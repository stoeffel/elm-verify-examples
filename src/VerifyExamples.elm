port module VerifyExamples exposing (..)

import Cmd.Util as Cmd
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, list, string)
import Platform
import VerifyExamples.Compiler as Compiler
import VerifyExamples.Encoder as Encoder
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
import VerifyExamples.Parser as Parser exposing (Parsed)
import VerifyExamples.Warning as Warning exposing (Warning)
import VerifyExamples.Warning.Ignored as Ignored exposing (Ignored)


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


decoder : Decoder (List String)
decoder =
    field "tests" (list string)



-- UPDATE


type Msg
    = ReadTest String
    | CompileModule CompileInfo
    | CompileMarkdown ()


update : Msg -> Cmd Msg
update msg =
    case msg of
        ReadTest test ->
            readFile test

        CompileModule info ->
            let
                parsed =
                    Parser.parse info.fileText
            in
            Cmd.batch
                [ parsed
                    |> testFiles info
                    |> generateTests
                , parsed
                    |> reportWarnings info
                ]

        CompileMarkdown info ->
            Cmd.none


generateTests : List ( ModuleName, String ) -> Cmd Msg
generateTests tests =
    tests
        |> Encoder.files
        |> writeFiles


testFiles : CompileInfo -> Parsed -> List ( ModuleName, String )
testFiles { moduleName, fileText, ignoredWarnings } parsed =
    let
        toGenerate =
            List.concatMap (Compiler.compile moduleName) parsed.testSuites
    in
    case toGenerate of
        [] ->
            [ Compiler.todoSpec moduleName ]

        _ ->
            toGenerate


reportWarnings : CompileInfo -> Parsed -> Cmd msg
reportWarnings { moduleName, ignoredWarnings } parsed =
    parsed
        |> Warning.warnings ignoredWarnings
        |> Encoder.warnings moduleName
        |> warn



-- PORTS


port readFile : String -> Cmd msg


port writeFiles : Value -> Cmd msg


port generateModuleVerifyExamples : (Value -> msg) -> Sub msg


port generateMarkdownVerifyExamples : (Value -> msg) -> Sub msg


port warn : Value -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : () -> Sub Msg
subscriptions _ =
    Sub.batch
        [ generateModuleVerifyExamples
            (runDecoder decodeCompileInfo >> CompileModule)
        , generateMarkdownVerifyExamples
            (runDecoder (Decode.succeed ()) >> CompileMarkdown)
        ]


runDecoder : Decoder a -> Value -> a
runDecoder decoder value =
    case decodeValue decoder value of
        Ok info ->
            info

        Err err ->
            Debug.crash "TODO"


type alias CompileInfo =
    { moduleName : ModuleName
    , fileText : String
    , ignoredWarnings : List Ignored
    }


decodeCompileInfo : Decoder CompileInfo
decodeCompileInfo =
    Decode.map3 CompileInfo
        (field "moduleName" string
            |> Decode.map ModuleName.fromString
        )
        (field "fileText" string)
        (field "ignoredWarnings" Ignored.decode)
