let
    // Load the research metadata CSV file.
    // 研究メタデータCSVファイルを読み込む。
    Source =
        Csv.Document(
            File.Contents("research_metadata.csv"),
            [
                Delimiter = ",",
                Encoding = 65001
            ]
        ),

    // Promote the first row to column headers.
    // 先頭行を列見出しとして昇格する。
    Headers =
        Table.PromoteHeaders(
            Source
        ),

    // Normalize metadata fields using the shared NormalizeText function.
    // 共通関数 NormalizeText を使用して、各メタデータ項目を正規化する。
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
            Headers,
            {
                {
                    "DOI",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Title",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Author",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Journal",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Year",
                    each NormalizeText(_),
                    type nullable text
                }
            }
        ),

    // Count rows for each DOI.
    // DOIごとの件数を集計する。
    GroupedDOI =
        Table.Group(
            Normalized,
            {"DOI"},
            {
                {
                    "Count",
                    each Table.RowCount(_),
                    Int64.Type
                }
            }
        ),

    // Merge DOI counts back into the normalized metadata table.
    // DOIごとの件数を正規化済みメタデータへ結合する。
    MergedDuplicateCheck =
        Table.NestedJoin(
            Normalized,
            {"DOI"},
            GroupedDOI,
            {"DOI"},
            "DuplicateCheck",
            JoinKind.LeftOuter
        ),

    // Expand the DOI count column.
    // DOI件数の列を展開する。
    ExpandedDuplicateCheck =
        Table.ExpandTableColumn(
            MergedDuplicateCheck,
            "DuplicateCheck",
            {"Count"},
            {"DOICount"}
        ),

    // Flag duplicate DOI values.
    // DOIの重複を判定する。
    //
    // Null DOI values are excluded from duplicate detection because
    // missing DOI values are handled separately by MissingDOI.
    // null の DOI は重複判定から除外する。
    // DOI未入力については MissingDOI で別途判定する。
    AddedDuplicateFlag =
        Table.AddColumn(
            ExpandedDuplicateCheck,
            "IsDuplicateDOI",
            each
                [DOI] <> null
                and [DOICount] > 1,
            type logical
        ),

    // Flag missing DOI values.
    // DOIの未入力を判定する。
    AddedMissingDOI =
        Table.AddColumn(
            AddedDuplicateFlag,
            "MissingDOI",
            each [DOI] = null,
            type logical
        ),

    // Flag missing titles.
    // Titleの未入力を判定する。
    AddedMissingTitle =
        Table.AddColumn(
            AddedMissingDOI,
            "MissingTitle",
            each [Title] = null,
            type logical
        ),

    // Flag missing authors.
    // Authorの未入力を判定する。
    AddedMissingAuthor =
        Table.AddColumn(
            AddedMissingTitle,
            "MissingAuthor",
            each [Author] = null,
            type logical
        ),

    // Determine the overall validation status.
    // 各検証結果をもとに、全体の検証ステータスを判定する。
    AddedValidationStatus =
        Table.AddColumn(
            AddedMissingAuthor,
            "ValidationStatus",
            each
                if
                    [IsDuplicateDOI]
                    or [MissingDOI]
                    or [MissingTitle]
                    or [MissingAuthor]
                then
                    "Review"
                else
                    "OK",
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
                                if [IsDuplicateDOI]
                                then "Duplicate DOI"
                                else null,

                                if [MissingDOI]
                                then "Missing DOI"
                                else null,

                                if [MissingTitle]
                                then "Missing Title"
                                else null,

                                if [MissingAuthor]
                                then "Missing Author"
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
            {"DOICount"}
        )

in
    RemovedHelperColumns