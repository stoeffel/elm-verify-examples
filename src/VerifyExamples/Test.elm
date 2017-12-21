module VerifyExamples.Test exposing (Test, fromExamples)

import VerifyExamples.Ast as Ast


type alias Test =
    { assertion : String
    , expectation : String
    , functionToTest : Maybe String
    }


fromExamples : Maybe String -> List Ast.Example -> List Test
fromExamples functionToTest =
    List.map
        (\{ assertion, expectation } ->
            { assertion = assertion
            , expectation = expectation
            , functionToTest = functionToTest
            }
        )
