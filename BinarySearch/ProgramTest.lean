import BinarySearch.Interp
import BinarySearch.ProgramDriver

/-! Tests for the IR binary search program-/

namespace BinarySearch.ProgramTest

open BinarySearch.ProgramDriver open BinarySearch.Interp

/-- Sample sorted array used by the `#guard` sanity checks below. -/
def testArray : Array Nat := #[1, 3, 5, 7, 7, 9]

#guard binarySearch testArray 5 == Result.return_index 2
#guard binarySearch testArray 2 == Result.return_none
#guard binarySearch testArray 9 == Result.return_index 5
#guard binarySearch testArray 1 == Result.return_index 0
#guard binarySearch testArray 0 == Result.return_none
#guard binarySearch testArray 7 == Result.return_index 3

/-- The empty array: `binarySearch` should never find anything in it. -/
def emptyArray : Array Nat := #[]

#guard binarySearch emptyArray 5 == Result.return_none

/-- A single-element array, to exercise the base case directly. -/
def singletonArray : Array Nat := #[42]

#guard binarySearch singletonArray 42 == Result.return_index 0
#guard binarySearch singletonArray 7 == Result.return_none

/-- A two-element array, to exercise both possible found indices and misses on
either side and in between. -/
def pairArray : Array Nat := #[10, 20]

#guard binarySearch pairArray 10 == Result.return_index 0
#guard binarySearch pairArray 20 == Result.return_index 1
#guard binarySearch pairArray 15 == Result.return_none

/-- A longer array with duplicate runs at both the start and the end (`1, 1`
and `15, 15`) as well as in the middle, to exercise more search iterations
and more chances for an off-by-one mistake to show up. -/
def largeArray : Array Nat := #[1, 1, 3, 4, 4, 4, 6, 8, 8, 10, 12, 15, 15]

#guard binarySearch largeArray 1 == Result.return_index 1
#guard binarySearch largeArray 15 == Result.return_index 12
#guard binarySearch largeArray 4 == Result.return_index 3
#guard binarySearch largeArray 8 == Result.return_index 8
#guard binarySearch largeArray 12 == Result.return_index 10
#guard binarySearch largeArray 0 == Result.return_none
#guard binarySearch largeArray 5 == Result.return_none
#guard binarySearch largeArray 20 == Result.return_none

end BinarySearch.ProgramTest
