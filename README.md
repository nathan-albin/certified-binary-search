# Certified Binary Search

Simple implementation of binary search in Lean along with a correctness proof.

## Algorithm

The algorithm has the call signature:

```lean
def binarySearch (arr : Array Nat) (target low high : Nat)
  (hhigh : high ≤ arr.size) : Option Nat
```

It takes an array of natural numbers, `arr`, a `target` value to search for, two indices, `low` and `high`, that define the search range of indices `[low, high)`, along with a proof that all indices in the range are in bounds. It returns `some i` if it finds `target` at index `i`, or `none` if it does not find `target`.

> [!IMPORTANT]
> The search algorithm does not require the array to be sorted; however, the
> correctness proof does require that the array is sorted in non-decreasing
> order. The search will operate on an unsorted array, but will not necessarily
> find the target if it is present.

> [!NOTE] 
> This is a quick-and-dirty implementation, with room for improvement. For
> example, some of the bounds checking could be removed by `Fin arr.size`. The
> use of `Nat` felt more natural for teaching purposes.

## Correctness Proof

The correctness proof is constructed in two pieces, depending on which branch of `Option` is returned. The proofs are built using two property `def`s. `Sorted arr` states that `arr` is sorted in non-decreasing order. `InRange arr target low high` states that the value `target` occurs somewhere in the range of indices `[low, high)` of `arr`.

There's also a helper lemma `split_InRange` that sets up a helpful trichotomy: it states that if `target` is in the range and if we pick an index `mid` then one of the following must be true.

- `target` is at index `mid`
- `target` is in the left half of the range `[low, mid)`
- `target` is in the right half of the range `[mid + 1, high)`

The two halves of the correctness proof are as follows.

### Some Case

This says that if the search returns `some i`, then `arr[i]` is equal to `target`.

```lean
theorem binarySearch_some (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (i : Nat) (h : binarySearch arr target low high hhigh = some i) :
  ∃ (hi : i < arr.size), arr[i] = target
```

### None Case

On the other hand, if the search returns `none`, then `target` is not in the array between the low and high indices. Interestingly, this is the only part that needs the sortedness assumption. This is essentially the difference between a proof of existence and a proof of non-existence. In the `some i` case, we have an actual index `i` to work with. In the `none` case, we have to reason about all indices in the range.

```lean
theorem binarySearch_none (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (hsorted : Sorted arr) (h : binarySearch arr target low high hhigh = none) :
  ¬ InRange arr target low high
```