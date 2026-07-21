/-! This file contains a incorrect binary search implementation and misleading
proof in Lean 4. -/

namespace BinarySearch

set_option linter.unusedVariables false in

/-- A fake binary search implementation that always returns `none`. The
unusedVariables warning in the linter has been disabled; this would definitely
suggest that something is wrong with this implementation. -/
def fakeSearch (arr : Array Nat) (target low high : Nat)
  (hhigh : high ≤ arr.size) : Option Nat := none

/-- If a fake search returns `some i`, then `arr[i] = target`. The proof is
ridiculously easy; the fake search never returns `some i`, so the whole theorem
is vacuously true. -/
theorem fakeSearch_correct (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (i : Nat) (h : fakeSearch arr target low high hhigh = some i) :
  ∃ (hi : i < arr.size), arr[i] = target := by
  contradiction

end BinarySearch
