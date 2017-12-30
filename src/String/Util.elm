module String.Util exposing (escape, indent, indentLines, unlines)

import Regex exposing (HowMany(..), Regex, regex)


unlines : List String -> String
unlines =
    String.join "\n"


indent : Int -> String -> String
indent count str =
    String.concat
        (List.repeat (count * 4) " " ++ [ str ])


indentLines : Int -> String -> String
indentLines count =
    String.lines
        >> List.map (indent count)
        >> unlines


escape : String -> String
escape =
    Regex.replace All escapedSlashRegex (\_ -> "\\\\")
        >> Regex.replace All escapedDoubleQuote (\_ -> "\\\"")


escapedSlashRegex : Regex
escapedSlashRegex =
    regex "\\\\"


escapedDoubleQuote : Regex
escapedDoubleQuote =
    regex "\\\""
