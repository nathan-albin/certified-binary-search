import BinarySearch.Interp
import BinarySearch.IR
import BinarySearch.Program

/-! Provides a driver for running the binary search program defined in `Program.lean` -/

namespace BinarySearch.ProgramDriver

open  BinarySearch.Interp BinarySearch.Program

private def C : Nat := 10

def binarySearch (arr : Array Nat) (target : Nat) : Result :=
  let env := Environment.mk arr target
  let state := State.mk 0 0 0
  interp env state (C*arr.size + C) binarySearchIR

end BinarySearch.ProgramDriver
