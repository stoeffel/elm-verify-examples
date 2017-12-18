module String.Util exposing (..)

import Regex exposing (HowMany(..), regex)


unlines : List String -> String
unlines =
    String.join "\n"


escape : String -> String
escape =
    Regex.replace All (regex "\\\\") (\_ -> "\\\\")
        >> Regex.replace All (regex "\\\"") (\_ -> "\\\"")
        >> Regex.replace All (regex "\\s\\s+") (\_ -> " ")


indent : Int -> String -> String
indent count str =
    String.concat
        (List.repeat (count * 4) " " ++ [ str ])
