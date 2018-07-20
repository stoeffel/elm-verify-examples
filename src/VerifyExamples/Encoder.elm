module VerifyExamples.Encoder exposing (files, moduleName, warnings)

import Json.Decode exposing (Value)
import Json.Encode as Encode
import VerifyExamples.Compiler as Compiler
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
import VerifyExamples.Warning as Warning exposing (Warning)


files : List Compiler.Result -> Value
files modules =
    List.map encodeFile modules
        |> Encode.list


encodeFile : Compiler.Result -> Value
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
