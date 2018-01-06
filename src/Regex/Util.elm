module Regex.Util exposing (firstSubmatch, newline, replaceAllWith, submatches)

import Regex exposing (HowMany(..), Regex)


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
