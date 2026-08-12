let
    // Load the inventory master CSV file.
    // 在庫マスターCSVファイルを読み込む。
    Source =
        Csv.Document(
            File.Contents("samples/inventory_master.csv"),
            [
                Delimiter = ",",
                Columns = 4,
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

    // Normalize text columns using the shared NormalizeText function.
    // 共通関数 NormalizeText を使用して、文字列列を正規化する。
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
                    "InventoryID",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "ProductID",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Warehouse",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Quantity",
                    each NormalizeText(_),
                    type nullable text
                }
            }
        ),

    // Count rows for each InventoryID.
    // InventoryIDごとの件数を集計する。
    GroupedInventoryID =
        Table.Group(
            Normalized,
            {"InventoryID"},
            {
                {
                    "Count",
                    each Table.RowCount(_),
                    Int64.Type
                }
            }
        ),

    // Merge InventoryID counts back into the normalized table.
    // InventoryIDごとの件数を正規化済みテーブルへ結合する。
    MergedDuplicateCheck =
        Table.NestedJoin(
            Normalized,
            {"InventoryID"},
            GroupedInventoryID,
            {"InventoryID"},
            "DuplicateCheck",
            JoinKind.LeftOuter
        ),

    // Expand the InventoryID count column.
    // InventoryID件数の列を展開する。
    ExpandedDuplicateCheck =
        Table.ExpandTableColumn(
            MergedDuplicateCheck,
            "DuplicateCheck",
            {"Count"},
            {"InventoryIDCount"}
        ),

    // Flag duplicate InventoryID values.
    // InventoryIDの重複を判定する。
    //
    // Null InventoryID values are excluded from duplicate detection.
    // null の InventoryID は重複判定の対象外とする。
    AddedDuplicateFlag =
        Table.AddColumn(
            ExpandedDuplicateCheck,
            "IsDuplicateInventoryID",
            each
                [InventoryID] <> null
                and [InventoryIDCount] > 1,
            type logical
        ),

    // Flag missing ProductID values.
    // ProductIDの未入力を判定する。
    AddedMissingProductID =
        Table.AddColumn(
            AddedDuplicateFlag,
            "MissingProductID",
            each [ProductID] = null,
            type logical
        ),

    // Flag missing warehouse values.
    // Warehouseの未入力を判定する。
    AddedMissingWarehouse =
        Table.AddColumn(
            AddedMissingProductID,
            "MissingWarehouse",
            each [Warehouse] = null,
            type logical
        ),

    // Convert Quantity to a number for validation.
    // Quantityを検証用の数値へ変換する。
    AddedQuantityNumber =
        Table.AddColumn(
            AddedMissingWarehouse,
            "QuantityNumber",
            each
                try Number.FromText([Quantity])
                otherwise null,
            type nullable number
        ),

    // Flag invalid quantity values.
    // Quantityが未入力、数値変換不可、または負数の場合にエラーとする。
    //
    // Zero is allowed because valid inventory can be out of stock.
    // 在庫切れを表現できるよう、0は有効値として扱う。
    AddedInvalidQuantity =
        Table.AddColumn(
            AddedQuantityNumber,
            "InvalidQuantity",
            each
                [QuantityNumber] = null
                or [QuantityNumber] < 0,
            type logical
        ),

    // Determine the overall validation status.
    // 各検証結果をもとに、全体の検証ステータスを判定する。
    AddedValidationStatus =
        Table.AddColumn(
            AddedInvalidQuantity,
            "ValidationStatus",
            each
                if
                    [IsDuplicateInventoryID]
                    or [MissingProductID]
                    or [MissingWarehouse]
                    or [InvalidQuantity]
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
                                if [IsDuplicateInventoryID]
                                then "Duplicate InventoryID"
                                else null,

                                if [MissingProductID]
                                then "Missing ProductID"
                                else null,

                                if [MissingWarehouse]
                                then "Missing Warehouse"
                                else null,

                                if [InvalidQuantity]
                                then "Invalid Quantity"
                                else null
                            }
                        )
                in
                    if List.Count(Reasons) = 0
                    then null
                    else Text.Combine(Reasons, "; "),
            type nullable text
        ),

    // Remove helper columns used only during validation.
    // 検証処理だけに使用した補助列を削除する。
    RemovedHelperColumns =
        Table.RemoveColumns(
            AddedIssueReason,
            {
                "InventoryIDCount",
                "QuantityNumber"
            }
        )

in
    RemovedHelperColumns