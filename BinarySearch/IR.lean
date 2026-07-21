/-! Defines a simple intermediate representation to transport the binary search algorithm to imperative code.-/

namespace BinarySearch.IR

inductive Var where
  | low : Var
  | high : Var
  | mid : Var

inductive Expr where
  | var : Var → Expr
  | target : Expr
  | literal : Nat → Expr
  | add : Expr → Expr → Expr
  | div : Expr → Expr → Expr
  | array_get : Expr → Expr
  | array_len : Expr
  | less_than : Expr → Expr → Expr
  | equal : Expr → Expr → Expr

inductive Stmt where
  | assign : Var → Expr → Stmt
  | if_then : Expr → Stmt → Stmt → Stmt
  | while_do : Expr → Stmt → Stmt
  | return_index : Expr → Stmt
  | return_none : Stmt
  | seq : Stmt → Stmt → Stmt

open Var Expr Stmt

infixr:50 " ;; " => Stmt.seq

def initBlock : Stmt :=
  assign low (literal 0) ;;
  assign high array_len ;;
  assign mid (literal 0)

def splitBlock : Stmt :=
  if_then (less_than (array_get (var mid)) target)
    (assign low (add (var mid) (literal 1)))
    (assign high (var mid))

def innerBlock : Stmt :=
  assign mid (div (add (var low) (var high)) (literal 2)) ;;
  if_then (equal (array_get (var mid)) target)
    (return_index (var mid))
    (splitBlock)

def binarySearchIR : Stmt :=
  initBlock ;;
  while_do (less_than (var low) (var high)) innerBlock ;;
  return_none

end BinarySearch.IR
