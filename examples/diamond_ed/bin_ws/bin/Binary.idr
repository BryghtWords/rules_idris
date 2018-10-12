module Main

import lib.Library1
import lib.Library3

main : IO ()
main = putStrLn (Library1.salute ++ "\n\n" ++ Library3.salute)

