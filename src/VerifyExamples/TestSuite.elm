module VerifyExamples.TestSuite exposing (TestSuite, fromAst, group, notSpecial)

import VerifyExamples.Ast as Ast exposing (Ast)
import VerifyExamples.Function as Function exposing (Function)
import VerifyExamples.Test as Test exposing (Test)


type alias TestSuite =
    { imports : List String
    , types : List String
    , tests : List Test
    , helperFunctions : List Function
    }


fromAst : Maybe String -> List Ast -> TestSuite
fromAst fnName ast =
    let
        { imports, types, functions, examples } =
            Ast.group ast

        tests =
            Test.fromExamples fnName examples
    in
    { imports = List.map Ast.toString imports
    , types = List.map Ast.toString types
    , tests = tests
    , helperFunctions =
        functions
            |> List.filterMap (Function.fromAst tests)
            |> Function.onlyUsed
    }


group : List TestSuite -> List TestSuite
group suites =
    let
        ( rest, isSpecial ) =
            List.partition notSpecial suites
    in
    List.foldr concat empty rest
        :: isSpecial


concat : TestSuite -> TestSuite -> TestSuite
concat suite acc =
    { imports = suite.imports ++ acc.imports
    , types = suite.types ++ acc.types
    , tests = suite.tests ++ acc.tests
    , helperFunctions = suite.helperFunctions ++ acc.helperFunctions
    }


empty : TestSuite
empty =
    { imports = []
    , types = []
    , tests = []
    , helperFunctions = []
    }


notSpecial : TestSuite -> Bool
notSpecial { types, helperFunctions } =
    List.isEmpty types && List.isEmpty helperFunctions
