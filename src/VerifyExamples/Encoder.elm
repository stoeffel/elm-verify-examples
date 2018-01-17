module VerifyExamples.Encoder exposing (files, moduleName, warnings)

import Json.Decode exposing (Value)
import Json.Encode as Encode
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
import VerifyExamples.Warning as Warning exposing (Warning)


files : List ( ModuleName, String ) -> Value
files modules =
    List.map encodeFile modules
        |> Encode.list


encodeFile : ( ModuleName, String ) -> Value
encodeFile ( name, content ) =
    Encode.object
        [ ( "moduleName", moduleName name )
        , ( "content", Encode.string content )
        ]


warnings : ModuleName -> List Warning -> Value
warnings name warnings =
    Encode.object
        [ ( "moduleName", moduleName name )
        , ( "warnings"
          , warnings
                |> List.map encodeWarning
                |> Encode.list
          )
        ]


moduleName : ModuleName -> Value
moduleName name =
    name
        |> ModuleName.toString
        |> Encode.string


encodeWarning : Warning -> Value
encodeWarning warning =
    warning
        |> Warning.toString
        |> Encode.string
