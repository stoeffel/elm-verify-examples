module VerifyExamples.Test
    exposing
        ( Test
        , exampleDescription
        , fromExamples
        , name
        , specBody
        , specName
        )

import String.Util exposing (unlines)
import VerifyExamples.GroupedAst as GroupedAst


type Test
    = Test
        { assertion : String
        , expectation : String
        , functionToTest : Maybe String
        }


fromExamples : Maybe String -> List GroupedAst.Example -> List Test
fromExamples functionToTest =
    List.map
        (\{ assertion, expectation } ->
            Test
                { assertion = assertion
                , expectation = expectation
                , functionToTest = functionToTest
                }
        )


specName : Int -> Test -> String
specName index (Test { functionToTest }) =
    case functionToTest of
        Just name ->
            name ++ toString index

        Nothing ->
            "ModuleDoc" ++ toString index


name : Test -> String
name (Test { functionToTest }) =
    case functionToTest of
        Just name ->
            "#" ++ name

        Nothing ->
            "Module VerifyExamples"


exampleDescription : Test -> String
exampleDescription (Test { assertion, expectation }) =
    unlines
        [ assertion
        , expectation
            |> String.lines
            |> List.map prefixArrow
            |> unlines
        ]


prefixArrow : String -> String
prefixArrow =
    (++) "--> "


specBody : Test -> String
specBody (Test { assertion, expectation }) =
    unlines
        [ "("
        , assertion
        , ")"
        , "("
        , expectation
        , ")"
        ]
