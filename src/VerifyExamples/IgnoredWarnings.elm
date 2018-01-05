module VerifyExamples.IgnoredWarnings exposing (IgnoredWarnings, decode, only)

import Json.Decode exposing (Decoder, field, list, map, map2, oneOf, string)
import Json.Util exposing (exact)
import VerifyExamples.Warning as Warning exposing (Warning(..))


type alias IgnoredWarnings =
    { name : String
    , ignore : List Warning
    }


decode : Decoder (List IgnoredWarnings)
decode =
    list ignoredWarnings


ignoredWarnings : Decoder IgnoredWarnings
ignoredWarnings =
    map2 IgnoredWarnings
        (field "name" string)
        (field "ignore" (list warning))


warning : Decoder Warning
warning =
    oneOf
        [ exact string "NoExampleForExposedDefinition"
            |> map (always NoExampleForExposedDefinition)
        ]


only : Warning -> List IgnoredWarnings -> List String
only warning =
    List.filter (.ignore >> List.member warning)
        >> List.map .name
