import Mathlib.Algebra.Order.Sub.Defs
import Mathlib.Order.Antisymmetrization
import Mathlib.Tactic.Ring

set_option linter.style.header false

/-!
This file contains a simple binary search implementation and proof in Lean 4.
-/

namespace BinarySearch

/-- Binary search implementation. If the array is sorted, this function will
  either return an index `some i` such that `i ∈ [low,high)` and `arr[i] =
  target` or `none` if no such index exists. -/
def binarySearch (arr : Array Nat) (target low high : Nat)
  (hhigh : high ≤ arr.size) : Option Nat :=
if hlh : low ≥ high then
  none
else
  let mid := (low + high) / 2
  have hmid : mid < arr.size := by omega
  if arr[mid] = target then
    some  mid
  else if arr[mid] < target then
    binarySearch arr target (mid+1) high hhigh
  else
    binarySearch arr target low mid hmid.le

def testArray : Array Nat := #[1, 3, 5, 7, 7, 9]

set_option linter.hashCommand false in
#guard binarySearch testArray 5 0 testArray.size (by decide) == some 2
set_option linter.hashCommand false in
#guard binarySearch testArray 2 0 testArray.size (by decide) == none
set_option linter.hashCommand false in
#guard binarySearch testArray 9 0 testArray.size (by decide) == some 5
set_option linter.hashCommand false in
#guard binarySearch testArray 1 0 testArray.size (by decide) == some 0
set_option linter.hashCommand false in
#guard binarySearch testArray 0 0 testArray.size (by decide) == none
set_option linter.hashCommand false in
#guard binarySearch testArray 7 0 testArray.size (by decide) == some 3

/-- An array is sorted if it is in non-decreasing order. -/
def Sorted (arr : Array Nat) : Prop :=
  ∀ i j (hi : i < arr.size) (hj : j < arr.size), i < j → arr[i] ≤ arr[j]

/-- An element is in the range `[low, high)` if there exists an index `i` in
that range such that `arr[i] = target`. -/
def InRange (arr : Array Nat) (target low high : Nat) : Prop :=
  ∃ (i : Nat) (hi : i < arr.size), low ≤ i ∧ i < high ∧ arr[i] = target

/-- If an element is in the range and we pick a midpoint, then the element is in
one of three places: the midpoint itself, the left half, or the right half. -/
theorem split_InRange (arr : Array Nat) (target low high mid : Nat)
  (hmid : mid < arr.size) (h : InRange arr target low high) :
  arr[mid] = target ∨ InRange arr target low mid ∨ InRange arr target (mid+1) high := by
    obtain ⟨i, hi, hlow, hhigh, htarget⟩ := h
    match lt_trichotomy i mid with
    | Or.inl hlt =>
      right
      left
      exact ⟨i, hi, hlow, hlt, htarget⟩
    | Or.inr (Or.inl heq) =>
      left
      rw [←htarget]
      congr
      exact heq.symm
    | Or.inr (Or.inr hgt) =>
      right
      right
      have hge := Nat.add_one_le_iff.mpr hgt
      exact ⟨i, hi, hge, hhigh, htarget⟩

/-- If binary search returns `some i`, then `arr[i] = target`. -/
theorem binarySearch_some (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (i : Nat) (h : binarySearch arr target low high hhigh = some i) :
  ∃ (hi : i < arr.size), arr[i] = target := by
  induction low, high, hhigh using binarySearch.induct with
  | target => exact target
  | case1 _ _ _ hlh=>
    simp [binarySearch, hlh] at h
  | case2 low high _ _ mid hmid ht =>
    unfold binarySearch at h
    dsimp only at h
    split_ifs at h
    · rw [Option.some.injEq] at h
      subst ht h
      simp_all [mid]
  | case3 low high hhigh hlh mid hmid hne hlt hbs =>
    unfold binarySearch at h
    dsimp only at h
    split_ifs at h
    · simp_all [mid]
  | case4 low high hhigh hlh mid hmid hne hnlt hbs =>
    unfold binarySearch at h
    dsimp only at h
    split_ifs at h
    · simp_all [mid]

/-- If binary search returns `none`, then the element is not in the range. -/
theorem binarySearch_none (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (hsorted : Sorted arr) (h : binarySearch arr target low high hhigh = none) :
  ¬ InRange arr target low high := by
  induction low, high, hhigh using binarySearch.induct with
  | target => exact target
  | case1 low high hhigh hlh =>
    unfold binarySearch at h
    dsimp only at h
    split_ifs at h
    rw [InRange]
    by_contra hc
    obtain ⟨i, hi, hlow, hhigh', htarget⟩ := hc
    omega
  | case2 low high hhigh hlh mid hmid htarget=>
    unfold binarySearch at h
    dsimp only at h
    split_ifs at h
  | case3 low high hhigh hlh mid hmid htarget hlt hbs =>
    unfold binarySearch at h
    dsimp only at h
    split_ifs at h
    have hrange := hbs h
    have hrange' : ¬InRange arr target low mid := by
      intro hleft
      obtain ⟨i, hi, hlow, hmid', htarget'⟩ := hleft
      rw [←htarget'] at hlt
      exact (hsorted i mid hi hmid hmid').not_gt hlt
    intro hfull
    have hsplit := split_InRange arr target low high mid hmid hfull
    rcases hsplit with heq | hleft | hright
    · exact htarget heq
    · exact hrange' hleft
    · exact hrange hright
  | case4 low high hhigh hlh mid hmid hne hnlt hbs =>
    unfold binarySearch at h
    dsimp only at h
    split_ifs at h
    have hrange := hbs h
    have hrange' : ¬InRange arr target (mid+1) high := by
      intro hright
      obtain ⟨i, hi, hmid', hhigh', htarget⟩ := hright
      rw [←htarget] at hnlt
      have hle := hsorted mid i hmid hi (Nat.add_one_le_iff.mp hmid')
      have heq := hle.not_lt_iff_eq.mp hnlt
      rw [htarget] at heq
      contradiction
    intro hfull
    have hsplit := split_InRange arr target low high mid hmid hfull
    rcases hsplit with heq | hleft | hright
    · exact hne heq
    · exact hrange hleft
    · exact hrange' hright

/-- Extra correctness check. In case InRange is somehow misleading, this theorem
provides a more direct way of stating that if `target` is in the array, then the
search returns an index where it is found. -/
theorem binarySearch_finds (arr : Array Nat) (target : Nat)
  (hsorted : Sorted arr) (h_contains : target ∈ arr) :
  ∃ (i : Nat), binarySearch arr target 0 arr.size arr.size.le_refl = some i := by
    have h_in_range : InRange arr target 0 arr.size := by
      unfold InRange
      obtain ⟨i, hi, htarget⟩ := Array.mem_iff_getElem.mp h_contains
      exact ⟨i, hi, i.zero_le, hi, htarget⟩
    rcases hb : binarySearch arr target 0 arr.size arr.size.le_refl with _ | i
    · exact absurd h_in_range (binarySearch_none arr target 0 arr.size arr.size.le_refl hsorted hb)
    · obtain ⟨hi, htarget⟩ := binarySearch_some arr target 0 arr.size arr.size.le_refl i hb
      exact ⟨i, rfl⟩

end BinarySearch
