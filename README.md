# Certified Binary Search

Some experiments with correctness proofs in Lean, using binary search as a
small testbed.

## Motivation

Automated tests check a program's behavior on whatever specific inputs you
thought to try. A machine-checked proof establishes behavior for _every_ input
of a given shape, not just the ones you enumerated. This repo explores what that
buys you, and what it doesn't. 

I've chosen binary search because it's a small, well-known algorithm that's easy
to reason about, but also easy to get wrong by making subtle indexing mistakes.


## What's Here

- **Pure Lean implementation and proof** — [`Basic.lean`](BinarySearch/Basic.lean)
- **A cautionary non-example** — [`Fake.lean`](BinarySearch/Fake.lean): an
  incorrect search with a theorem that merely *looks* like a correctness proof
- **A small imperative IR** — [`IR.lean`](BinarySearch/IR.lean),
  [`Interp.lean`](BinarySearch/Interp.lean), [`Program.lean`](BinarySearch/Program.lean)
- **Code emitters** (IR → C++ / Rust) —
  [`EmitCpp.lean`](BinarySearch/EmitCpp.lean) / [`EmitCppProgram.lean`](BinarySearch/EmitCppProgram.lean),
  [`EmitRust.lean`](BinarySearch/EmitRust.lean) / [`EmitRustProgram.lean`](BinarySearch/EmitRustProgram.lean)
- **Proof that the IR matches the Lean implementation** — [`ProgramCorrect.lean`](BinarySearch/ProgramCorrect.lean)
- **Generated code plus hand-written tests**, compiled and run in CI —
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
  let mid := (low + high) / 2
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
    size_t mid = ((low + high) / 2);
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
        let mut mid: usize = ((low + high) / 2);
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
stated against.

## Pure Lean Version

```lean
def binarySearch (arr : Array Nat) (target low high : Nat)
  (hhigh : high ≤ arr.size) : Option Nat
```

Searches `arr[low, high)` for `target`: `some i` if found at index `i`,
`none` otherwise.

Two theorems carry the correctness argument:

```lean
theorem binarySearch_some (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (i : Nat) (h : binarySearch arr target low high hhigh = some i) :
  ∃ (hi : i < arr.size), arr[i] = target
```
If the search returns `some i`, `arr[i]` really is `target`.

```lean
theorem binarySearch_none (arr : Array Nat) (target low high : Nat) (hhigh : high ≤ arr.size)
  (hsorted : Sorted arr) (h : binarySearch arr target low high hhigh = none) :
  ¬ InRange arr target low high
```
If the search returns `none` on a sorted array, `target` genuinely isn't in
`[low, high)`. A third theorem, `binarySearch_finds`, restates this more
intuitively: a sorted array containing `target` is guaranteed to return
`some i`.

See [`Basic.lean`](BinarySearch/Basic.lean) for the full development,
including the `Sorted`/`InRange` definitions and the `split_InRange` lemma the
proofs are built on.

## IR Program

The Lean implementation is elegant, but it's not easy to directly translate it
into an efficient C++ or Rust implementation due to the recursion and the proof
obligations. This part of the project demonstrates how to generate imperative
code from the same algorithm, and prove *that* matches the reference
implementation too?

- **IR** ([`IR.lean`](BinarySearch/IR.lean)) — a tiny imperative language:
  variable declare/assign, `if`, one `while` loop, early return. Just enough
  to express binary search.
- **Interpreter** ([`Interp.lean`](BinarySearch/Interp.lean)) — a fuel-bounded
  evaluator for the IR; this defines the semantics of the IR that are used in
  the correctness proof.
- **Program** ([`Program.lean`](BinarySearch/Program.lean),
  [`ProgramDriver.lean`](BinarySearch/ProgramDriver.lean)) — binary search
  assembled from IR statements.
- **Emitters** ([`EmitCpp.lean`](BinarySearch/EmitCpp.lean) /
  [`EmitCppProgram.lean`](BinarySearch/EmitCppProgram.lean),
  [`EmitRust.lean`](BinarySearch/EmitRust.lean) /
  [`EmitRustProgram.lean`](BinarySearch/EmitRustProgram.lean)) — pretty-print
  the IR to C++ and Rust source. The snippets in the preview above are their
  actual output.
- **Correctness proof** ([`ProgramCorrect.lean`](BinarySearch/ProgramCorrect.lean))
  — `binarySearch_correct` ties it together:

  ```lean
  theorem binarySearch_correct (arr : Array Nat) (target : Nat) :
    resultsMatch (ProgramDriver.binarySearch arr target)
      (binarySearch arr target 0 arr.size arr.size.le_refl)
  ```

  Interpreting the IR program produces the same result as `Basic.binarySearch`.

That proof covers the IR *interpreter's* semantics, not g++'s or rustc's. As
usual with formalization, there's a gap; what we've done is narrowed it. We
don't have to reason about the correctness of the C++ or Rust code as a whole,
we just have to reason about the correctness of the emitters (and trust that the compiler does what it's supposed to do).

To help close that remaining gap empirically rather than formally, `make
test-cpp` and `make test-rust` compile and run the emitted code against the same
test cases, and CI does this on every push.

## Proofs Narrow the Gap — They Don't Remove It

[`Fake.lean`](BinarySearch/Fake.lean) is a small cautionary tale: `fakeSearch`
always returns `none`, yet its "correctness theorem" type-checks trivially,
because the hypothesis it's proving from can never be satisfied. Lean can check
that a proof is *valid*; it can't check that the statement you wrote down means
what you think it means.

Every layer added here (the interpreter, the emitters, the compiled-code tests)
narrows the gap between "Lean says this is correct" and "this is correct." None
of them close it completely. There's always some boundary (a specification, an
interpreter's semantics, a compiler's behavior) that has to be trusted, or
checked some other way.
