module lib.test.LibTest

import lib.Library
import System

exists : (a -> Bool) -> List a -> Bool
exists p l = isJust (find p l)

forall : (a -> Bool) -> List a -> Bool
forall p l = not (exists (\i => not (p i)) l)

finaliseTestRunning : List (Bool, String) -> IO ()
finaliseTestRunning l = if forall fst l
                          then putStrLn "All tests PASSED"
                          else do putStrLn "Some tests FAILED"
                                  exit 1

printResults : List (Bool, String) -> IO (List ())
printResults   tests = sequence (map (\pair => putStrLn (snd pair)) tests)

runTests : List (Bool, String) -> IO ()
runTests   tests = do printResults tests
                      finaliseTestRunning tests

assert : Bool -> String -> String -> (Bool, String)
assert   True    s         f      =  (True, s)
assert   False   s         f      =  (False, f)

assertEq : (Eq a, Show a) => (label: String) -> (given : a) -> (expected : a) -> (Bool, String)
assertEq l g e = assert (g == e) (l ++ ": Passed") (l ++ ": Failed\n  GIVEN: " ++ (show g) ++ "\n  EXPECTED: " ++ (show e))

assertNotEq : (Eq a, Show a) => (label: String) -> (given : a) -> (expected : a) -> (Bool, String)
assertNotEq l g e = assert ( not (g == e)) (l ++ ": Passed") (l ++ ": Failed\n  Both values were expected to be different\n  BOTH ARE: " ++ (show g) ++ "\n  EXPECTED: ")

testDouble : (Bool, String)
testDouble = assertEq "Test double" (2 * 2) 4

testTriple : (Bool, String)
testTriple = assertNotEq "Test triple" (2 * 2 * 2) 5

testLibrary1 : (Bool, String)
testLibrary1 = assertEq "Test salute" salute "Hello, library example of idris"

testLibrary2 : (Bool, String)
testLibrary2 = assertNotEq "Test salute diff" salute "Ups"

export
test : IO ()
test = runTests [testDouble, testTriple, testLibrary1, testLibrary2]
