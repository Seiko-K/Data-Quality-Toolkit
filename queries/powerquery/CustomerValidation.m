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
                {"Name", Text.Trim}
            }
        ),

    Deduplicated =
        Table.Distinct(Trimmed)

in
    Deduplicated
