module VerifyExamples.Test exposing (Test, testsFromAst)

import VerifyExamples.Ast as Ast exposing (Ast)


type alias Test =
    { assertion : String
    , expectation : String
    }


testsFromAst : List Ast -> List Test
testsFromAst ast =
    ast
        |> List.filter (\a -> Ast.isAssertion a || Ast.isExpectiation a)
        |> toTests []
        |> List.reverse


toTests : List Test -> List Ast -> List Test
toTests acc xs =
    case xs of
        (Ast.Assertion x) :: (Ast.Expectation y) :: rest ->
            toTests
                ({ assertion = x
                 , expectation = y
                 }
                    :: acc
                )
                rest

        -- drop items until a valid sequence of items is found
        _ :: rest ->
            toTests acc rest

        [] ->
            acc
