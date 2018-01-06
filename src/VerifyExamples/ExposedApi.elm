module VerifyExamples.ExposedApi
    exposing
        ( ExposedApi
        , definitions
        , everythingExposed
        , filter
        , parse
        )

import Regex exposing (HowMany(..), Regex)
import Regex.Util exposing (firstSubmatch, newline, replaceAllWith)


type ExposedApi
    = Explicitly (List String)
    | All
    | None


parse : String -> List String -> ExposedApi
parse value functions =
    value
        |> firstSubmatch moduleExposing
        |> Maybe.map (toExposedDefinition functions)
        |> Maybe.withDefault None


toExposedDefinition : List String -> String -> ExposedApi
toExposedDefinition functions match =
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


filter : (String -> Bool) -> ExposedApi -> ExposedApi
filter f api =
    case api of
        Explicitly definitions ->
            List.filter f definitions
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


everythingExposed : ExposedApi -> Bool
everythingExposed api =
    case api of
        Explicitly _ ->
            False

        All ->
            True

        None ->
            False
