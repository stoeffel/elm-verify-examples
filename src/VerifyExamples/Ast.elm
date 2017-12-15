module VerifyExamples.Ast exposing (..)


type alias TestSuite =
    { imports : List String
    , types : List String
    , tests : List Test
    , functionToTest : Maybe String
    , helperFunctions : List Function
    }


type alias Test =
    { assertion : String
    , expectation : String
    }


type alias Function =
    { isUsed : Bool
    , name : String
    , value : String
    }


type IntermediateAst
    = MaybeExpression String
    | Expression Prefix String
    | Func Name String
    | NewLine


type alias Name =
    String


type Prefix
    = ArrowPrefix
    | ImportPrefix
    | TypePrefix


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


astToString : Ast -> String
astToString ast =
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


intermediateToString : IntermediateAst -> String
intermediateToString ast =
    case ast of
        MaybeExpression str ->
            str

        Expression _ str ->
            str

        Func _ str ->
            str

        NewLine ->
            "\n"


astToFunction : List Test -> Ast -> Maybe Function
astToFunction rest ast =
    case ast of
        LocalFunction name value ->
            { name = name
            , value = value
            , isUsed =
                List.any
                    (\{ assertion, expectation } ->
                        String.contains name assertion
                            || String.contains name expectation
                    )
                    rest
            }
                |> Just

        _ ->
            Nothing
