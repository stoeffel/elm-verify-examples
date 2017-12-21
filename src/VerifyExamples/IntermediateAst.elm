module VerifyExamples.IntermediateAst
    exposing
        ( IntermediateAst
        , fromString
        , toAst
        )

import List.Extra
import Maybe.Util exposing (oneOf)
import Regex exposing (HowMany(..), Regex)
import Regex.Util exposing (firstSubmatch, submatches)
import String
import String.Util exposing (unlines)
import VerifyExamples.Ast as Ast exposing (Ast)


type IntermediateAst
    = ExpressionNotPrefixed String
    | Expression Prefix String
    | Function String String
    | NewLine


type Prefix
    = ArrowPrefix
    | ImportPrefix
    | TypePrefix


fromString : String -> List IntermediateAst
fromString =
    commentLines >> List.filterMap toIntermediateAst


commentLines : String -> List String
commentLines =
    String.lines
        >> List.concatMap splitOneLiners


splitOneLiners : String -> List String
splitOneLiners =
    breakIntoTwoLines >> String.lines


breakIntoTwoLines : String -> String
breakIntoTwoLines a =
    if Regex.contains expectationRegex a then
        a
    else
        Regex.replace Regex.All arrowRegex (always "\n    --> ") a


toIntermediateAst : String -> Maybe IntermediateAst
toIntermediateAst =
    oneOf
        [ firstSubmatch newLineRegex >> Maybe.map (always NewLine)
        , firstSubmatch importRegex >> Maybe.map (Expression ImportPrefix)
        , firstSubmatch typeRegex >> Maybe.map (Expression TypePrefix)
        , firstSubmatch expectationRegex >> Maybe.map (Expression ArrowPrefix)
        , firstSubmatch localFunctionRegex >> Maybe.map toFunctionExpression
        , firstSubmatch assertionRegex >> Maybe.map ExpressionNotPrefixed
        ]


toFunctionExpression : String -> IntermediateAst
toFunctionExpression str =
    firstSubmatch functionNameRegex str
        |> Maybe.withDefault "no function name given!"
        |> flip Function str


arrowRegex : Regex
arrowRegex =
    Regex.regex "\\s\\-\\->\\s"


newLineRegex : Regex
newLineRegex =
    Regex.regex "(^\\s*$)"


importRegex : Regex
importRegex =
    Regex.regex "^\\s{4}(import\\s.*)"


typeRegex : Regex
typeRegex =
    Regex.regex "^\\s{4}(type\\s.*)"


functionNameRegex : Regex
functionNameRegex =
    Regex.regex "(\\w+)\\s:"


assertionRegex : Regex
assertionRegex =
    Regex.regex "^\\s{4}(.*)"


expectationRegex : Regex
expectationRegex =
    Regex.regex "^\\s{4}\\-\\->\\s(.*)"


localFunctionRegex : Regex
localFunctionRegex =
    Regex.regex "^\\s{4}(\\w+\\s:\\s.*)"


toAst : List IntermediateAst -> List Ast
toAst =
    List.Extra.groupWhileTransitively group
        >> List.filterMap convertGroup


group : IntermediateAst -> IntermediateAst -> Bool
group x y =
    case x of
        NewLine ->
            False

        ExpressionNotPrefixed _ ->
            notPrefixed y

        Function _ _ ->
            notPrefixed y

        Expression prefix _ ->
            case prefix of
                ImportPrefix ->
                    notPrefixed y

                TypePrefix ->
                    notPrefixed y

                ArrowPrefix ->
                    arrowPrefixed y


notPrefixed : IntermediateAst -> Bool
notPrefixed ast =
    case ast of
        ExpressionNotPrefixed _ ->
            True

        _ ->
            False


arrowPrefixed : IntermediateAst -> Bool
arrowPrefixed ast =
    case ast of
        Expression ArrowPrefix _ ->
            True

        _ ->
            False


convertGroup : List IntermediateAst -> Maybe Ast
convertGroup ast =
    case ast of
        first :: _ ->
            List.map toString ast
                |> unlines
                |> convertWithString first

        [] ->
            Nothing


convertWithString : IntermediateAst -> String -> Maybe Ast
convertWithString ast str =
    case ast of
        ExpressionNotPrefixed _ ->
            Just (Ast.Assertion str)

        Expression ArrowPrefix _ ->
            Just (Ast.Expectation str)

        Expression ImportPrefix _ ->
            Just (Ast.Import str)

        Expression TypePrefix _ ->
            Just (Ast.Type str)

        Function name _ ->
            Just (Ast.Function name str)

        NewLine ->
            Nothing


toString : IntermediateAst -> String
toString ast =
    case ast of
        ExpressionNotPrefixed str ->
            str

        Expression _ str ->
            str

        Function _ str ->
            str

        NewLine ->
            "\n"
