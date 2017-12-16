module VerifyExamples.Comment exposing (Comment, parse)

import Regex exposing (HowMany(..), Regex)


type alias Comment =
    { comment : String
    , functionName : String
    }


parse : String -> List Comment
parse =
    List.filterMap (toComment << .submatches)
        << Regex.find All commentRegex


toComment : List (Maybe String) -> Maybe Comment
toComment matches =
    case matches of
        (Just comment) :: (Just functionName) :: _ ->
            Just { comment = comment, functionName = functionName }

        _ ->
            Nothing


commentRegex : Regex
commentRegex =
    Regex.regex "({-[^]*?-})\x0D?\n([^\x0D\n(\\s:)(\\s=))]*)\\s[:=]"
