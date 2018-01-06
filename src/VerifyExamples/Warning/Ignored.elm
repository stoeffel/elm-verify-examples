module VerifyExamples.Warning.Ignored exposing (Ignored, decode, only)

import Json.Decode exposing (Decoder, field, list, map, map2, oneOf, string)
import Json.Util exposing (exact)
import VerifyExamples.Warning.Type exposing (Type(..))


type alias Ignored =
    { name : String
    , ignore : List Type
    }


decode : Decoder (List Ignored)
decode =
    list ignoredWarnings


ignoredWarnings : Decoder Ignored
ignoredWarnings =
    map2 Ignored
        (field "name" string)
        (field "ignore" (list warning))


warning : Decoder Type
warning =
    oneOf
        [ exact string "NoExampleForExposedDefinition"
            |> map (always NoExampleForExposedDefinition)
        ]


only : Type -> List Ignored -> List String
only warning =
    List.filter (.ignore >> List.member warning)
        >> List.map .name
