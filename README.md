# Certified Binary Search

Some experiments with correctness proofs in Lean, using binary search as a
small test bed.

## Motivation

Automated tests check a program's behavior on whatever specific inputs you
thought to try. A machine-checked proof establishes behavior for _every_ input
of a given shape, not just the ones you enumerated. This repo explores what that
buys you, and what it doesn't. I've chosen binary search because it's a small,
well-known algorithm that's easy to reason about, but also easy to get wrong by
making subtle indexing mistakes (which, of course, I did while implementing
this).


## What's Here

- **Pure Lean implementation and proof**: [`Basic.lean`](BinarySearch/Basic.lean)
- **A cautionary non-example**: [`Fake.lean`](BinarySearch/Fake.lean): an
  incorrect search with a theorem that merely *looks* like a correctness proof
- **A small imperative IR**: [`IR.lean`](BinarySearch/IR.lean),
  [`Interp.lean`](BinarySearch/Interp.lean), [`Program.lean`](BinarySearch/Program.lean)
- **Code emitters** (IR → C++ / Rust):
  [`EmitCpp.lean`](BinarySearch/EmitCpp.lean) / [`EmitCppProgram.lean`](BinarySearch/EmitCppProgram.lean),
  [`EmitRust.lean`](BinarySearch/EmitRust.lean) / [`EmitRustProgram.lean`](BinarySearch/EmitRustProgram.lean)
- **Proof that the IR matches the Lean implementation**: [`ProgramCorrect.lean`](BinarySearch/ProgramCorrect.lean)
- **Generated code plus handwritten tests**, compiled and run in CI:
  [`emit/cpp`](emit/cpp), [`emit/rust`](emit/rust)

## Preview

The repo contains essentially two implementations of binary search: a pure, recursive, Lean version, and an imperative version expressed in a small intermediate representation (IR). The IR can be emulated in Lean and emitted to C++ and Rust. The correctness proof shows that the IR implementation matches the Lean version.

Here are the Lean version and the two emitted versions of binary search.

```lean
def binarySearch (arr : Array Nat) (target low high : Nat)
  (hhigh : high ≤ arr.size) : Option Nat :=
if hlh : low ≥ high then
  none
else
  let mid := low + (high - low) / 2
  have hmid : mid < arr.size := by omega
  if arr[mid] = target then
    some mid
  else if arr[mid] < target then
    binarySearch arr target (mid+1) high hhigh
  else
    binarySearch arr target low mid hmid.le
```

```cpp
std::optional<size_t> binary_search(const std::vector<size_t> &arr,
                                    size_t target) {
  size_t low = 0;
  size_t high = arr.size();
  while ((low < high)) {
    size_t mid = (low + ((high - low) / 2));
    if ((arr[mid] == target)) {
      return mid;
    } else {
      if ((arr[mid] < target)) {
        low = (mid + 1);
      } else {
        high = mid;
      }
    }
  }
  return std::nullopt;
}
```

```rust
pub fn binary_search(arr: &[usize], target: usize) -> Option<usize> {
    let mut low: usize = 0;
    let mut high: usize = arr.len();
    while (low < high) {
        let mut mid: usize = (low + ((high - low) / 2));
        if (arr[mid] == target) {
            return Some(mid);
        } else {
            if (arr[mid] < target) {
                low = (mid + 1);
            } else {
                high = mid;
            }
        }
    }
    return None;
}
```

