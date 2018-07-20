module VerifyExamples.Test
    exposing
        ( Test
        , exampleDescription
        , fromExamples
        , functionName
        , specBody
        )

import String.Util exposing (unlines)
import VerifyExamples.Ast.Grouped as GroupedAst


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


functionName : Test -> Maybe String
functionName (Test { functionToTest }) =
    functionToTest


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
