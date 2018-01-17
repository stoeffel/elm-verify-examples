module VerifyExamples.Warning exposing (Warning, toString, warnings)

import Maybe.Extra
import Maybe.Util
import String.Util exposing (unlines)
import VerifyExamples.ExposedApi as ExposedApi exposing (ExposedApi)
import VerifyExamples.Parser as Parser exposing (Parsed)
import VerifyExamples.TestSuite as TestSuite exposing (TestSuite)
import VerifyExamples.Warning.Ignored as Ignored exposing (Ignored, IgnoredFunctions)
import VerifyExamples.Warning.Type exposing (Type(..))


type Warning
    = Warning WarningData


type alias WarningData =
    { type_ : Type
    , definitions : List String
    }


warnings : List Ignored -> Parsed -> List Warning
warnings ignored { exposedApi, testSuites } =
    Maybe.Extra.values
        [ noExamples ignored exposedApi testSuites
        , notEverythingExposed ignored exposedApi
        ]


noExamples : List Ignored -> ExposedApi -> List TestSuite -> Maybe Warning
noExamples ignored exposedApi testSuites =
    case Ignored.isIgnored NoExampleForExposedDefinition ignored of
        Ignored.All ->
            Nothing

        Ignored.Subset ignores ->
            exposedApi
                |> ExposedApi.reject (flip List.member (testedFunctions testSuites))
                |> ExposedApi.reject (flip List.member ignores)
                |> ExposedApi.definitions
                |> Maybe.Util.fromList
                |> Maybe.map (WarningData NoExampleForExposedDefinition)
                |> Maybe.map Warning


testedFunctions : List TestSuite -> List String
testedFunctions testSuites =
    List.concatMap TestSuite.testedFunctions testSuites


notEverythingExposed : List Ignored -> ExposedApi -> Maybe Warning
notEverythingExposed ignored exposedApi =
    case Ignored.isIgnored NoExampleForExposedDefinition ignored of
        Ignored.All ->
            Nothing

        Ignored.Subset ignores ->
            if ExposedApi.everythingExposed exposedApi then
                WarningData NotEverythingExposed []
                    |> Warning
                    |> Just
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
