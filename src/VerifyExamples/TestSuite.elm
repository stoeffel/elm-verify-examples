module VerifyExamples.TestSuite exposing (TestSuite, fromAst)

import VerifyExamples.Ast as Ast exposing (Ast)
import VerifyExamples.Function as Function exposing (Function)
import VerifyExamples.Test as Test exposing (Test)


type alias TestSuite =
    { imports : List String
    , types : List String
    , tests : List Test
    , functionToTest : Maybe String
    , helperFunctions : List Function
    }


fromAst : String -> List Ast -> TestSuite
fromAst fnName ast =
    let
        tests =
            Test.testsFromAst ast
    in
    { imports =
        List.filter Ast.isImport ast
            |> List.map Ast.toString
    , types =
        List.filter Ast.isType ast
            |> List.map Ast.toString
    , tests = tests
    , functionToTest = Just fnName
    , helperFunctions =
        ast
            |> List.filter Ast.isLocalFunction
            |> List.filterMap (Function.fromAst tests)
            |> Function.onlyUsed
    }
