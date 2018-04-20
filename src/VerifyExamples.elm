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
    | CompileModule ElmSource
    | CompileMarkdown MarkdownSource


update : Msg -> Cmd Msg
update msg =
    case msg of
        ReadTest test ->
            readFile test

        CompileModule source ->
            source.fileText
                |> Elm.parse
                |> compileElm source
                |> (\( warnings, tests ) ->
                        Cmd.batch
                            [ generateTests tests
                            , reportWarnings source.moduleName warnings
                            ]
                   )

        CompileMarkdown source ->
            source.fileText
                |> Markdown.parse
                |> compileMarkdown source
                |> generateTests


generateTests : List ( ModuleName, String ) -> Cmd Msg
generateTests tests =
    tests
        |> Encoder.files
        |> writeFiles


compileElm : ElmSource -> Elm.Parsed -> ( List Warning, List ( ModuleName, String ) )
compileElm { moduleName, fileText, ignoredWarnings } parsed =
    case parsed.testSuites of
        [] ->
            ( []
            , [ Compiler.todoSpec moduleName ]
            )

        _ ->
            ( Warning.warnings ignoredWarnings parsed
            , List.concatMap
                (Elm.compile moduleName)
                parsed.testSuites
            )


reportWarnings : ModuleName -> List Warning -> Cmd msg
reportWarnings moduleName warnings =
    warnings
        |> Encoder.warnings moduleName
        |> warn


compileMarkdown : MarkdownSource -> Markdown.Parsed -> List ( ModuleName, String )
compileMarkdown { fileName } parsed =
    List.concatMap
        (Markdown.compile fileName)
        parsed.testSuites



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
            (runDecoder decodeElmSource >> CompileModule)
        , generateMarkdownVerifyExamples
            (runDecoder decodeMarkdownSource >> CompileMarkdown)
        ]


runDecoder : Decoder a -> Value -> a
runDecoder decoder value =
    case decodeValue decoder value of
        Ok info ->
            info

        Err err ->
            Debug.crash "TODO"


type alias ElmSource =
    { moduleName : ModuleName
    , fileText : String
    , ignoredWarnings : List Ignored
    }


type alias MarkdownSource =
    { fileName : String
    , fileText : String
    }


decodeElmSource : Decoder ElmSource
decodeElmSource =
    Decode.map3 ElmSource
        (field "moduleName" string
            |> Decode.map ModuleName.fromString
        )
        (field "fileText" string)
        (field "ignoredWarnings" Ignored.decode)


decodeMarkdownSource : Decoder MarkdownSource
decodeMarkdownSource =
    Decode.map2 MarkdownSource
        (field "fileName" string)
        (field "fileText" string)
