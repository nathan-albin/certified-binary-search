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

infixr:50 " ;; " => Stmt.seq

end BinarySearch.IR
