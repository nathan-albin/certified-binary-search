import BinarySearch.IR

/-! IR implementation of the binary search algorithm. -/

namespace BinarySearch.Program

open BinarySearch.IR.Var BinarySearch.IR.Expr BinarySearch.IR.Stmt

def initBlock : IR.Stmt :=
  declare low (literal 0) ;;
  declare high array_len

def splitBlock : IR.Stmt :=
  if_then (less_than (array_get (var mid)) target)
    (assign low (add (var mid) (literal 1)))
    (assign high (var mid))

def innerBlock : IR.Stmt :=
  declare mid (div (add (var low) (var high)) (literal 2)) ;;
  if_then (equal (array_get (var mid)) target)
    (return_index (var mid))
    (splitBlock)

def loopBlock : IR.Stmt :=
  while_do (less_than (var low) (var high)) innerBlock

def whileBlock : IR.Stmt :=
  loopBlock ;;
  return_none

def binarySearchIR : IR.Stmt :=
  initBlock ;;
  whileBlock

end BinarySearch.Program
