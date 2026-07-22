import BinarySearch.Basic
import BinarySearch.Interp
import BinarySearch.ProgramDriver

set_option linter.style.header false

/-! Proof that the binary search program defined in `Program.lean` when passed
through the interpreter in `Interp.lean` produces the same result as the Lean
implementation in `Basic.lean` -/

namespace BinarySearch.ProgramCorrect

open BinarySearch.Interp

/-! Defines what it means for the program results to match the output of the
native Lean search -/

def resultsMatch (resultIR : Result) (ResultLean : Option Nat) : Prop :=
  match resultIR, ResultLean with
  | Result.return_index i, some j => i = j
  | Result.return_none, none => True
  | _, _ => False

/-! The main theorem: the binary search IR implementation produces the same
result as the native Lean implementation -/
theorem binarySearch_correct (arr : Array Nat) (target low high : Nat)
  (hhigh : high ≤ arr.size) (hsorted : Sorted arr) :
  resultsMatch (BinarySearch.ProgramDriver.binarySearch arr target low high)
    (binarySearch arr target low high hhigh) := by
  sorry

end BinarySearch.ProgramCorrect
