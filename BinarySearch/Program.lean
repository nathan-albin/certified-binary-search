import BinarySearch.IR

/-! IR implementation of the binary search algorithm. -/

namespace BinarySearch.Program

open BinarySearch.IR.Var BinarySearch.IR.Expr BinarySearch.IR.Stmt

/-- Declares `low := 0` and `high := arr.size`, initializing the search
interval to cover the whole array. -/
def initBlock : IR.Stmt :=
  declare low (literal 0) ;;
  declare high array_len

/-- Given the midpoint has already been compared against `target` and found
unequal, narrows the search interval: raises `low` past `mid` if `arr[mid]` is
too small, otherwise lowers `high` to `mid`. -/
def splitBlock : IR.Stmt :=
  if_then (less_than (array_get (var mid)) target)
    (assign low (add (var mid) (literal 1)))
    (assign high (var mid))

/-- One iteration of the search: computes the midpoint, returns its index if
it matches `target`, otherwise narrows the interval via `splitBlock`.

The midpoint is computed as `low + (high - low) / 2` rather than
`(low + high) / 2`, to avoid overflow in the fixed-width `size_t`/`usize`
arithmetic used by the emitted C++ and Rust - the classic binary-search
overflow bug. -/
def innerBlock : IR.Stmt :=
  declare mid (add (var low) (div (sub (var high) (var low)) (literal 2))) ;;
  if_then (equal (array_get (var mid)) target)
    (return_index (var mid))
    (splitBlock)

/-- Repeats `innerBlock` while the search interval `[low, high)` is
nonempty. -/
def loopBlock : IR.Stmt :=
  while_do (less_than (var low) (var high)) innerBlock

/-- Runs the search loop, returning "not found" if it exits without ever
returning an index. -/
def whileBlock : IR.Stmt :=
  loopBlock ;;
  return_none

/-- The full binary search program: initialize the interval to the whole
array, then search it. -/
def binarySearchIR : IR.Stmt :=
  initBlock ;;
  whileBlock

end BinarySearch.Program
