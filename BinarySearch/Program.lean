import BinarySearch.IR

/-! IR implementation of the binary search algorithm. -/

namespace BinarySearch.Program

open BinarySearch.IR.Var BinarySearch.IR.Expr BinarySearch.IR.Stmt

def initBlock : IR.Stmt :=
  assign low (literal 0) ;;
  assign high array_len ;;
  assign mid (literal 0)

def splitBlock : IR.Stmt :=
  if_then (less_than (array_get (var mid)) target)
    (assign low (add (var mid) (literal 1)))
    (assign high (var mid))

def innerBlock : IR.Stmt :=
  assign mid (div (add (var low) (var high)) (literal 2)) ;;
  if_then (equal (array_get (var mid)) target)
    (return_index (var mid))
    (splitBlock)

def binarySearchIR : IR.Stmt :=
  initBlock ;;
  while_do (less_than (var low) (var high)) innerBlock ;;
  return_none

end BinarySearch.Program
