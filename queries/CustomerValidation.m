let
    Source =
        Csv.Document(
            File.Contents("customer_master.csv"),
            [Delimiter=",", Encoding=65001]
        ),

    Headers =
        Table.PromoteHeaders(Source),

    Trimmed =
        Table.TransformColumns(
            Headers,
            {
                {"CustomerID", Text.Trim},
                {"Name", Text.Trim},
                {"Email", Text.Trim}
            }
        ),

    EmptyToNull =
        Table.ReplaceValue(
            Trimmed,
            "",
            null,
            Replacer.ReplaceValue,
            {"CustomerID", "Name", "Email"}
        ),

    Grouped =
        Table.Group(
            EmptyToNull,
            {"CustomerID"},
            {
                {"Rows", each _, type table},
                {"Count", each Table.RowCount(_), Int64.Type}
            }
        ),

    Expanded =
        Table.ExpandTableColumn(
            Grouped,
            "Rows",
            {"Name", "Email"},
            {"Name", "Email"}
        ),

    AddedDuplicateFlag =
        Table.AddColumn(
            Expanded,
            "IsDuplicateCustomerID",
            each [Count] > 1,
            type logical
        ),

    AddedMissingName =
        Table.AddColumn(
            AddedDuplicateFlag,
            "MissingName",
            each [Name] = null,
            type logical
        ),

    AddedMissingEmail =
        Table.AddColumn(
            AddedMissingName,
            "MissingEmail",
            each [Email] = null,
            type logical
        ),

    AddedStatus =
        Table.AddColumn(
            AddedMissingEmail,
            "ValidationStatus",
            each
                if [MissingName] or [MissingEmail] or [IsDuplicateCustomerID]
                then "Review"
                else "OK",
            type text
        ),

    RemovedHelperCount =
        Table.RemoveColumns(
            AddedStatus,
            {"Count"}
        )

in
    RemovedHelperCount
