/-! Defines a simple intermediate representation to transport the binary search algorithm to imperative code.-/

namespace BinarySearch.IR

/-- The mutable variables available to an IR program. -/
inductive Var where
  /-- The lower bound of the current search interval. -/
  | low : Var
  /-- The upper bound (exclusive) of the current search interval. -/
  | high : Var
  /-- The midpoint of the current search interval. -/
  | mid : Var

/-- Expressions that can be evaluated in the IR, given an environment
(the array and search target) and a state (the current variable values). -/
inductive Expr where
  /-- Reads the current value of a variable. -/
  | var : Var → Expr
  /-- The search target, read from the environment. -/
  | target : Expr
  /-- A constant natural number. -/
  | literal : Nat → Expr
  /-- Addition of two expressions. -/
  | add : Expr → Expr → Expr
  /-- Natural-number (floor) division of two expressions. -/
  | div : Expr → Expr → Expr
  /-- Reads the array at the index given by an expression. -/
  | array_get : Expr → Expr
  /-- The length of the array, read from the environment. -/
  | array_len : Expr
  /-- `1` if the first expression is less than the second, else `0`. -/
  | less_than : Expr → Expr → Expr
  /-- `1` if the two expressions are equal, else `0`. -/
  | equal : Expr → Expr → Expr

/-- Statements in the IR, forming a small imperative language of variable
declarations/assignments, conditionals, a single while loop, and early
returns. -/
inductive Stmt where
  /-- Introduces a new variable bound to the value of an expression. -/
  | declare : Var → Expr → Stmt
  /-- Overwrites an existing variable with the value of an expression. -/
  | assign : Var → Expr → Stmt
  /-- Runs one of two branches depending on whether the condition is nonzero. -/
  | if_then : Expr → Stmt → Stmt → Stmt
  /-- Repeats the body while the condition is nonzero. -/
  | while_do : Expr → Stmt → Stmt
  /-- Returns successfully with the index given by an expression. -/
  | return_index : Expr → Stmt
  /-- Returns to indicate the target was not found. -/
  | return_none : Stmt
  /-- Runs the first statement, then the second. -/
  | seq : Stmt → Stmt → Stmt

/-- Sequential composition of two statements. -/
infixr:50 " ;; " => Stmt.seq

end BinarySearch.IR
