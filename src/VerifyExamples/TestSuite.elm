module VerifyExamples.TestSuite exposing (TestSuite, fromAst, group)

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


group : List TestSuite -> List TestSuite
group suites =
    let
        ( hasTypes, rest ) =
            List.partition hasTypesOrDefs suites
    in
    List.foldr combine empty rest :: hasTypes


combine : TestSuite -> TestSuite -> TestSuite
combine suite acc =
    { imports = suite.imports ++ acc.imports
    , types = suite.types ++ acc.types
    , tests = suite.tests ++ acc.tests
    , functionToTest = suite.functionToTest
    , helperFunctions = suite.helperFunctions ++ acc.helperFunctions
    }


empty : TestSuite
empty =
    { imports = []
    , types = []
    , tests = []
    , functionToTest = Nothing
    , helperFunctions = []
    }


hasTypesOrDefs : TestSuite -> Bool
hasTypesOrDefs { types, helperFunctions } =
    not (List.isEmpty types) || not (List.isEmpty helperFunctions)
