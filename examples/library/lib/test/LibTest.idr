module lib.test.LibTest

import lib.Library

assertEq : Eq a => (given : a) -> (expected : a) -> IO ()
assertEq g e = if g == e
    then putStrLn "Test Passed"
    else putStrLn "Test Failed"

assertNotEq : Eq a => (given : a) -> (expected : a) -> IO ()
assertNotEq g e = if not (g == e)
    then putStrLn "Test Passed"
    else putStrLn "Test Failed"

testDouble : IO ()
testDouble = assertEq (2 * 2) 5

testTriple : IO ()
testTriple = assertNotEq (2 * 2 * 2) 5

export
test : IO ()
test = do testDouble
          testTriple
