module DocTest.Ast exposing (..)


type alias TestSuite =
    { imports : List String
    , tests : List Test
    , functionName : Maybe String
    , functions : List Function
    }


type alias Test =
    { assertion : String
    , expectation : String
    }


type alias Function =
    { used : Bool
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


type Ast
    = Assertion String
    | Expectation String
    | Import String
    | LocalFunction String String


isImport : Ast -> Bool
isImport x =
    case x of
        Import _ ->
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
            Just
                { name = name
                , value = value
                , used =
                    List.any
                        (\{ assertion, expectation } ->
                            String.contains name assertion
                                || String.contains name expectation
                        )
                        rest
                }

        _ ->
            Nothing
