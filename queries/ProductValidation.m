let
    Source =
        Csv.Document(
            File.Contents("product_catalog.csv"),
            [Delimiter=",", Encoding=65001]
        ),

    Headers =
        Table.PromoteHeaders(Source),

    // Normalize text fields.
    // 文字列項目を正規化する。
    Normalized =
        Table.TransformColumns(
            Headers,
            {
                {
                    "ProductID",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "SKU",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "ProductName",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Category",
                    each NormalizeText(_),
                    type nullable text
                },
                {
                    "Price",
                    each NormalizeText(_),
                    type nullable text
                }
            }
        ),


    AddedPriceNumber =
        Table.AddColumn(
            Normalized,            "PriceNumber",
            each try Number.FromText([Price]) otherwise null,
            type nullable number
        ),

    Grouped =
        Table.Group(
            AddedPriceNumber,
            {"ProductID"},
            {
                {"Rows", each _, type table},
                {"Count", each Table.RowCount(_), Int64.Type}
            }
        ),

    Expanded =
        Table.ExpandTableColumn(
            Grouped,
            "Rows",
            {"SKU", "ProductName", "Category", "Price", "PriceNumber"},
            {"SKU", "ProductName", "Category", "Price", "PriceNumber"}
        ),

    AddedDuplicateFlag =
        Table.AddColumn(
            Expanded,
            "IsDuplicateProductID",
            each [Count] > 1,
            type logical
        ),

    AddedMissingSKU =
        Table.AddColumn(
            AddedDuplicateFlag,
            "MissingSKU",
            each [SKU] = null,
            type logical
        ),

    AddedMissingProductName =
        Table.AddColumn(
            AddedMissingSKU,
            "MissingProductName",
            each [ProductName] = null,
            type logical
        ),

    AddedMissingCategory =
        Table.AddColumn(
            AddedMissingProductName,
            "MissingCategory",
            each [Category] = null,
            type logical
        ),

    AddedInvalidPrice =
        Table.AddColumn(
            AddedMissingCategory,
            "InvalidPrice",
            each [PriceNumber] = null or [PriceNumber] <= 0,
            type logical
        ),

    AddedStatus =
        Table.AddColumn(
            AddedInvalidPrice,
            "ValidationStatus",
            each
                if
                    [IsDuplicateProductID]
                    or [MissingSKU]
                    or [MissingProductName]
                    or [MissingCategory]
                    or [InvalidPrice]
                then "Review"
                else "OK",
            type text
        ),

    AddedIssueReason =
        Table.AddColumn(
            AddedStatus,
            "IssueReason",
            each
                let
                    reasons =
                        List.RemoveNulls(
                            {
                                if [IsDuplicateProductID] then "Duplicate ProductID" else null,
                                if [MissingSKU] then "Missing SKU" else null,
                                if [MissingProductName] then "Missing ProductName" else null,
                                if [MissingCategory] then "Missing Category" else null,
                                if [InvalidPrice] then "Invalid Price" else null
                            }
                        )
                in
                    if List.Count(reasons) = 0
                    then null
                    else Text.Combine(reasons, "; "),
            type nullable text
        ),

    RemovedHelperColumns =
        Table.RemoveColumns(
            AddedIssueReason,
            {"Count"}
        )

in
    RemovedHelperColumns
