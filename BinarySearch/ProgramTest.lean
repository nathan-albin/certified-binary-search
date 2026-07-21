import BinarySearch.IR
import BinarySearch.Interp
import BinarySearch.Program

/-! Tests for the IR binary search program-/

namespace BinarySearch.ProgramTest

open BinarySearch.IR BinarySearch.Interp BinarySearch.Program

def binarySearch (arr : Array Nat) (target : Nat) (low high : Nat) : Result :=
  let env := Environment.mk arr target
  let state := State.mk low high 0
  interp env state (10*arr.size) binarySearchIR

def testArray : Array Nat := #[1, 3, 5, 7, 7, 9]

#guard binarySearch testArray 5 0 testArray.size == Result.return_index 2
#guard binarySearch testArray 2 0 testArray.size == Result.return_none
#guard binarySearch testArray 9 0 testArray.size == Result.return_index 5
#guard binarySearch testArray 1 0 testArray.size == Result.return_index 0
#guard binarySearch testArray 0 0 testArray.size == Result.return_none
#guard binarySearch testArray 7 0 testArray.size == Result.return_index 3

end BinarySearch.ProgramTest