The C++ and Rust aren't hand-translated, they come from the emitters in this
repo, and are generated from the same IR that the correctness proof below is
stated against. Note the midpoint is computed as `low + (high - low) / 2` rather
than `(low + high) / 2`. This avoids the [classic binary-search overflow
bug](https://research.google/blog/extra-extra-read-all-about-it-nearly-all-binary-searches-and-mergesorts-are-broken/),
guarded against here because it would actually matter in the fixed-width
`size_t`/`usize` arithmetic, unlike Lean's arbitrary-precision `Nat`.

## Pure Lean Version

```lean
def binarySearch (arr : Array Nat) (target low high : Nat)
  (hhigh : high ≤ arr.size) : Option Nat
```

Searches `arr[low, high)` for `target`: `some i` if found at index `i`,
`none` otherwise.

The correctness proof is split into two theorems:

> **Theorem 1: `binarySearch_some`** If the search returns `some i`, `arr[i]`
> really is `target`.

```lean
theorem binarySearch_some (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (i : Nat) (h : binarySearch arr target low high hhigh = some i) :
  ∃ (hi : i < arr.size), arr[i] = target
```

> **Theorem 2: `binarySearch_none`** If the search returns `none` on a sorted
> array, `target` isn't in `[low, high)`.

```lean
theorem binarySearch_none (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (hsorted : Sorted arr) (h : binarySearch arr target low high hhigh = none) :
  ¬ InRange arr target low high
```

See [`Basic.lean`](BinarySearch/Basic.lean) for the full development,
including the `Sorted`/`InRange` definitions and the `split_InRange` lemma the proofs are built on.

> [!NOTE] 
> It's interesting to think about why `binarySearch_none` needs the `Sorted`
> hypothesis while `binarySearch_some` does not. 

If the pair of theorems above don't feel intuitive to you, there's a third
theorem in [`Basic.lean`](BinarySearch/Basic.lean) that states the
contrapositive of the second result in a way that doesn't rely on the `InRange`
predicate.

> **Theorem 3: `binarySearch_finds`** If the array is sorted and contains
> `target`, `binarySearch` will find it.

```lean
theorem binarySearch_finds (arr : Array Nat) (target : Nat)
  (hsorted : Sorted arr) (h_contains : target ∈ arr) :
  ∃ (i : Nat), binarySearch arr target 0 arr.size arr.size.le_refl = some i
```

## IR Program

The Lean implementation is elegant, but it's not easy to directly translate it
into an efficient C++ or Rust implementation due to the recursion and the proof
obligations. This part of the project demonstrates how to generate imperative
code from the same algorithm, and prove *that* matches the reference
implementation too.

- **IR** ([`IR.lean`](BinarySearch/IR.lean)) — a tiny imperative language:
  variable declare/assign, `if`, one `while` loop, early return. It's not a general-purpose language. It's not even a very good language. The interesting thing here is that we don't need to reason about all possible programs expressible in the IR, we just need it for this one program.
- **Interpreter** ([`Interp.lean`](BinarySearch/Interp.lean)) — a fuel-bounded
  evaluator for the IR. This encodes the IR semantics. When we reason about the IR program, we do it through the interpreter.
- **Program** ([`Program.lean`](BinarySearch/Program.lean),
  [`ProgramDriver.lean`](BinarySearch/ProgramDriver.lean)) — binary search
  assembled from IR statements. This is the _only_ program in the IR that we reason about.
- **Emitters** ([`EmitCpp.lean`](BinarySearch/EmitCpp.lean) /
  [`EmitCppProgram.lean`](BinarySearch/EmitCppProgram.lean),
  [`EmitRust.lean`](BinarySearch/EmitRust.lean) /
  [`EmitRustProgram.lean`](BinarySearch/EmitRustProgram.lean)) — pretty-print
  the IR plus some scaffolding to C++ and Rust source. The snippets in the
  preview above come directly from the emitters.
- **Correctness proof** ([`ProgramCorrect.lean`](BinarySearch/ProgramCorrect.lean))
  — `binarySearch_correct` ties it together:

  ```lean
  theorem binarySearch_correct (arr : Array Nat) (target : Nat) :
    resultsMatch (ProgramDriver.binarySearch arr target)
      (binarySearch arr target 0 arr.size arr.size.le_refl)
  ```

  It says that interpreting the IR program through the Lean interpreter produces
  the same result as `Basic.binarySearch`.

> [!WARNING] 
> The proof applies only to the IR interpreter's semantics, not g++'s or
> rustc's, so there's still a gap. But by proving the IR program correct, we've
> narrowed the gap. Now, instead of reasoning about the correctness of the C++
> or Rust code as a whole (loop invariants, bounds checking, index correctness,
> etc.), we only need to reason about the correctness of the emitters and trust
> that the compilers do what they're supposed to do.

As an extra precaution, it doesn't hurt to run the emitted code against some
test cases. This provides empirical evidence that the emitters and compilers do
what we expect. The Makefile targets `make test-cpp` and `make test-rust`
compile and run the emitted code against the same test cases, and CI does this
on every push.

## Proofs Narrow the Gap, They Don't Remove It

If you like thinking about the gap between "Lean says this is correct" and "this
is correct," you might like to look at the example in
[`Fake.lean`](BinarySearch/Fake.lean). It's an (admittedly silly) example of how
a Lean proof can be valid but meaningless.

```lean
theorem fakeSearch_correct (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (i : Nat) (h : fakeSearch arr target low high hhigh = some i) :
  ∃ (hi : i < arr.size), arr[i] = target
```

It says that if `fakeSearch` returns `some i`, then `arr[i]` is `target`, which
sounds pretty promising until you realize that `fakeSearch` is a bogus
implementation that always returns `none`. Lean can verify our "correctness"
proof, but it can't tell us about the logical gap: a true correctness proof
needs to handle the converse as well.
