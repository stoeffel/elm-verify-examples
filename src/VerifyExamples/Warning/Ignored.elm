module VerifyExamples.Warning.Ignored exposing (Ignored, IgnoredFunctions(..), decode, only)

import Json.Decode exposing (Decoder, field, list, map, map2, maybe, oneOf, string)
import Json.Util exposing (exact)
import Maybe.Extra
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
        (field "ignore" (list warning))


warning : Decoder Type
warning =
    oneOf
        [ exact string "NoExampleForExposedDefinition"
            |> map (always NoExampleForExposedDefinition)
        , exact string "NotEverythingExposed"
            |> map (always NotEverythingExposed)
        ]


type IgnoredFunctions
    = All
    | Subset (List String)


only : Type -> List Ignored -> IgnoredFunctions
only warning =
    List.filter (.ignore >> List.member warning)
        >> List.map .name
        >> Maybe.Extra.combine
        >> Maybe.map Subset
        >> Maybe.withDefault All
