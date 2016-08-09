module Legacy.Check.Test exposing (evidenceToTest)

{-| An implementation of the legacy `Check.Test` module for backwards compatibility.

If you are currently using `Check.Test` and want to upgrade your version of
`elm-test` to access the improved test runners, but still want your existing
code to compile, just replace your current `import Check.Test` with this:

    import Legacy.Check.Test as CheckTest

That's it! (Well, you may also need to find/replace `Check.Test` with `CheckTest`.)

This module provides integration with
[`elm-test`](http://package.elm-lang.org/packages/elm-community/elm-test/latest/).

# Convert to Tests
@docs evidenceToTest
-}

import Check
import Legacy.ElmTest as ElmTest


{-| Convert elm-check's Evidence into an elm-test Test. You can use elm-test's
runners to view the results of your property-based tests, alongside the results
of unit tests.
-}
evidenceToTest : Check.Evidence -> ElmTest.Test
evidenceToTest evidence =
    case evidence of
        Check.Multiple name more ->
            ElmTest.suite name (List.map evidenceToTest more)

        Check.Unit (Ok { name, numberOfChecks }) ->
            ElmTest.test (name ++ " [" ++ nChecks numberOfChecks ++ "]") ElmTest.pass

        Check.Unit (Err { name, numberOfChecks, expected, actual, counterExample }) ->
            ElmTest.test name <|
                ElmTest.fail <|
                    "\nOn check "
                        ++ toString numberOfChecks
                        ++ ", found counterexample: "
                        ++ counterExample
                        ++ "\nExpected:   "
                        ++ expected
                        ++ "\nBut It Was: "
                        ++ actual


nChecks : Int -> String
nChecks n =
    if n == 1 then
        "1 check"
    else
        toString n ++ " checks"
