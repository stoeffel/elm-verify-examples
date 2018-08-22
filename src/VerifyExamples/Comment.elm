module VerifyExamples.Comment exposing (Comment(..), function, parse)

import Regex exposing (Regex)
import Regex.Util exposing (newline)


type Comment
    = FunctionDoc { functionName : String, comment : String }
    | ModuleDoc String


parse : String -> List Comment
parse =
    Regex.find commentRegex
        >> List.filterMap (toComment << .submatches)


toComment : List (Maybe String) -> Maybe Comment
toComment matches =
    case matches of
        (Just comment) :: _ :: Nothing :: _ ->
            Just (ModuleDoc comment)

        (Just comment) :: _ :: (Just functionName) :: _ ->
            Just (FunctionDoc { functionName = functionName, comment = comment })

        _ ->
            Nothing


commentRegex : Regex
commentRegex =
    Maybe.withDefault Regex.never <|
        Regex.fromString <|
            String.concat
                [ "({-[^]*?-})" -- anything between comments
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
