module VerifyExamples.Warning exposing (Warning, toString, warnings)

import Maybe.Util
import String.Util exposing (unlines)
import VerifyExamples.ExposedApi as ExposedApi exposing (ExposedApi)
import VerifyExamples.Parser as Parser exposing (Parsed)
import VerifyExamples.TestSuite as TestSuite exposing (TestSuite)
import VerifyExamples.Warning.Ignored as Ignored exposing (Ignored)
import VerifyExamples.Warning.Type exposing (Type(..))


type Warning
    = Warning Type (List String)


warnings : List Ignored -> Parsed -> List Warning
warnings ignored { exposedApi, testSuites } =
    [ notEverythingExposed exposedApi
    , Ignored.subset NoExampleForExposedDefinition ignored
        |> noExamples exposedApi testSuites
    ]
        |> Maybe.Util.values
        |> List.filter (notIgnoredWarnings ignored)


noExamples : ExposedApi -> List TestSuite -> List String -> Maybe Warning
noExamples exposedApi testSuites ignoredDefinitions =
    exposedApi
        |> ExposedApi.reject (\x -> List.member x (testedFunctions testSuites))
        |> ExposedApi.reject (\x -> List.member x ignoredDefinitions)
        |> ExposedApi.definitions
        |> Maybe.Util.fromList
        |> Maybe.map (Warning NoExampleForExposedDefinition)


testedFunctions : List TestSuite -> List String
testedFunctions testSuites =
    List.concatMap TestSuite.testedFunctions testSuites


notEverythingExposed : ExposedApi -> Maybe Warning
notEverythingExposed exposedApi =
    if ExposedApi.isEverythingExposed exposedApi then
        Warning ExposingDotDot []
            |> Just
    else
        Nothing


notIgnoredWarnings : List Ignored -> Warning -> Bool
notIgnoredWarnings ignored (Warning type_ _) =
    not (Ignored.all type_ ignored)


toString : Warning -> String
toString (Warning type_ definitions) =
    case type_ of
        NoExampleForExposedDefinition ->
            "The following exposed definitions don't have examples:\n"
                :: List.map ((++) "    - ") definitions
                |> unlines

        ExposingDotDot ->
            [ "It's recommended to be specific about your exports."
            , ""
            , "    Don't use `module ... exposing (..)`"
            , "                                    ^^  "
            ]
                |> unlines
