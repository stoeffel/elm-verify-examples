module VerifyExamples.IntermediateAst
    exposing
        ( IntermediateAst(..)
        , Prefix(..)
        , fromString
        , group
        , toString
        )

import List.Extra
import Regex exposing (HowMany(..), Regex)
import String


type IntermediateAst
    = MaybeExpression String
    | Expression Prefix String
    | Func String String
    | NewLine


type Prefix
    = ArrowPrefix
    | ImportPrefix
    | TypePrefix


toString : IntermediateAst -> String
toString ast =
    case ast of
        MaybeExpression str ->
            str

        Expression _ str ->
            str

        Func _ str ->
            str

        NewLine ->
            "\n"


fromString : String -> List IntermediateAst
fromString parsedComment =
    commentLines parsedComment
        |> List.filterMap toIntermediateAst


commentLines : String -> List String
commentLines str =
    str
        |> String.lines
        |> List.concatMap splitOneLiners


splitOneLiners : String -> List String
splitOneLiners str =
    let
        breakIntoTwoLines a =
            if Regex.contains expectationRegex a then
                a
            else
                Regex.replace Regex.All arrowRegex (\_ -> "\n    --> ") a
    in
    str
        |> breakIntoTwoLines
        |> String.lines


toIntermediateAst : String -> Maybe IntermediateAst
toIntermediateAst =
    oneOf
        [ makeSyntaxRegex newLineRegex (\_ -> NewLine)
        , makeSyntaxRegex importRegex (Expression ImportPrefix)
        , makeSyntaxRegex typeRegex (Expression TypePrefix)
        , makeSyntaxRegex expectationRegex (Expression ArrowPrefix)
        , makeSyntaxRegex localFunctionRegex toFunctionExpression
        , makeSyntaxRegex assertionRegex MaybeExpression
        ]


toFunctionExpression : String -> IntermediateAst
toFunctionExpression str =
    let
        functionToTest : String
        functionToTest =
            str
                |> Regex.find (AtMost 1) functionNameRegex
                |> List.head
                |> Maybe.andThen (.submatches >> List.head)
                |> Maybe.andThen identity
                |> Maybe.withDefault "no function name given!"
    in
    Func functionToTest str


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


oneOf : List (a -> Maybe b) -> a -> Maybe b
oneOf fs str =
    case fs of
        [] ->
            Nothing

        f :: rest ->
            case f str of
                Just result ->
                    Just result

                Nothing ->
                    oneOf rest str


makeSyntaxRegex : Regex -> (String -> a) -> (String -> Maybe a)
makeSyntaxRegex regex f str =
    Regex.find (AtMost 1) regex str
        |> List.map .submatches
        |> List.concat
        |> List.filterMap identity
        |> List.head
        |> Maybe.map f


group : List IntermediateAst -> List (List IntermediateAst)
group =
    List.Extra.groupWhileTransitively groupBy


groupBy : IntermediateAst -> IntermediateAst -> Bool
groupBy x y =
    case ( x, y ) of
        ( _, NewLine ) ->
            False

        ( NewLine, MaybeExpression _ ) ->
            False

        ( _, MaybeExpression _ ) ->
            True

        ( Expression ArrowPrefix _, Expression ArrowPrefix _ ) ->
            True

        _ ->
            False
