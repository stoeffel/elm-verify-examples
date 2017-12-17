module Regex.Util exposing (firstSubmatch)

import Regex exposing (HowMany(..), Regex)


firstSubmatch : Regex -> (String -> Maybe String)
firstSubmatch regex str =
    Regex.find (AtMost 1) regex str
        |> List.concatMap .submatches
        |> List.filterMap identity
        |> List.head
