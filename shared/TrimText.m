(value as any) as nullable text =>
let
    ConvertedToText =
        if value = null
        then null
        else Text.From(value),

    TrimmedText =
        if ConvertedToText = null
        then null
        else Text.Trim(ConvertedToText)
in
    TrimmedText
