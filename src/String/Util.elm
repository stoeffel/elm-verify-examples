module String.Util exposing (escape, indent, indentLines, unlines)

import Regex exposing (HowMany(..), Regex, regex)
import Regex.Util exposing (replaceAllWith)


{-| Joins strings with a newline.

    unlines
        [ "a"
        , "b"
        , "c"
        ]
    --> "a\nb\nc"

-}
unlines : List String -> String
unlines =
    String.join "\n"


{-| Indents a string by steps of 4 characters.

    indent 1 "hello" --> "    hello"

    indent 2 "hello" --> "        hello"

-}
indent : Int -> String -> String
indent count str =
    String.concat
        (List.repeat (count * 4) " " ++ [ str ])


{-| Indent all lines in a string.

    indentLines 1 <|
        unlines
            [ "|"
            , "|"
            ]
    --> unlines
    -->     [ "    |"
    -->     , "    |"
    -->     ]

-}
indentLines : Int -> String -> String
indentLines count =
    String.lines
        >> List.map (indent count)
        >> unlines


escape : String -> String
escape =
    replaceAllWith escapedSlashRegex "\\\\"
        >> replaceAllWith escapedDoubleQuote "\\\""


escapedSlashRegex : Regex
escapedSlashRegex =
    regex "\\\\"


escapedDoubleQuote : Regex
escapedDoubleQuote =
    regex "\\\""
