module VerifyExamples.ExposedApi
    exposing
        ( ExposedApi
        , definitions
        , isEverythingExposed
        , parse
        , reject
        )

import Regex exposing (HowMany(..), Regex)
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

        definitions ->
            definitions
                |> String.split ","
                |> List.map (replaceAllWith typeConstructors "" << String.trim)
                |> Explicitly


typeConstructors : Regex
typeConstructors =
    Regex.regex "\\([^]*?\\)"


moduleExposing : Regex
moduleExposing =
    Regex.regex <|
        String.concat
            [ "module"
            , "[^]*?exposing"
            , "[^]*?\\("
            , "([^]*?)(\\)\\nimport|\\)\\n\\n)"
            ]


reject : (String -> Bool) -> ExposedApi -> ExposedApi
reject f api =
    case api of
        Explicitly definitions ->
            List.filter (\def -> not (f def)) definitions
                |> Explicitly

        All ->
            All

        None ->
            None


definitions : ExposedApi -> List String
definitions api =
    case api of
        Explicitly definitions ->
            definitions

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
