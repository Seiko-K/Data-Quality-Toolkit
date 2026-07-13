(value as nullable text) as nullable text =>
let
    Result =
        if value = null or value = ""
        then null
        else value
in
    Result
