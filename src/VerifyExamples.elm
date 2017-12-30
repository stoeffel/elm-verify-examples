port module VerifyExamples exposing (..)

import Cmd.Util as Cmd
import Json.Decode as Decode exposing (Value, decodeValue, field, list, string)
import Platform
import VerifyExamples.Compiler as Compiler
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
import VerifyExamples.Parser as Parser


main : Program Value () Msg
main =
    Platform.programWithFlags
        { init = init >> (,) ()
        , update = \msg _ -> ( (), update msg )
        , subscriptions = subscriptions
        }



-- MODEL


init : Value -> Cmd Msg
init flags =
    case decodeValue decoder flags of
        Ok tests ->
            tests
                |> List.map (ReadTest >> Cmd.perform)
                |> Cmd.batch

        Err err ->
            Debug.crash err


decoder : Decode.Decoder (List String)
decoder =
    field "tests" (list string)



-- UPDATE


type Msg
    = ReadTest String
    | CompileModule ( ModuleName, String )


update : Msg -> Cmd Msg
update msg =
    case msg of
        ReadTest test ->
            readFile test

        CompileModule ( moduleName, fileText ) ->
            generateTests moduleName fileText
                |> List.map (Tuple.mapFirst ModuleName.toString)
                |> writeFiles


generateTests : ModuleName -> String -> List ( ModuleName, String )
generateTests moduleName =
    Parser.parse >> List.concatMap (Compiler.compile moduleName)



-- PORTS


port readFile : String -> Cmd msg


port writeFiles : List ( String, String ) -> Cmd msg


port generateModuleVerifyExamples : (( String, String ) -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : () -> Sub Msg
subscriptions _ =
    generateModuleVerifyExamples
        (CompileModule << Tuple.mapFirst ModuleName.fromString)
