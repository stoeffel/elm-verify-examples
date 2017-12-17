module VerifyExamples.IntermediateAst
    exposing
        ( IntermediateAst
        , convert
        , fromString
        )

import List.Extra
import Maybe.Util exposing (oneOf)
import Regex exposing (HowMany(..), Regex)
import Regex.Util exposing (firstSubmatch)
import String
import String.Util exposing (unlines)


type IntermediateAst
    = MaybeExpression String
    | Expression Prefix String
    | Function String String
    | NewLine


type Prefix
    = ArrowPrefix
    | ImportPrefix
    | TypePrefix


fromString : String -> List IntermediateAst
fromString =
    List.filterMap toIntermediateAst << commentLines


commentLines : String -> List String
commentLines =
    List.concatMap splitOneLiners << String.lines


splitOneLiners : String -> List String
splitOneLiners =
    String.lines << breakIntoTwoLines


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
        , firstSubmatch assertionRegex >> Maybe.map MaybeExpression
        ]


toFunctionExpression : String -> IntermediateAst
toFunctionExpression str =
    str
        |> firstSubmatch functionNameRegex
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


type alias Converter a =
    { maybeExpression : String -> a
    , arrowPrefixed : String -> a
    , importPrefixed : String -> a
    , typePrefixed : String -> a
    , function : String -> String -> a
    }


convert : Converter a -> List IntermediateAst -> List a
convert to =
    group >> List.filterMap (convertGroup to)


convertGroup : Converter a -> List IntermediateAst -> Maybe a
convertGroup to ast =
    case ast of
        first :: _ ->
            List.map toString ast
                |> unlines
                |> convertWithString to first

        [] ->
            Nothing


convertWithString : Converter a -> IntermediateAst -> String -> Maybe a
convertWithString to ast str =
    case ast of
        MaybeExpression _ ->
            Just (to.maybeExpression str)

        Expression ArrowPrefix _ ->
            Just (to.arrowPrefixed str)

        Expression ImportPrefix _ ->
            Just (to.importPrefixed str)

        Expression TypePrefix _ ->
            Just (to.typePrefixed str)

        Function name _ ->
            Just (to.function name str)

        NewLine ->
            Nothing


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


toString : IntermediateAst -> String
toString ast =
    case ast of
        MaybeExpression str ->
            str

        Expression _ str ->
            str

        Function _ str ->
            str

        NewLine ->
            "\n"
