module VerifyExamples.Test exposing (Test, testsFromAst)

import VerifyExamples.Ast as Ast exposing (Ast)


type alias Test =
    { assertion : String
    , expectation : String
    , functionToTest : Maybe String
    }


testsFromAst : Maybe String -> List Ast -> List Test
testsFromAst functionToTest =
    List.filter Ast.isTest
        >> toTests functionToTest []
        >> List.reverse


toTests : Maybe String -> List Test -> List Ast -> List Test
toTests functionToTest acc xs =
    case xs of
        (Ast.Assertion x) :: (Ast.Expectation y) :: rest ->
            toTests functionToTest
                ({ assertion = x
                 , expectation = y
                 , functionToTest = functionToTest
                 }
                    :: acc
                )
                rest

        -- drop items until a valid sequence of items is found
        _ :: rest ->
            toTests functionToTest acc rest

        [] ->
            acc
