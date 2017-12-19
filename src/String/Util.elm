module String.Util exposing (escape, indent, unlines)

import Regex exposing (HowMany(..), Regex, regex)


unlines : List String -> String
unlines =
    String.join "\n"


indent : Int -> String -> String
indent count str =
    String.concat
        (List.repeat (count * 4) " " ++ [ str ])


escape : String -> String
escape =
    Regex.replace All escapedSlashRegex (\_ -> "\\\\")
        >> Regex.replace All escapedDoubleQuote (\_ -> "\\\"")
        >> Regex.replace All spacesRegex (\_ -> " ")


escapedSlashRegex : Regex
escapedSlashRegex =
    regex "\\\\"


escapedDoubleQuote : Regex
escapedDoubleQuote =
    regex "\\\""


spacesRegex : Regex
spacesRegex =
    regex "\\s\\s+"
