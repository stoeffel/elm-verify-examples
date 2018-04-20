module VerifyExamples.Comment exposing (Comment(..), function, parse)

import Regex exposing (HowMany(..), Regex)
import Regex.Util exposing (newline)
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
        |> String.lines
        |> List.filter (Regex.contains snippetLineRegex)
        |> String.Util.unlines
        |> String.Extra.unindent


snippetLineRegex : Regex
snippetLineRegex =
    Regex.regex <| "(^\\s*$)|(\\s{4}(.*))"


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


function : Comment -> Maybe String
function comment =
    case comment of
        FunctionDoc { functionName } ->
            Just functionName

        ModuleDoc _ ->
            Nothing
