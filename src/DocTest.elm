port module DocTest exposing (..)

import DocTest.Compiler as Compiler
import DocTest.Parser as Parser
import Json.Decode as Decode exposing (decodeValue, field, string, list, Value)
import Platform
import Task


main : Program Value Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    List Test


type alias Test =
    { name : String, path : String }


init : Value -> ( Model, Cmd Msg )
init flags =
    case decodeValue decoder flags of
        Ok model ->
            model ! List.map (message << ReadTest) model

        Err err ->
            Debug.crash err


decoder : Decode.Decoder Model
decoder =
    list decodeTest


decodeTest : Decode.Decoder Test
decodeTest =
    Decode.map2 Test
        (field "name" string)
        (field "path" string)



-- UPDATE


type Msg
    = ReadTest Test
    | CompileModule ( String, String )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReadTest test ->
            model ! [ readFile ( test.name, test.path ) ]

        CompileModule ( moduleName, fileText ) ->
            let
                generatedTestFileText =
                    Parser.parse fileText
                        |> Compiler.compile moduleName
            in
                model ! [ writeFile ( moduleName, generatedTestFileText ) ]



-- PORTS


port readFile : ( String, String ) -> Cmd msg


port writeFile : ( String, String ) -> Cmd msg


port generateModuleDoctest : (( String, String ) -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    generateModuleDoctest CompileModule



-- UTILS


message : msg -> Cmd msg
message x =
    Task.perform (\_ -> x) (Task.succeed ())
