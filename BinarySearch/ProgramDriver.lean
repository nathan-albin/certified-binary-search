import BinarySearch.Interp
import BinarySearch.IR
import BinarySearch.Program

/-! Provides a driver for running the binary search program defined in `Program.lean` -/

namespace BinarySearch.ProgramDriver

open  BinarySearch.Interp BinarySearch.Program

/-- Fuel needed to execute the binary search program. Since the search has
logarithmic complexity, this is far more than is necessary in general. -/
def fullFuel (low high : Nat) : Nat :=
  10 * (high - low) + 10

def binarySearch (arr : Array Nat) (target : Nat) : Result :=
  let env := Environment.mk arr target
  let state := State.mk 0 0 0
  interp env state (fullFuel 0 arr.size) binarySearchIR

end BinarySearch.ProgramDriver
