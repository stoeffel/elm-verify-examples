module VerifyExamples.Comment exposing (Comment(..), function, parse)

import List.Extra
import Regex exposing (HowMany(..), Regex)
import Regex.Util exposing (newline, replaceLinesWith)
import String.Extra
import String.Util


type Comment
    = FunctionDoc { functionName : String, comment : String }
    | ModuleDoc String


parse : String -> List Comment
parse =
    Regex.find All commentRegex
        >> List.filterMap (toComment << .submatches)


toComment : List (Maybe String) -> Maybe Comment
toComment matches =
    case matches of
        (Just comment) :: _ :: Nothing :: _ ->
            Just (ModuleDoc (cleanSnippet comment))

        (Just comment) :: _ :: (Just functionName) :: _ ->
            Just (FunctionDoc { functionName = functionName, comment = cleanSnippet comment })

        _ ->
            Nothing


cleanSnippet : String -> String
cleanSnippet comment =
    comment
        -- replace non-blank lines that don't start with 4 spaces with a newline
        -- doing this instead of deleting to avoid joining different code snippets in a comment
        |> replaceLinesWith proseLineRegex ""
        -- remove 4-space indentation
        |> String.Extra.unindent


commentRegex : Regex
commentRegex =
    Regex.regex <|
        String.concat
            [ "{-\\|?([^]*?)-}" -- anything between comments
            , newline
            , "("
            , "([^\\s(" ++ newline ++ ")]+)" -- anything that is not a space or newline
            , "\\s[:=]" -- until ` :` or ` =`
            , ")?" -- it's possible that we have examples in comment not attached to a function
            ]


proseLineRegex : Regex
proseLineRegex =
    Regex.regex "^\\s?\\s?\\s?[^\\s]"


function : Comment -> Maybe String
function comment =
    case comment of
        FunctionDoc { functionName } ->
            Just functionName

        ModuleDoc _ ->
            Nothing
