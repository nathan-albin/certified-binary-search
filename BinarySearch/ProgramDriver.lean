import BinarySearch.Interp
import BinarySearch.IR
import BinarySearch.Program

/-! Provides a driver for running the binary search program defined in `Program.lean` -/

namespace BinarySearch.ProgramDriver

open  BinarySearch.Interp BinarySearch.Program

def binarySearch (arr : Array Nat) (target : Nat) (low high : Nat) : Result :=
  let env := Environment.mk arr target
  let state := State.mk low high 0
  interp env state (10*arr.size) binarySearchIR

end BinarySearch.ProgramDriver
