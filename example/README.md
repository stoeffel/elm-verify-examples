Examples for elm-verify-examples
=================================

This is an example project on which you can test `elm-verify-examples`.

The funny thing is, this file illustrates how the tool can verify examples even inside your READMEs and other markdown files.

So this snippet would pass:

```elm
import Documented

Documented.two --> 2
```

But the following would cause a build error!

```elm
import Documented

Documented.two --> 3
```
