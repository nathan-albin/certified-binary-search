import BinarySearch.Interp
import BinarySearch.ProgramDriver

/-! Tests for the IR binary search program-/

namespace BinarySearch.ProgramTest

open BinarySearch.ProgramDriver open BinarySearch.Interp

def testArray : Array Nat := #[1, 3, 5, 7, 7, 9]

#guard binarySearch testArray 5 == Result.return_index 2
#guard binarySearch testArray 2 == Result.return_none
#guard binarySearch testArray 9 == Result.return_index 5
#guard binarySearch testArray 1 == Result.return_index 0
#guard binarySearch testArray 0 == Result.return_none
#guard binarySearch testArray 7 == Result.return_index 3

end BinarySearch.ProgramTest
