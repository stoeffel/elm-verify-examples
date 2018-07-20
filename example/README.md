Examples for elm-verify-examples
=================================

This is an example project on which you can test `elm-verify-examples`.

Comments in this project's source files will be compiled into tests.

Besides that, code examples in this same markdown file will also be automatically verified. So this snippet will pass:

```elm
import Documented

Documented.two --> 2
```

But the following will case a test to fail!

```elm
import Documented

Documented.two --> 3
```
