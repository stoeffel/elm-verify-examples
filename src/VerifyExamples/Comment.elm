module VerifyExamples.Comment exposing (Comment, parse)

import Regex exposing (HowMany(..), Regex)


type alias Comment =
    { comment : String
    , functionName : String
    }


parse : String -> List Comment
parse =
    List.filterMap (nameAndComment << .submatches)
        << Regex.find All commentRegex


nameAndComment : List (Maybe String) -> Maybe Comment
nameAndComment matches =
    case matches of
        (Just comment) :: (Just functionName) :: _ ->
            Just
                { comment = comment
                , functionName =
                    functionName
                        |> String.split " :"
                        |> List.head
                        |> Maybe.withDefault ""
                }

        _ ->
            Nothing


commentRegex : Regex
commentRegex =
    Regex.regex "({-[^]*?-})\x0D?\n([^\x0D\n]*)\\s[:=]"
