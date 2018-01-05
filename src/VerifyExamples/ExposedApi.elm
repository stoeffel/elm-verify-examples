module VerifyExamples.ExposedApi
    exposing
        ( ExposedApi
        , definitions
        , filter
        , parse
        )

import Regex exposing (HowMany(..), Regex)
import Regex.Util exposing (firstSubmatch, newline)


type ExposedApi
    = Explicitly (List String)
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
            Explicitly functions

        definitions ->
            definitions
                |> String.split ","
                |> List.map String.trim
                |> Explicitly


moduleExposing : Regex
moduleExposing =
    Regex.regex <|
        String.concat
            [ "module"
            , "[^]*?exposing"
            , "[^]*?\\("
            , "([^]*?)\\)"
            ]


filter : (String -> Bool) -> ExposedApi -> ExposedApi
filter f api =
    case api of
        Explicitly definitions ->
            List.filter f definitions
                |> Explicitly

        None ->
            None


definitions : ExposedApi -> List String
definitions api =
    case api of
        Explicitly definitions ->
            definitions

        None ->
            []
