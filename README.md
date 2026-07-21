# Certified Binary Search

Some experiments with correctness proofs in Lean. This repo contains a simple
implementation of a binary search algorithm along with a correctness proof. The
repo also includes a **cautionary non-example**: an incorrect binary search
algorithm along with something that might accidentally be mistaken for a
correctness proof.

## Algorithm

The algorithm and its correctness proof are found in
[Basic.lean](BinarySearch/Basic.lean). The algorithm has the call signature:

```lean
def binarySearch (arr : Array Nat) (target low high : Nat)
  (hhigh : high ≤ arr.size) : Option Nat
```

It takes an array of natural numbers, `arr`, a `target` value to search for, two indices, `low` and `high`, that define the search range of indices `[low, high)`, along with a proof that `high ≤ arr.size` (which guarantees every index in the range is in bounds). It returns `some i` if it finds `target` at index `i`, or `none` if it does not find `target`.

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

## Non-Example

It's important to keep in mind that, while Lean can check the correctness of a
proof, it can't check that the proof actually means what we think it means. This
example shows that there is still a conceptual gap separating what Lean can prove
and what we can logically conclude about the algorithm. An example is provided
in [Fake.lean](BinarySearch/Fake.lean).

The search implementation there is absurd: it just always returns `none`. (The
linter warnings have been disabled for this example; in the real world, these
warnings would be a huge red flag that something is wrong. But we can't rely on
the linter to catch all of our logic errors.)

The "correctness theorem" looks identical to the `some` version of the true
algorithm.

```lean
theorem fakeSearch_correct (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (i : Nat) (h : fakeSearch arr target low high hhigh = some i) :
  ∃ (hi : i < arr.size), arr[i] = target
```

It says what we would hope it would say: if the search returns `some i`, then
`arr[i]` is equal to `target`. (The proof is trivial because the hypothesis `h`
asserts an impossible equality: `fakeSearch` always returns `none`, so `h`
claims `none = some i`, which can never happen. Since the hypothesis can never
be satisfied, the implication is vacuously true no matter what it concludes.)
The problem is that it looks like a
correctness proof; the theorem's name even has the word "correct" in it.
Probably this wouldn't get past a mathematician or computer scientist who is
paying attention, but it's a small-scale example of how we still need to apply
reasoning and logic, even when using a proof assistant like Lean.

In this case, a careful reader would notice that the correctness proof is
incomplete. It only shows one direction of the implication: if the algorithm
returns `some i`, then `arr[i] = target`. For correctness, though, we also need
the other direction: if `arr[i] = target` for some index `i`, then the algorithm
should return `some i`. The `fakeSearch` implementation clearly does not have
this property, since it can never return `some i`, so you wouldn't be able to
prove that part in Lean.

## Supporting Our Reasoning

If you look back at the correct algorithm, you'll see that there was some
higher-order reasoning involved in thinking about that proof as well. Notice,
for example, that we didn't explicitly prove the statement that if `arr[i] =
target` for some index `i`, then the algorithm returns `some i`. Instead, we
proved the contrapositive: if the algorithm returns `none`, then `target` is not
in the range.

We can prove an additional theorem that captures this more directly:

```lean
theorem binarySearch_finds (arr : Array Nat) (target : Nat)
  (hsorted : Sorted arr) (h_contains : target ∈ arr) :
  ∃ (i : Nat), binarySearch arr target 0 arr.size arr.size.le_refl = some i
```

This is a little easier to interpret than the `none` case of the correctness
proof. It says more directly that if the array is sorted and contains the
target, then running a search over the whole array will return `some i`. From
the `some` case of the correctness proof, we'll be able to conclude that `arr[i]
= target`. Nevertheless, no matter how many theorems we prove, there will always
be a gap we have to fill ourselves with reasoning and logic.
