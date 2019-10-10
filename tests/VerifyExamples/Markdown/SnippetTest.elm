module VerifyExamples.Markdown.SnippetTest exposing (..)

import Expect
import Test exposing (..)
import VerifyExamples.Markdown.Snippet as Snippet exposing (Snippet(..))


parseTest : Test
parseTest =
    describe "parse"
        [ test "on a single snippet" <|
            \_ ->
                Snippet.parse
                    """Hello, World

```elm
1 + 2
--> 3
```

Goodbye world."""
                    |> Expect.equal [ Snippet "1 + 2\n--> 3" ]
        , test "on multiple snippets" <|
            \_ ->
                Snippet.parse
                    """Hello, World

```elm
1 + 2
--> 3
```

```elm
String.reverse "racecar"
--> "racecar"
```

Goodbye world."""
                    |> Expect.equal
                        [ Snippet "1 + 2\n--> 3"
                        , Snippet "String.reverse \"racecar\"\n--> \"racecar\""
                        ]
        , test "on a snippet that defines a function" <|
            \_ ->
                Snippet.parse
                    """Hello, World

```elm
add : Int -> Int -> Int
add x y =
    x + y

add 1 2
--> 3
```


Goodbye world."""
                    |> Expect.equal
                        [ Snippet "add : Int -> Int -> Int\nadd x y =\n    x + y\n\nadd 1 2\n--> 3"
                        ]
        ]
