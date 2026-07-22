import BinarySearch.Basic
import BinarySearch.Interp
import BinarySearch.ProgramDriver
import Mathlib.Data.Nat.Notation

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

theorem innerBlock_step (arr : Array Nat) (target low high mid fuel : Nat)
    (hmid : (low + high) / 2 < arr.size)
    (hfuel : fuel ≥ 4) :
    interp (Environment.mk arr target) (State.mk low high mid) fuel Program.innerBlock =
      if arr[(low + high) / 2] = target then
        Result.return_index ((low + high) / 2)
      else if arr[(low + high) / 2] < target then
        Result.success (State.mk ((low + high) / 2 + 1) high ((low + high) / 2))
      else
        Result.success (State.mk low ((low + high) / 2) ((low + high) / 2)) := by
  have htargetD : arr.getD ((low + high) / 2) 0 = arr[(low + high) / 2] := by
    unfold Array.getD; simp [hmid]
  have htargetD2 : arr[(low + high) / 2]?.getD 0 = arr[(low + high) / 2] := by
    simp [hmid]
  split_ifs with h₁ h₂
  · have hn₁ : fuel ≠ 0 := by omega
    obtain ⟨n₁, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₁
    unfold Program.innerBlock
    simp only [interp]
    have hn₂ : n₁ ≠ 0 := by omega
    obtain ⟨n₂, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₂
    simp [interp, evalExpr, updateState, htargetD, h₁]
    have hn₃ : n₂ ≠ 0 := by omega
    obtain ⟨n₃, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₃
    simp [interp, evalExpr]
  · have hn₁ : fuel ≠ 0 := by omega
    obtain ⟨n₁, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₁
    unfold Program.innerBlock
    simp only [interp]
    have hn₂ : n₁ ≠ 0 := by omega
    obtain ⟨n₂, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₂
    simp only [interp, updateState, evalExpr, Array.getD_eq_getD_getElem?, htargetD2, h₁,
      ↓reduceIte, ne_eq, not_true_eq_false]
    unfold Program.splitBlock
    have hn₃ : n₂ ≠ 0 := by omega
    obtain ⟨n₃, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₃
    simp [interp, evalExpr, htargetD2, h₂]
    have hn₄ : n₃ ≠ 0 := by omega
    obtain ⟨n₄, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₄
    simp [interp, evalExpr, updateState]
  · have hn₁ : fuel ≠ 0 := by omega
    obtain ⟨n₁, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₁
    unfold Program.innerBlock
    simp only [interp]
    have hn₂ : n₁ ≠ 0 := by omega
    obtain ⟨n₂, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₂
    simp only [interp, updateState, evalExpr, Array.getD_eq_getD_getElem?, htargetD2, h₁,
      ↓reduceIte, ne_eq, not_true_eq_false]
    unfold Program.splitBlock
    have hn₃ : n₂ ≠ 0 := by omega
    obtain ⟨n₃, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₃
    simp [interp, evalExpr, htargetD2, h₂]
    have hn₄ : n₃ ≠ 0 := by omega
    obtain ⟨n₄, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₄
    simp [interp, evalExpr, updateState]

