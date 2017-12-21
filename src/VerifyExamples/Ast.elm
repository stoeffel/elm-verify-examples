module VerifyExamples.Ast
    exposing
        ( Ast(..)
        , Example
        , group
        , toString
        )


type Ast
    = Assertion String
    | Expectation String
    | Import String
    | Function String String
    | Type String


type alias Groupped =
    { functions : List Ast
    , imports : List Ast
    , types : List Ast
    , examples : List Example
    }


type alias Example =
    { assertion : String, expectation : String }


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


group : List Ast -> Groupped
group ast =
    groupHelp ast empty


groupHelp : List Ast -> Groupped -> Groupped
groupHelp ast acc =
    case ast of
        [] ->
            acc

        (Assertion assertion) :: (Expectation expectation) :: rest ->
            { assertion = assertion, expectation = expectation }
                :: acc.examples
                |> setExamples acc
                |> groupHelp rest

        (Assertion assertion) :: rest ->
            groupHelp rest acc

        (Expectation str) :: rest ->
            groupHelp rest acc

        (Import str) :: rest ->
            Import str
                :: acc.imports
                |> setImports acc
                |> groupHelp rest

        (Type str) :: rest ->
            Type str
                :: acc.types
                |> setTypes acc
                |> groupHelp rest

        (Function name str) :: rest ->
            Function name str
                :: acc.functions
                |> setFunctions acc
                |> groupHelp rest


empty : Groupped
empty =
    { functions = []
    , imports = []
    , types = []
    , examples = []
    }


setExamples : Groupped -> List Example -> Groupped
setExamples groupped examples =
    { groupped | examples = examples }


setImports : Groupped -> List Ast -> Groupped
setImports groupped imports =
    { groupped | imports = imports }


setTypes : Groupped -> List Ast -> Groupped
setTypes groupped types =
    { groupped | types = types }


setFunctions : Groupped -> List Ast -> Groupped
setFunctions groupped functions =
    { groupped | functions = functions }
