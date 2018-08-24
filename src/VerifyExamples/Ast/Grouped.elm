module VerifyExamples.Ast.Grouped
    exposing
        ( Example
        , Function(..)
        , FunctionInfo
        , GroupedAst
        , Import
        , Type
        , fromAst
        , functionInfo
        , importToString
        , typeToString
        )

import VerifyExamples.Ast as Ast exposing (Ast)


type alias GroupedAst =
    { functions : List Function
    , imports : List Import
    , types : List Type
    , examples : List Example
    }


type alias Example =
    { assertion : String, expectation : String }


type Function
    = Function FunctionInfo


type alias FunctionInfo =
    { name : String, function : String }


type Import
    = Import String


type Type
    = Type String


importToString : Import -> String
importToString (Import import_) =
    import_


typeToString : Type -> String
typeToString (Type type_) =
    type_


functionInfo : Function -> FunctionInfo
functionInfo (Function info) =
    info


fromAst : List Ast -> GroupedAst
fromAst ast =
    group ast empty


group : List Ast -> GroupedAst -> GroupedAst
group ast acc =
    case ast of
        [] ->
            acc

        (Ast.Assertion assertion) :: (Ast.Expectation expectation) :: rest ->
            { assertion = assertion, expectation = expectation }
                :: acc.examples
                |> (\x -> setExamples x acc)
                |> group rest

        (Ast.Assertion assertion) :: rest ->
            group rest acc

        (Ast.Expectation str) :: rest ->
            group rest acc

        (Ast.Import str) :: rest ->
            Import str
                :: acc.imports
                |> (\x -> setImports x acc)
                |> group rest

        (Ast.Type str) :: rest ->
            Type str
                :: acc.types
                |> (\x -> setTypes x acc)
                |> group rest

        (Ast.Function name str) :: rest ->
            Function { name = name, function = str }
                :: acc.functions
                |> (\x -> setFunctions x acc)
                |> group rest


empty : GroupedAst
empty =
    { functions = []
    , imports = []
    , types = []
    , examples = []
    }


setExamples : List Example -> GroupedAst -> GroupedAst
setExamples examples groupped =
    { groupped | examples = examples }


setImports : List Import -> GroupedAst -> GroupedAst
setImports imports groupped =
    { groupped | imports = imports }


setTypes : List Type -> GroupedAst -> GroupedAst
setTypes types groupped =
    { groupped | types = types }


setFunctions : List Function -> GroupedAst -> GroupedAst
setFunctions functions groupped =
    { groupped | functions = functions }
