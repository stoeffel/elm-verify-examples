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
        groupped =
            Ast.group ast

        tests =
            Test.testsFromAst ast
    in
    { imports = List.map Ast.toString groupped.imports
    , types = List.map Ast.toString groupped.types
    , tests = tests
    , functionToTest = Just fnName
    , helperFunctions =
        groupped.localFunctions
            |> List.filterMap (Function.fromAst tests)
            |> Function.onlyUsed
    }


group : List TestSuite -> List TestSuite
group suites =
    let
        ( rest, isSpecial ) =
            List.partition notSpecial suites
    in
    List.foldr combine empty rest
        :: isSpecial


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


notSpecial : TestSuite -> Bool
notSpecial { types, helperFunctions } =
    List.isEmpty types && List.isEmpty helperFunctions
