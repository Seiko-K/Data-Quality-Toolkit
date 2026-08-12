let
    Source =
        Csv.Document(
            File.Contents("research_metadata.csv"),
            [Delimiter=",", Encoding=65001]
        ),

    Headers =
        Table.PromoteHeaders(Source),

    Trimmed =
        Table.TransformColumns(
            Headers,
            {
                {"DOI", Text.Trim},
                {"Title", Text.Trim},
                {"Author", Text.Trim},
                {"Journal", Text.Trim},
                {"Year", Text.Trim}
            }
        ),

    EmptyToNull =
        Table.ReplaceValue(
            Trimmed,
            "",
            null,
            Replacer.ReplaceValue,
            {"DOI", "Title", "Author", "Journal", "Year"}
        ),

    Grouped =
        Table.Group(
            EmptyToNull,
            {"DOI"},
            {
                {"Rows", each _, type table},
                {"Count", each Table.RowCount(_), Int64.Type}
            }
        ),

    Expanded =
        Table.ExpandTableColumn(
            Grouped,
            "Rows",
            {"Title", "Author", "Journal", "Year"},
            {"Title", "Author", "Journal", "Year"}
        ),

    AddedDuplicateFlag =
        Table.AddColumn(
            Expanded,
            "IsDuplicateDOI",
            each [Count] > 1,
            type logical
        ),

    AddedMissingDOI =
        Table.AddColumn(
            AddedDuplicateFlag,
            "MissingDOI",
            each [DOI] = null,
            type logical
        ),

    AddedMissingTitle =
        Table.AddColumn(
            AddedMissingDOI,
            "MissingTitle",
            each [Title] = null,
            type logical
        ),

    AddedMissingAuthor =
        Table.AddColumn(
            AddedMissingTitle,
            "MissingAuthor",
            each [Author] = null,
            type logical
        ),

    AddedStatus =
        Table.AddColumn(
            AddedMissingAuthor,
            "ValidationStatus",
            each
                if
                    [IsDuplicateDOI]
                    or [MissingDOI]
                    or [MissingTitle]
                    or [MissingAuthor]
                then "Review"
                else "OK",
            type text
        ),

    AddedIssueReason =
        Table.AddColumn(
            AddedStatus,
            "IssueReason",
            each
                Text.Combine(
                    List.RemoveNulls(
                        {
                            if [IsDuplicateDOI] then "Duplicate DOI" else null,
                            if [MissingDOI] then "Missing DOI" else null,
                            if [MissingTitle] then "Missing Title" else null,
                            if [MissingAuthor] then "Missing Author" else null
                        }
                    ),
                    "; "
                ),
            type text
        ),

    RemovedHelperColumns =
        Table.RemoveColumns(
            AddedIssueReason,
            {"Count"}
        )

in
    RemovedHelperColumns
    