theorem whileBlock_finds (arr : Array Nat) (target low high i : Nat)
  (hhigh : high ≤ arr.size)
  (h : binarySearch arr target low high hhigh = some i) :
  ∀ mid0 fuel, fuel ≥ ProgramDriver.fullFuel low high →
  interp (Environment.mk arr target) (State.mk low high mid0)
  fuel Program.whileBlock = Result.return_index i := by
  induction low, high, hhigh using binarySearch.induct with
  | target => exact target
  | case1 low high hhigh hlh=>
    unfold binarySearch at h
    split_ifs at h
  | case2 low high hhigh hlh mid hmid htarget =>
    unfold binarySearch at h
    dsimp only at h
    split_ifs at h
    subst mid
    rw [Option.some.injEq] at h
    intro mid0 fuel hfuel
    have hfuel_pos : fuel > 0 := by rw [ProgramDriver.fullFuel] at hfuel; omega
    obtain ⟨n, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (show fuel ≠ 0 by omega)
    unfold Program.whileBlock
    simp only [interp, evalExpr, ne_eq, ite_eq_right_iff, one_ne_zero, imp_false, not_lt, hlh,
      not_false_eq_true, ↓reduceIte]
    have hn : n ≥ 4 := by rw [ProgramDriver.fullFuel] at hfuel; omega
    rw [innerBlock_step arr target low high mid0 n hmid hn]
    simp only [htarget, ↓reduceIte, Result.return_index.injEq]
    exact h
  | case3 low high hhigh hlh mid hmid hne hlt ih =>
    subst mid
    intro mid0 fuel hfuel
    have hn₁ : fuel ≠ 0 := by rw [ProgramDriver.fullFuel] at hfuel; omega
    obtain ⟨n₁, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₁
    unfold Program.whileBlock
    simp only [interp, evalExpr, ne_eq, ite_eq_right_iff, one_ne_zero, imp_false, not_lt, hlh,
      not_false_eq_true, ↓reduceIte]
    have hn : n₁ ≥ 4 := by rw [ProgramDriver.fullFuel] at hfuel; omega
    rw [innerBlock_step arr target low high mid0 n₁ hmid hn]
    simp only [hne, ↓reduceIte, hlt]
    have h_upper : binarySearch arr target ((low + high) / 2 + 1) high hhigh = some i := by
      unfold binarySearch at h
      dsimp only at h
      split_ifs at h
      exact h
    have hfuel_remain : n₁ ≥ ProgramDriver.fullFuel ((low + high) / 2 + 1) high := by
      rw [ProgramDriver.fullFuel]
      rw [ProgramDriver.fullFuel] at hfuel
      omega
    exact (ih h_upper ((low + high) / 2) n₁ ∘ fun a ↦ hfuel_remain) arr
  | case4 low high hhigh hlh mid hmid hne hge ih =>
    subst mid
    intro mid0 fuel hfuel
    have hn₁ : fuel ≠ 0 := by rw [ProgramDriver.fullFuel] at hfuel; omega
    obtain ⟨n₁, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hn₁
    unfold Program.whileBlock
    simp only [interp, evalExpr, ne_eq, ite_eq_right_iff, one_ne_zero, imp_false, not_lt, hlh,
      not_false_eq_true, ↓reduceIte]
    have hn : n₁ ≥ 4 := by rw [ProgramDriver.fullFuel] at hfuel; omega
    rw [innerBlock_step arr target low high mid0 n₁ hmid hn]
    simp only [hne, ↓reduceIte, hge]
    have h_lower : binarySearch arr target low ((low + high) / 2) hmid.le = some i := by
      unfold binarySearch at h
      dsimp only at h
      split_ifs at h
      exact h
    have hfuel_remain : n₁ ≥ ProgramDriver.fullFuel low ((low + high) / 2) := by
      rw [ProgramDriver.fullFuel]
      rw [ProgramDriver.fullFuel] at hfuel
      omega
    exact (ih h_lower ((low + high) / 2) n₁ ∘ fun a ↦ hfuel_remain) arr

theorem whileBlock_none (arr : Array Nat) (target low high : Nat)
  (hhigh : high ≤ arr.size)
  (h : binarySearch arr target low high hhigh = none) :
  ∀ mid0 fuel, fuel ≥ ProgramDriver.fullFuel low high →
  interp (Environment.mk arr target) (State.mk low high mid0)
  fuel Program.whileBlock = Result.return_none := by
  sorry


theorem whileBlock_correct (arr : Array Nat) (target : Nat) (low high : Nat)
  (hhigh : high ≤ arr.size) :
  resultsMatch (interp (Environment.mk arr target) (State.mk low high 0)
  (ProgramDriver.fullFuel low high) Program.whileBlock)
  (binarySearch arr target low high hhigh) := by
  cases h : binarySearch arr target low high hhigh with
  | some i =>
    have hwhile := whileBlock_finds arr target low high i hhigh h 0
      (ProgramDriver.fullFuel low high) (by omega)
    simp [hwhile, resultsMatch]
  | none =>
    have hwhile := whileBlock_none arr target low high hhigh h 0
      (ProgramDriver.fullFuel low high) (by omega)
    simp [hwhile, resultsMatch]

/-! The main theorem: the binary search IR implementation produces the same
result as the native Lean implementation -/
theorem binarySearch_correct (arr : Array Nat) (target : Nat) (hsorted : Sorted arr) :
  resultsMatch (BinarySearch.ProgramDriver.binarySearch arr target)
    (binarySearch arr target 0 arr.size arr.size.le_refl) := by
  sorry

end BinarySearch.ProgramCorrect
