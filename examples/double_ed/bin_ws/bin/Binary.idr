module Main

import lib.Library1
import lib.Library2

main : IO ()
main = putStrLn (salute1 ++ "\n" ++ salute2)

