module VerifyExamples.Ast exposing (Ast(..), toString)


type Ast
    = Assertion String
    | Expectation String
    | Import String
    | Function String String
    | Type String


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

        Function _ str ->
            str
