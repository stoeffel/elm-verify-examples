module VerifyExamples.Warning exposing (Warning, toString, warnings)

import Maybe.Util
import String.Util exposing (unlines)
import VerifyExamples.ExposedApi as ExposedApi exposing (ExposedApi)
import VerifyExamples.Parser as Parser exposing (Parsed)
import VerifyExamples.TestSuite as TestSuite exposing (TestSuite)
import VerifyExamples.Warning.Ignored as Ignored exposing (Ignored, IgnoredFunctions)
import VerifyExamples.Warning.Type exposing (Type(..))


type Warning
    = Warning { type_ : Type, definitions : List String }


warnings : List Ignored -> Parsed -> List Warning
warnings ignores parsed =
    List.concatMap (gatherWarningsFor ignores parsed)
        [ ( NoExampleForExposedDefinition, noExamples )
        , ( NotEverythingExposed, notEverythingExposed )
        ]


type alias HasWarning =
    Parsed -> List String -> Maybe (List String)


gatherWarningsFor : List Ignored -> Parsed -> ( Type, HasWarning ) -> List Warning
gatherWarningsFor ignored parsed ( type_, f ) =
    case Ignored.only type_ ignored of
        Ignored.All ->
            []

        Ignored.Subset ignores ->
            case f parsed ignores of
                Just definitions ->
                    [ Warning { type_ = type_, definitions = definitions } ]

                Nothing ->
                    []


noExamples : HasWarning
noExamples { exposedApi, testSuites } ignores =
    exposedApi
        |> ExposedApi.filter
            (\definition ->
                not (List.member definition (List.concatMap TestSuite.testedFunctions testSuites))
                    && not (List.member definition ignores)
            )
        |> ExposedApi.definitions
        |> Maybe.Util.fromList


notEverythingExposed : HasWarning
notEverythingExposed { exposedApi } _ =
    if ExposedApi.everythingExposed exposedApi then
        Just []
    else
        Nothing


toString : Warning -> String
toString (Warning { type_, definitions }) =
    case type_ of
        NoExampleForExposedDefinition ->
            "The following exposed definitions don't have examples:\n"
                :: List.map ((++) "    - ") definitions
                |> unlines

        NotEverythingExposed ->
            "It's recommended to be specific about your exports.\n"
                :: [ "    Don't use `module ... exposing (..)`"
                   , "                                    ^^  "
                   ]
                |> unlines
