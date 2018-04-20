module Regex.Util exposing (firstSubmatch, newline, replaceAllWith, replaceLinesWith, submatches)

import List.Extra exposing (replaceIf)
import Regex exposing (HowMany(..), Regex)
import String.Extra exposing (unindent)


submatches : Regex -> (String -> List String)
submatches regex str =
    Regex.find (AtMost 1) regex str
        |> List.concatMap .submatches
        |> List.filterMap identity


firstSubmatch : Regex -> (String -> Maybe String)
firstSubmatch regex str =
    submatches regex str
        |> List.head


newline : String
newline =
    "\x0D?\n"


replaceAllWith : Regex -> String -> String -> String
replaceAllWith regex with =
    Regex.replace Regex.All regex (always with)


{-| Replace all lines matching a regex. Unlike `replaceAllWith`, `^` and `$` will match the beginning and end of line instead of the whole input.
-}
replaceLinesWith : Regex -> String -> String -> String
replaceLinesWith regex with =
    String.lines
        >> replaceIf (Regex.contains regex) with
        >> String.join "\n"
        >> unindent
