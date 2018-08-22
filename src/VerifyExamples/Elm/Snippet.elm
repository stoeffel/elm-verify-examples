module VerifyExamples.Elm.Snippet exposing (Snippet(..), parse)

import Regex exposing (Regex)
import Regex.Util exposing (newline, replaceLinesWith)
import String.Util


type Snippet
    = ModuleDoc String
    | FunctionDoc { functionName : String, snippet : String }


parse : String -> List Snippet
parse =
    Regex.find commentRegex
        >> List.filterMap (toSnippet << .submatches)


toSnippet : List (Maybe String) -> Maybe Snippet
toSnippet matches =
    case matches of
        (Just comment) :: _ :: Nothing :: _ ->
            Just (ModuleDoc (cleanComment comment))

        (Just comment) :: _ :: (Just functionName) :: _ ->
            Just (FunctionDoc { functionName = functionName, snippet = cleanComment comment })

        _ ->
            Nothing


cleanComment : String -> String
cleanComment comment =
    comment
        -- replace non-blank lines that don't start with 4 spaces with a newline
        -- doing this instead of deleting to avoid joining different code snippets in a comment
        |> replaceLinesWith proseLineRegex ""
        -- remove 4-space indentation
        |> String.Util.unindent


commentRegex : Regex
commentRegex =
    String.concat
        [ "{-\\|?([^]*?)-}" -- anything between comments
        , newline
        , "("
        , "([^\\s(" ++ newline ++ ")]+)" -- anything that is not a space or newline
        , "\\s[:=]" -- until ` :` or ` =`
        , ")?" -- it's possible that we have examples in comment not attached to a function
        ]
        |> Regex.fromString
        |> Maybe.withDefault Regex.never


proseLineRegex : Regex
proseLineRegex =
    Regex.fromString "^\\s?\\s?\\s?[^\\s]"
        |> Maybe.withDefault Regex.never
