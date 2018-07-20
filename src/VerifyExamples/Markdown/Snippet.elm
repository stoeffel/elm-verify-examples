module VerifyExamples.Markdown.Snippet exposing (Snippet(..), parse)

import Regex exposing (HowMany(..), Regex)
import Regex.Util exposing (newline)


type Snippet
    = Snippet String


parse : String -> List Snippet
parse =
    Regex.find All commentRegex
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
    Regex.regex <|
        String.concat
            [ "```elm"
            , newline
            , "([^]*?)"
            , newline
            , "```"
            ]
