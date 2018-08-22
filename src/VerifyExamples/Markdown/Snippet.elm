module VerifyExamples.Markdown.Snippet exposing (Snippet(..), parse)

import Regex exposing (Regex)
import Regex.Util exposing (newline)


type Snippet
    = Snippet String


parse : String -> List Snippet
parse =
    Regex.find commentRegex
        >> List.filterMap (toSnippet << .submatches)


toSnippet : List (Maybe String) -> Maybe Snippet
toSnippet matches =
    case matches of
        (Just comment) :: [] ->
            Just (Snippet comment)

        _ ->
            Nothing


commentRegex : Regex
commentRegex =
    String.concat
        [ "```elm"
        , newline
        , "([^]*?)"
        , newline
        , "```"
        ]
        |> Regex.fromString
        |> Maybe.withDefault Regex.never
