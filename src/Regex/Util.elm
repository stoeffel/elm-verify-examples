module Regex.Util exposing (firstSubmatch, newline, replaceAllWith, replaceLinesWith, submatches)

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
    "\x0D?\n"


replaceAllWith : Regex -> String -> String -> String
replaceAllWith regex with string =
    Regex.replace regex (always with) string


{-| Replace all lines matching a regex. Unlike `replaceAllWith`, `^` and `$` will match the beginning and end of line instead of the whole input.
-}
replaceLinesWith : Regex -> String -> String -> String
replaceLinesWith regex with =
    String.lines
        >> replaceIf (Regex.contains regex) with
        >> String.join "\n"
        >> unindent


replaceIf : (String -> Bool) -> String -> String -> String
replaceIf fn with string =
    if fn string then
        with

    else
        string


{-| Remove the shortest sequence of leading spaces or tabs on each line
of the string, so that at least one of the lines will not have any
leading spaces nor tabs and the rest of the lines will have the same
amount of indentation removed.
unindent " Hello\\n World " == "Hello\\n World"
unindent "\\t\\tHello\\n\\t\\t\\t\\tWorld" == "Hello\\n\\t\\tWorld"
-}
unindent : String -> String
unindent multilineSting =
    let
        lines =
            String.lines multilineSting

        countLeadingWhitespace count line =
            case String.uncons line of
                Nothing ->
                    count

                Just ( char, rest ) ->
                    case char of
                        ' ' ->
                            countLeadingWhitespace (count + 1) rest

                        '\t' ->
                            countLeadingWhitespace (count + 1) rest

                        _ ->
                            count

        isNotWhitespace char =
            char /= ' ' && char /= '\t'

        minLead =
            lines
                |> List.filter (String.any isNotWhitespace)
                |> List.map (countLeadingWhitespace 0)
                |> List.minimum
                |> Maybe.withDefault 0
    in
    lines
        |> List.map (String.dropLeft minLead)
        |> String.join "\n"
