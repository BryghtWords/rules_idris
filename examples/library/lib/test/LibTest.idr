module lib.test.LibTest

import lib.Library
import System
import idristest.Suite

testDouble : (Bool, String)
testDouble = assertEq "Test double" (2 * 2) 4

testTriple : (Bool, String)
testTriple = assertNotEq "Test triple" (2 * 2 * 2) 5

testLibrary1 : (Bool, String)
testLibrary1 = assertEq "Test salute" salute "Hello, library example of idris"

testLibrary2 : (Bool, String)
testLibrary2 = assertNotEq "Test salute diff" salute "Ups"

export
test : IO Bool
test = runTests [testDouble, testTriple, testLibrary1, testLibrary2]
