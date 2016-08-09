module Legacy.ElmTest exposing (Test, test, defaultTest, equals, suite, Assertion, assert, assertEqual, assertNotEqual, lazyAssert, assertionList, pass, fail, stringRunner, runSuite, runSuiteHtml)

{-| An implementation of the legacy `ElmTest` module for backwards compatibility.

If you are currently using `ElmTest` and want to upgrade your version of
`elm-test` to access the improved test runners, but still want your existing
code to compile, just replace your current `import ElmTest` with this:

    import Legacy.ElmTest as ElmTest

That's it!

This implementation of the old `ElmTest` API has been done entirely
in terms of the new API. All of the logic should work the same way, although
failure reports will be formatted differently. They are most different for
`stringRunner` and `defaultTest`, so take a look at the docs for those to see
what's changed.

Note that unlike `elm-test`, this API is synchronous, meaning tests cannot be
run in parallel. (That was a big part of the motivation for changing the API!)
Unfortunately, there is no workaround for this. Upgrading is the only way.

# Tests
@docs Test, test, defaultTest, equals, suite

# Assertions
@docs Assertion, assert, assertEqual, assertNotEqual, lazyAssert, assertionList, pass, fail

# Run tests in-program
@docs stringRunner

# Run tests as an app
@docs runSuite, runSuiteHtml
-}

import Test
import Expect
import Test.Runner.Html
import Legacy.LogRunner
import Legacy.StringRunner
import Html.App
import Html


{-| The core unit representing a runnable test, or a group of tests called a
suite.
-}
type alias Test =
    Test.Test


{-| The basic unit of testability.
-}
type alias Assertion =
    Expect.Expectation


{-| A basic function to create a `Test`. Takes a name and an `Assertion`.
-}
test : String -> Assertion -> Test
test desc outcome =
    Test.test desc (\_ -> outcome)


{-| In the original elm-test API, this would create a `Test` with a default name automatically chosen based on the inputs.
For example, `defaultTest (assertEqual 5 5)` would have be named "5 == 5".

In this version, it creates a `Test` with no name instead.
-}
defaultTest : Assertion -> Test
defaultTest assertion =
    Test.test "" (\_ -> assertion)


{-| Create a `Test` which asserts equality between two expressions.
For example, `(7 + 10) `equals` (1 + 16)` will create a `Test` which tests for
equality between the statements `(7 + 10)` and `(1 + 16)`.
-}
equals : a -> a -> Test
equals expected actual =
    Expect.equal expected actual
        |> defaultTest


{-| Convert a list of `Test`s to a test suite. Test suites are used to group
tests into logical units, simplifying the management and running of many tests.
Takes a name and a list of `Test`s. Since suites are also of type `Test`, they
can contain other suites, allowing for a more complex tree structure.
-}
suite : String -> List Test -> Test
suite =
    Test.describe


{-| Basic function to assert that some expression is True
-}
assert : Bool -> Assertion
assert condition =
    if condition then
        Expect.pass
    else
        Expect.fail "Assertion failed"


{-| Basic function to assert that two expressions are equal in value.
-}
assertEqual : a -> a -> Assertion
assertEqual =
    Expect.equal


{-| Basic function to assert that two expressions are not equal.
-}
assertNotEqual : a -> a -> Assertion
assertNotEqual =
    Expect.notEqual


{-| A lazy version of `assert`. Delays execution of the expression until tests
are run.
-}
lazyAssert : (() -> Bool) -> Assertion
lazyAssert fn =
    Expect.true "lazyAssert assertion failed" (fn ())


{-| Given a list of values and another list of expected values, generates a
list of assertions that these values are equal.
-}
assertionList : List a -> List a -> List Assertion
assertionList first second =
    List.map2 assertEqual first second


{-| An assertion that always passes. This is useful when you have test results
from another library but want to use ElmTest runners.
-}
pass : Assertion
pass =
    Expect.pass


{-| Create an assertion that always fails, for reasons described by the given
string.
-}
fail : String -> Assertion
fail =
    Expect.fail


{-| Run a test or a test suite and return the results as a `String`. Mostly
useful if you want to implement a different type of output for your test
results. If you aren't sure whether or not to use this function, you should
probably use `elementRunner`.
-}
stringRunner : Test -> String
stringRunner test =
    (Legacy.StringRunner.run test).output


{-| Run a suite as a program. Useful for tests run from the command line:
    module Tests exposing (..)
    import ElmTest exposing (..)

    tests : Test
    tests =
        suite "A Test Suite"
            [ test "Addition" (assertEqual (3 + 7) 10)
            , test "Subtraction" (assertEqual (7 - 3) 4)
            , test "This test should fail" (assert False)
            ]

    main : Program Never
    main =
        runSuite tests
And then:
    $ elm-make Tests.elm --output tests.js
    $ node tests.js
-}
runSuite : Test -> Program Never
runSuite test =
    Html.App.beginnerProgram
        { model = ()
        , update = \_ _ -> ()
        , view = \_ -> Html.text "Check the console for useful output!"
        }
        |> Legacy.LogRunner.run test


{-| Run a suite as program with Html output.
-}
runSuiteHtml : Test -> Program Never
runSuiteHtml =
    Test.Runner.Html.run
