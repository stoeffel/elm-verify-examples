module VerifyExamples.ExposedApi exposing
    ( ExposedApi
    , definitions
    , isEverythingExposed
    , parse
    , reject
    )

import Regex exposing (Regex)
import Regex.Util exposing (firstSubmatch, newline, replaceAllWith)


type ExposedApi
    = Explicitly (List String)
    | All
    | None


parse : String -> ExposedApi
parse value =
    value
        |> firstSubmatch moduleExposing
        |> Maybe.map toExposedDefinition
        |> Maybe.withDefault None


toExposedDefinition : String -> ExposedApi
toExposedDefinition match =
    case match of
        ".." ->
            All

        defs ->
            defs
                |> String.split ","
                |> List.map (replaceAllWith typeConstructors "" << String.trim)
                |> Explicitly


typeConstructors : Regex
typeConstructors =
    Regex.fromString "\\([^]*?\\)"
        |> Maybe.withDefault Regex.never


moduleExposing : Regex
moduleExposing =
    String.concat
        [ "module"
        , "[^]*?exposing"
        , "[^]*?\\("
        , "([^]*?)(\\)\\nimport|\\)\\n\\n)"
        ]
        |> Regex.fromString
        |> Maybe.withDefault Regex.never


reject : (String -> Bool) -> ExposedApi -> ExposedApi
reject f api =
    case api of
        Explicitly defs ->
            List.filter (\def -> not (f def)) defs
                |> Explicitly

        All ->
            All

        None ->
            None


definitions : ExposedApi -> List String
definitions api =
    case api of
        Explicitly defs ->
            defs

        All ->
            []

        None ->
            []


isEverythingExposed : ExposedApi -> Bool
isEverythingExposed api =
    case api of
        Explicitly _ ->
            False

        All ->
            True

        None ->
            False
