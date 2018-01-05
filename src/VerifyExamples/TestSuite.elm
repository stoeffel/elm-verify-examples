module VerifyExamples.TestSuite exposing (TestSuite, fromAst, group, notSpecial, testedFunctions)

import List.Extra exposing (unique)
import VerifyExamples.Function as Function exposing (Function)
import VerifyExamples.GroupedAst as GroupedAst exposing (GroupedAst)
import VerifyExamples.Test as Test exposing (Test)


type alias TestSuite =
    { imports : List String
    , types : List String
    , tests : List Test
    , helperFunctions : List Function
    }


fromAst : Maybe String -> GroupedAst -> TestSuite
fromAst fnName { imports, types, functions, examples } =
    { imports = List.map GroupedAst.importToString imports
    , types = List.map GroupedAst.typeToString types
    , tests = Test.fromExamples fnName examples
    , helperFunctions = Function.toFunctions examples functions
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


testedFunctions : TestSuite -> List String
testedFunctions =
    .tests
        >> List.filterMap Test.functionName
        >> unique
