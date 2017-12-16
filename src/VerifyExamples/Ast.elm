module VerifyExamples.Ast
    exposing
        ( Ast(..)
        , fromIntermediateAst
        , group
        , isTest
        , toString
        )

import VerifyExamples.IntermediateAst as IAst exposing (IntermediateAst)


type Ast
    = Assertion String
    | Expectation String
    | Import String
    | LocalFunction String String
    | Type String


isTest : Ast -> Bool
isTest x =
    case x of
        Assertion _ ->
            True

        Expectation _ ->
            True

        Import _ ->
            False

        LocalFunction _ _ ->
            False

        Type _ ->
            False


isExpectiation : Ast -> Bool
isExpectiation x =
    case x of
        Expectation _ ->
            True

        _ ->
            False


group : List Ast -> { localFunctions : List Ast, imports : List Ast, types : List Ast }
group ast =
    groupHelp ast { localFunctions = [], imports = [], types = [] }


groupHelp :
    List Ast
    -> { localFunctions : List Ast, imports : List Ast, types : List Ast }
    -> { localFunctions : List Ast, imports : List Ast, types : List Ast }
groupHelp ast acc =
    case ast of
        [] ->
            acc

        (Assertion _) :: rest ->
            groupHelp rest acc

        (Expectation str) :: rest ->
            groupHelp rest acc

        (Import str) :: rest ->
            groupHelp rest { acc | imports = acc.imports ++ [ Import str ] }

        (Type str) :: rest ->
            groupHelp rest { acc | types = acc.types ++ [ Type str ] }

        (LocalFunction name str) :: rest ->
            groupHelp rest { acc | localFunctions = acc.localFunctions ++ [ LocalFunction name str ] }


toString : Ast -> String
toString ast =
    case ast of
        Assertion str ->
            str

        Expectation str ->
            str

        Import str ->
            str

        Type str ->
            str

        LocalFunction _ str ->
            str


fromIntermediateAst : List IntermediateAst -> List Ast
fromIntermediateAst =
    List.filterMap groupToAst << IAst.group


groupToAst : List IntermediateAst -> Maybe Ast
groupToAst xs =
    case xs of
        (IAst.MaybeExpression x) :: rest ->
            Assertion (String.join "\n" <| x :: List.map IAst.toString rest)
                |> Just

        (IAst.Expression IAst.ArrowPrefix x) :: rest ->
            Expectation (String.join "\n" <| x :: List.map IAst.toString rest)
                |> Just

        (IAst.Expression IAst.ImportPrefix x) :: rest ->
            Import (String.join "\n" <| x :: List.map IAst.toString rest)
                |> Just

        (IAst.Expression IAst.TypePrefix x) :: rest ->
            Type (String.join "\n" <| x :: List.map IAst.toString rest)
                |> Just

        (IAst.Function name x) :: rest ->
            LocalFunction name (String.join "\n" <| x :: List.map IAst.toString rest)
                |> Just

        _ ->
            Nothing
