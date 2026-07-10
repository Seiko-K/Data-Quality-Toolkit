let
    Source = Csv.Document(
        File.Contents("samples/invoice_master.csv"),
        [Delimiter=",", Columns=4, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),

    PromotedHeaders = Table.PromoteHeaders(
        Source,
        [PromoteAllScalars=true]
    ),

    TrimmedText = Table.TransformColumns(
        PromotedHeaders,
        {
            {"InvoiceID", each Text.Trim(Text.From(_)), type text},
            {"CustomerID", each Text.Trim(Text.From(_)), type text},
            {"InvoiceDate", each Text.Trim(Text.From(_)), type text},
            {"Amount", each Text.Trim(Text.From(_)), type text}
        }
    ),

    EmptyToNull = Table.ReplaceValue(
        TrimmedText,
        "",
        null,
        Replacer.ReplaceValue,
        {"InvoiceID", "CustomerID", "InvoiceDate", "Amount"}
    ),

    GroupedInvoiceID = Table.Group(
        EmptyToNull,
        {"InvoiceID"},
        {
            {
                "Count",
                each Table.RowCount(_),
                Int64.Type
            }
        }
    ),

    MergedDuplicateCheck = Table.NestedJoin(
        EmptyToNull,
        {"InvoiceID"},
        GroupedInvoiceID,
        {"InvoiceID"},
        "DuplicateCheck",
        JoinKind.LeftOuter
    ),

    ExpandedDuplicateCheck = Table.ExpandTableColumn(
        MergedDuplicateCheck,
        "DuplicateCheck",
        {"Count"},
        {"InvoiceIDCount"}
    ),

    AddedDuplicateFlag = Table.AddColumn(
        ExpandedDuplicateCheck,
        "IsDuplicateInvoiceID",
        each
            [InvoiceID] <> null
            and [InvoiceIDCount] > 1,
        type logical
    ),

    AddedMissingCustomerID = Table.AddColumn(
        AddedDuplicateFlag,
        "MissingCustomerID",
        each [CustomerID] = null,
        type logical
    ),

    AddedMissingInvoiceDate = Table.AddColumn(
        AddedMissingCustomerID,
        "MissingInvoiceDate",
        each [InvoiceDate] = null,
        type logical
    ),

    AddedInvalidAmount = Table.AddColumn(
        AddedMissingInvoiceDate,
        "InvalidAmount",
        each
            let
                ConvertedAmount =
                    try Number.From([Amount])
                    otherwise null
            in
                ConvertedAmount = null
                or ConvertedAmount <= 0,
        type logical
    ),

    AddedValidationStatus = Table.AddColumn(
        AddedInvalidAmount,
        "ValidationStatus",
        each
            if
                [IsDuplicateInvoiceID]
                or [MissingCustomerID]
                or [MissingInvoiceDate]
                or [InvalidAmount]
            then
                "Invalid"
            else
                "Valid",
        type text
    ),

    AddedIssueReason = Table.AddColumn(
        AddedValidationStatus,
        "IssueReason",
        each
            Text.Combine(
                List.RemoveNulls(
                    {
                        if [IsDuplicateInvoiceID]
                        then "Duplicate InvoiceID"
                        else null,

                        if [MissingCustomerID]
                        then "Missing CustomerID"
                        else null,

                        if [MissingInvoiceDate]
                        then "Missing InvoiceDate"
                        else null,

                        if [InvalidAmount]
                        then "Invalid Amount"
                        else null
                    }
                ),
                "; "
            ),
        type text
    ),

    RemovedHelperColumns = Table.RemoveColumns(
        AddedIssueReason,
        {"InvoiceIDCount"}
    )
in
    RemovedHelperColumns
