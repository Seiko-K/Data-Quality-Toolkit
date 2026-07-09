let
    Source = Csv.Document(
        File.Contents("samples/inventory_master.csv"),
        [Delimiter=",", Columns=4, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),

    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),

    TrimmedText = Table.TransformColumns(
        PromotedHeaders,
        {
            {"InventoryID", each Text.Trim(Text.From(_)), type text},
            {"ProductID", each Text.Trim(Text.From(_)), type text},
            {"Warehouse", each Text.Trim(Text.From(_)), type text},
            {"Quantity", each Text.Trim(Text.From(_)), type text}
        }
    ),

    EmptyToNull = Table.ReplaceValue(
        TrimmedText,
        "",
        null,
        Replacer.ReplaceValue,
        {"InventoryID", "ProductID", "Warehouse", "Quantity"}
    ),

    GroupedInventoryID =
        Table.Group(
            EmptyToNull,
            {"InventoryID"},
            {{"Count", each Table.RowCount(_), Int64.Type}}
        ),

    MergedDuplicate =
        Table.NestedJoin(
            EmptyToNull,
            {"InventoryID"},
            GroupedInventoryID,
            {"InventoryID"},
            "DuplicateCheck",
            JoinKind.LeftOuter
        ),

    ExpandedDuplicate =
        Table.ExpandTableColumn(
            MergedDuplicate,
            "DuplicateCheck",
            {"Count"},
            {"InventoryIDCount"}
        ),

    AddedDuplicate =
        Table.AddColumn(
            ExpandedDuplicate,
            "IsDuplicateInventoryID",
            each [InventoryID] <> null and [InventoryIDCount] > 1,
            type logical
        ),

    AddedMissingProduct =
        Table.AddColumn(
            AddedDuplicate,
            "MissingProductID",
            each [ProductID] = null,
            type logical
        ),

    AddedMissingWarehouse =
        Table.AddColumn(
            AddedMissingProduct,
            "MissingWarehouse",
            each [Warehouse] = null,
            type logical
        ),

    AddedInvalidQuantity =
        Table.AddColumn(
            AddedMissingWarehouse,
            "InvalidQuantity",
            each
                let
                    q = try Number.From([Quantity]) otherwise null
                in
                    q = null or q < 0,
            type logical
        ),

    AddedValidationStatus =
        Table.AddColumn(
            AddedInvalidQuantity,
            "ValidationStatus",
            each
                if [IsDuplicateInventoryID]
                    or [MissingProductID]
                    or [MissingWarehouse]
                    or [InvalidQuantity]
                then "Invalid"
                else "Valid",
            type text
        ),

    AddedIssueReason =
        Table.AddColumn(
            AddedValidationStatus,
            "IssueReason",
            each
                Text.Combine(
                    List.RemoveNulls({
                        if [IsDuplicateInventoryID] then "Duplicate InventoryID" else null,
                        if [MissingProductID] then "Missing ProductID" else null,
                        if [MissingWarehouse] then "Missing Warehouse" else null,
                        if [InvalidQuantity] then "Invalid Quantity" else null
                    }),
                    "; "
                ),
            type text
        ),

    RemovedHelper =
        Table.RemoveColumns(
            AddedIssueReason,
            {"InventoryIDCount"}
        )

in
    RemovedHelper
