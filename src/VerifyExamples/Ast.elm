module VerifyExamples.Ast
    exposing
        ( Ast(..)
        , fromIntermediateAst
        , isAssertion
        , isExpectiation
        , isImport
        , isLocalFunction
        , isType
        , toString
        )

import VerifyExamples.IntermediateAst as IAst exposing (IntermediateAst)


type Ast
    = Assertion String
    | Expectation String
    | Import String
    | LocalFunction String String
    | Type String


isImport : Ast -> Bool
isImport x =
    case x of
        Import _ ->
            True

        _ ->
            False


isType : Ast -> Bool
isType x =
    case x of
        Type _ ->
            True

        _ ->
            False


isAssertion : Ast -> Bool
isAssertion x =
    case x of
        Assertion _ ->
            True

        _ ->
            False


isExpectiation : Ast -> Bool
isExpectiation x =
    case x of
        Expectation _ ->
            True

        _ ->
            False


isLocalFunction : Ast -> Bool
isLocalFunction x =
    case x of
        LocalFunction _ _ ->
            True

        _ ->
            False


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

        (IAst.Func name x) :: rest ->
            LocalFunction name (String.join "\n" <| x :: List.map IAst.toString rest)
                |> Just

        _ ->
            Nothing
