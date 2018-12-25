module Main

%include C "main.h"

salute : IO ()
salute = foreign FFI_C "salute" (IO ())

main : IO ()
main = salute

