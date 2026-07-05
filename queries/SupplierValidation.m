let
    Source = Csv.Document(
        File.Contents("samples/supplier_master.csv"),
        [Delimiter=",", Columns=5, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),

    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),

    TrimmedText = Table.TransformColumns(
        PromotedHeaders,
        {
            {"SupplierID", each Text.Trim(Text.From(_)), type text},
            {"SupplierName", each Text.Trim(Text.From(_)), type text},
            {"Email", each Text.Trim(Text.From(_)), type text},
            {"Country", each Text.Trim(Text.From(_)), type text},
            {"Phone", each Text.Trim(Text.From(_)), type text}
        }
    ),

    EmptyToNull = Table.ReplaceValue(
        TrimmedText,
        "",
        null,
        Replacer.ReplaceValue,
        {"SupplierID", "SupplierName", "Email", "Country", "Phone"}
    ),

    GroupedSupplierID = Table.Group(
        EmptyToNull,
        {"SupplierID"},
        {{"Count", each Table.RowCount(_), Int64.Type}}
    ),

    MergedDuplicateCheck = Table.NestedJoin(
        EmptyToNull,
        {"SupplierID"},
        GroupedSupplierID,
        {"SupplierID"},
        "DuplicateCheck",
        JoinKind.LeftOuter
    ),

    ExpandedDuplicateCheck = Table.ExpandTableColumn(
        MergedDuplicateCheck,
        "DuplicateCheck",
        {"Count"},
        {"SupplierIDCount"}
    ),

    AddedDuplicateFlag = Table.AddColumn(
        ExpandedDuplicateCheck,
        "IsDuplicateSupplierID",
        each [SupplierID] <> null and [SupplierIDCount] > 1,
        type logical
    ),

    AddedMissingSupplierName = Table.AddColumn(
        AddedDuplicateFlag,
        "MissingSupplierName",
        each [SupplierName] = null,
        type logical
    ),

    AddedMissingEmail = Table.AddColumn(
        AddedMissingSupplierName,
        "MissingEmail",
        each [Email] = null,
        type logical
    ),

    AddedMissingCountry = Table.AddColumn(
        AddedMissingEmail,
        "MissingCountry",
        each [Country] = null,
        type logical
    ),

    AddedValidationStatus = Table.AddColumn(
        AddedMissingCountry,
        "ValidationStatus",
        each
            if [IsDuplicateSupplierID]
                or [MissingSupplierName]
                or [MissingEmail]
                or [MissingCountry]
            then "Invalid"
            else "Valid",
        type text
    ),

    AddedIssueReason = Table.AddColumn(
        AddedValidationStatus,
        "IssueReason",
        each
            Text.Combine(
                List.RemoveNulls({
                    if [IsDuplicateSupplierID] then "Duplicate SupplierID" else null,
                    if [MissingSupplierName] then "Missing SupplierName" else null,
                    if [MissingEmail] then "Missing Email" else null,
                    if [MissingCountry] then "Missing Country" else null
                }),
                "; "
            ),
        type text
    ),

    RemovedHelperColumns = Table.RemoveColumns(
        AddedIssueReason,
        {"SupplierIDCount"}
    )
in
    RemovedHelperColumns
