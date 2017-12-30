port module VerifyExamples exposing (..)

import Json.Decode as Decode exposing (Value, decodeValue, field, list, string)
import Platform
import Task
import VerifyExamples.Compiler as Compiler
import VerifyExamples.ModuleName as ModuleName
import VerifyExamples.Parser as Parser


main : Program Value Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { root : String
    , tests : List String
    }


init : Value -> ( Model, Cmd Msg )
init flags =
    case decodeValue decoder flags of
        Ok model ->
            model ! List.map (message << ReadTest) model.tests

        Err err ->
            Debug.crash err


decoder : Decode.Decoder Model
decoder =
    Decode.map2 Model
        (field "root" string)
        (field "tests" (list string))



-- UPDATE


type Msg
    = ReadTest String
    | CompileModule ( String, String )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReadTest test ->
            model ! [ readFile test ]

        CompileModule ( moduleName, fileText ) ->
            let
                generatedTests =
                    Parser.parse fileText
                        |> List.concatMap (Compiler.compile <| ModuleName.fromString moduleName)
                        |> List.map (Tuple.mapFirst ModuleName.toString)
            in
            ( model
            , writeFiles generatedTests
            )



-- PORTS


port readFile : String -> Cmd msg


port writeFiles : List ( String, String ) -> Cmd msg


port generateModuleVerifyExamples : (( String, String ) -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    generateModuleVerifyExamples CompileModule



-- UTILS


message : msg -> Cmd msg
message x =
    Task.perform (\_ -> x) (Task.succeed ())
