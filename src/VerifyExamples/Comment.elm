module VerifyExamples.Comment exposing (Comment, parse)

import Regex exposing (HowMany(..), Regex)


type alias Comment =
    { comment : String
    , functionName : String
    }


parse : String -> List Comment
parse =
    Regex.find All commentRegex
        >> List.filterMap (toComment << .submatches)


toComment : List (Maybe String) -> Maybe Comment
toComment matches =
    case matches of
        (Just comment) :: (Just functionName) :: _ ->
            Just { comment = comment, functionName = functionName }

        _ ->
            Nothing


commentRegex : Regex
commentRegex =
    Regex.regex <|
        String.concat
            [ "({-[^]*?-})" -- anything between comments
            , newline
            , "([^\\s(" ++ newline ++ ")]*)" -- anything that is not a space or newline
            , "\\s[:=]" -- until ` :` or ` =`
            ]


newline : String
newline =
    "\x0D?\n"
