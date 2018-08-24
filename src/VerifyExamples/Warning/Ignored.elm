module VerifyExamples.Warning.Ignored exposing (Ignored, all, decode, subset)

import Json.Decode exposing (Decoder, field, list, map, map2, maybe, oneOf, string)
import Json.Util exposing (exact)
import VerifyExamples.Warning.Type exposing (Type(..))


type alias Ignored =
    { name : Maybe String
    , ignore : List Type
    }


decode : Decoder (List Ignored)
decode =
    list ignoredWarnings


ignoredWarnings : Decoder Ignored
ignoredWarnings =
    map2 Ignored
        (maybe (field "name" string))
        (field "ignore" (list warningDecoder))


warningDecoder : Decoder Type
warningDecoder =
    oneOf
        [ exact string "NoExampleForExposedDefinition"
            |> map (always NoExampleForExposedDefinition)
        , exact string "ExposingDotDot"
            |> map (always ExposingDotDot)
        ]


subset : Type -> List Ignored -> List String
subset warning ignores =
    ignores
        |> List.filter (\{ ignore } -> List.member warning ignore)
        |> List.filterMap (\ignored -> ignored.name)


all : Type -> List Ignored -> Bool
all warning ignores =
    case
        ignores
            |> List.filter (\{ ignore } -> List.member warning ignore)
            |> List.filter (\ignored -> ignored.name == Nothing)
    of
        [] ->
            False

        _ ->
            True
