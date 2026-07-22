let
    // Load the supplier master CSV file.
    // 仕入先マスターCSVファイルを読み込む。
    Source =
        Csv.Document(
            File.Contents("samples/supplier_master.csv"),
            [
                Delimiter = ",",
                Columns = 5,
                Encoding = 65001,
                QuoteStyle = QuoteStyle.None
            ]
        ),

    // Promote the first row to column headers.
    // 先頭行を列見出しとして昇格する。
    PromotedHeaders =
        Table.PromoteHeaders(
            Source,
            [PromoteAllScalars = true]
        ),

    // Normalize all text columns using the shared NormalizeText function.
    // 共通関数 NormalizeText を使用して、すべての文字列列を正規化する。
    //
    // NormalizeText performs:
    // NormalizeText の処理内容：
    // - Converts values to text.
    // - 値を文字列へ変換する。
    // - Removes leading and trailing spaces.
    // - 前後の空白を削除する。
    // - Converts empty strings to null.
    // - 空文字を null に変換する。
    Normalized =
        Table.TransformColumns(
            PromotedHeaders,
            {
                {
                    "SupplierID",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "SupplierName",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Email",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Country",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Phone",
                    each NormalizeText(_),
                    type nullable text
                }
            }
        ),

    // Count rows for each SupplierID.
    // SupplierIDごとの件数を集計する。
    GroupedSupplierID =
        Table.Group(
            Normalized,
            {"SupplierID"},
            {
                {
                    "Count",
                    each Table.RowCount(_),
                    Int64.Type
                }
            }
        ),

    // Merge the SupplierID counts back into the normalized table.
    // SupplierIDごとの件数を正規化済みテーブルへ結合する。
    MergedDuplicateCheck =
        Table.NestedJoin(
            Normalized,
            {"SupplierID"},
            GroupedSupplierID,
            {"SupplierID"},
            "DuplicateCheck",
            JoinKind.LeftOuter
        ),

    // Expand the SupplierID count column.
    // SupplierID件数の列を展開する。
    ExpandedDuplicateCheck =
        Table.ExpandTableColumn(
            MergedDuplicateCheck,
            "DuplicateCheck",
            {"Count"},
            {"SupplierIDCount"}
        ),

    // Flag duplicate SupplierID values.
    // SupplierIDの重複を判定する。
    //
    // Null SupplierID values are excluded from duplicate detection.
    // null の SupplierID は重複判定の対象外とする。
    AddedDuplicateFlag =
        Table.AddColumn(
            ExpandedDuplicateCheck,
            "IsDuplicateSupplierID",
            each
                [SupplierID] <> null
                and [SupplierIDCount] > 1,
            type logical
        ),

    // Flag missing supplier names.
    // SupplierNameの未入力を判定する。
    AddedMissingSupplierName =
        Table.AddColumn(
            AddedDuplicateFlag,
            "MissingSupplierName",
            each [SupplierName] = null,
            type logical
        ),

    // Flag missing email addresses.
    // Emailの未入力を判定する。
    AddedMissingEmail =
        Table.AddColumn(
            AddedMissingSupplierName,
            "MissingEmail",
            each [Email] = null,
            type logical
        ),

    // Flag missing country values.
    // Countryの未入力を判定する。
    AddedMissingCountry =
        Table.AddColumn(
            AddedMissingEmail,
            "MissingCountry",
            each [Country] = null,
            type logical
        ),

    // Determine the overall validation status.
    // 各検証結果をもとに、全体の検証ステータスを判定する。
    AddedValidationStatus =
        Table.AddColumn(
            AddedMissingCountry,
            "ValidationStatus",
            each
                if
                    [IsDuplicateSupplierID]
                    or [MissingSupplierName]
                    or [MissingEmail]
                    or [MissingCountry]
                then
                    "Invalid"
                else
                    "Valid",
            type text
        ),

    // Create a readable list of validation issues.
    // 検出された問題を、人が確認しやすい形式でまとめる。
    AddedIssueReason =
        Table.AddColumn(
            AddedValidationStatus,
            "IssueReason",
            each
                let
                    Reasons =
                        List.RemoveNulls(
                            {
                                if [IsDuplicateSupplierID]
                                then "Duplicate SupplierID"
                                else null,

                                if [MissingSupplierName]
                                then "Missing SupplierName"
                                else null,

                                if [MissingEmail]
                                then "Missing Email"
                                else null,

                                if [MissingCountry]
                                then "Missing Country"
                                else null
                            }
                        )
                in
                    if List.Count(Reasons) = 0
                    then null
                    else Text.Combine(Reasons, "; "),
            type nullable text
        ),

    // Remove the helper column used only for duplicate detection.
    // 重複判定だけに使用した補助列を削除する。
    RemovedHelperColumns =
        Table.RemoveColumns(
            AddedIssueReason,
            {"SupplierIDCount"}
        )

in
    RemovedHelperColumns