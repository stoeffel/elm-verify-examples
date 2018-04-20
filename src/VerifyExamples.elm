port module VerifyExamples exposing (..)

import Cmd.Util as Cmd
import Json.Decode as Decode exposing (Decoder, Value, decodeValue, field, list, string)
import Platform
import VerifyExamples.Compiler as Compiler
import VerifyExamples.Elm as Elm
import VerifyExamples.Encoder as Encoder
import VerifyExamples.Markdown as Markdown
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
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
    | CompileMarkdown MarkdownCompileInfo


update : Msg -> Cmd Msg
update msg =
    case msg of
        ReadTest test ->
            readFile test

        CompileModule info ->
            let
                parsed =
                    Elm.parse info.fileText
            in
            Cmd.batch
                [ parsed
                    |> testFiles info
                    |> generateTests
                , parsed
                    |> reportWarnings info
                ]

        CompileMarkdown info ->
            info.fileText
                |> Markdown.parse
                |> testFilesFromMarkdown info
                |> generateTests


generateTests : List ( ModuleName, String ) -> Cmd Msg
generateTests tests =
    tests
        |> Encoder.files
        |> writeFiles


testFiles : CompileInfo -> Elm.Parsed -> List ( ModuleName, String )
testFiles { moduleName, fileText, ignoredWarnings } parsed =
    case parsed.testSuites of
        [] ->
            [ Compiler.todoSpec moduleName ]

        _ ->
            List.concatMap
                (Elm.compile moduleName)
                parsed.testSuites


reportWarnings : CompileInfo -> Elm.Parsed -> Cmd msg
reportWarnings { moduleName, ignoredWarnings } parsed =
    parsed
        |> Warning.warnings ignoredWarnings
        |> Encoder.warnings moduleName
        |> warn


testFilesFromMarkdown : MarkdownCompileInfo -> Markdown.Parsed -> List ( ModuleName, String )
testFilesFromMarkdown { fileName, fileText, ignoredWarnings } parsed =
    List.concatMap (Markdown.compile fileName) parsed.testSuites



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
            (runDecoder decodeMarkdownCompileInfo >> CompileMarkdown)
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



{- TODO: Maybe this is better...

   type CompileInfo =
     { source: Source
     , fileText: String
     , ignoredWarnings: List Ignored
     }

   type Source
     = Elm String
     = Markdown String

-}


type alias MarkdownCompileInfo =
    { fileName : String
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


decodeMarkdownCompileInfo : Decoder MarkdownCompileInfo
decodeMarkdownCompileInfo =
    Decode.map3 MarkdownCompileInfo
        (field "fileName" string)
        (field "fileText" string)
        (field "ignoredWarnings" Ignored.decode)
