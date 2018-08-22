module Regex.Util exposing (firstSubmatch, newline, replaceAllWith, submatches)

import Regex exposing (Regex)


submatches : Regex -> (String -> List String)
submatches regex =
    Regex.findAtMost 1 regex
        >> List.concatMap .submatches
        >> List.filterMap identity


firstSubmatch : Regex -> (String -> Maybe String)
firstSubmatch regex str =
    submatches regex str
        |> List.head


newline : String
newline =
    "\u{000D}?\n"


replaceAllWith : Regex -> String -> String -> String
replaceAllWith regex with string =
    Regex.replace regex (always with) string
