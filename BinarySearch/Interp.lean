import BinarySearch.IR

/-! Interpreter for the IR grammar defined in IR.lean -/

namespace BinarySearch.Interp

open BinarySearch.IR.Expr BinarySearch.IR.Stmt BinarySearch.IR.Var

/-- The mutable variables of a running IR program: the current search
interval `[low, high)` and the most recently computed midpoint. -/
structure State where
  low : Nat
  high : Nat
  mid : Nat
  deriving BEq, Repr

/-- The read-only context a program runs against: the array being searched
and the value being searched for. -/
structure Environment where
  arr : Array Nat
  target : Nat

/-- The outcome of interpreting a statement: either it ran to completion and
produced a new state, it returned (with or without a found index), or it ran
out of fuel before reaching a `return`. -/
inductive Result where
  /-- The statement ran to completion, producing an updated state. -/
  | success (newState : State) : Result
  /-- The program returned, having found `target` at index `i`. -/
  | return_index (i : Nat) : Result
  /-- The program returned, having determined `target` is not present. -/
  | return_none : Result
  /-- Fuel was exhausted before the statement finished running. -/
  | out_of_fuel : Result
  deriving BEq, Repr

/-- Evaluates an IR expression to a `Nat`, given the environment and current
state. -/
def evalExpr (env : Environment) (state : State) : IR.Expr → Nat
  | var low => state.low
  | var high => state.high
  | var mid => state.mid
  | target => env.target
  | literal n => n
  | add e1 e2 => (evalExpr env state e1) + (evalExpr env state e2)
  | div e1 e2 => (evalExpr env state e1) / (evalExpr env state e2)
  | array_get e => env.arr.getD (evalExpr env state e) 0
  | array_len => env.arr.size
  | less_than e1 e2 => if (evalExpr env state e1) < (evalExpr env state e2) then 1 else 0
  | equal e1 e2 => if (evalExpr env state e1) = (evalExpr env state e2) then 1 else 0

/-- Overwrites the given variable of a state with a new value. -/
def updateState (state : State) (v : IR.Var) (value : Nat) : State :=
  match v with
  | low => { state with low := value }
  | high => { state with high := value }
  | mid => { state with mid := value }

/-- Runs a statement in an environment starting from a given state, using
`fuel` as a step-count bound so that the recursion through `while_do` is
structural. Returns `Result.out_of_fuel` if the statement (in particular, a
loop) does not finish within that many steps. -/
def interp (env : Environment) (state : State) : Nat → IR.Stmt → Result
  | 0, _ => Result.out_of_fuel
  | n+1, stmt =>
    match stmt with
    | declare v expr =>
        let value := evalExpr env state expr
        let newState := updateState state v value
        Result.success newState
    | assign v expr =>
        let value := evalExpr env state expr
        let newState := updateState state v value
        Result.success newState
    | if_then cond thenStmt elseStmt =>
        let condValue := evalExpr env state cond
        if condValue ≠ 0 then interp env state n thenStmt
        else interp env state n elseStmt
    | while_do cond body =>
        let condValue := evalExpr env state cond
        if condValue ≠ 0 then
          match interp env state n body with
          | Result.success newState => interp env newState n (while_do cond body)
          | Result.return_index i => Result.return_index i
          | Result.return_none => Result.return_none
          | Result.out_of_fuel => Result.out_of_fuel
        else Result.success state
    | return_index expr =>
        let index := evalExpr env state expr
        Result.return_index index
    | return_none => Result.return_none
    | seq stmt1 stmt2 =>
        match interp env state n stmt1 with
        | Result.success newState => interp env newState n stmt2
        | Result.return_index i => Result.return_index i
        | Result.return_none => Result.return_none
        | Result.out_of_fuel => Result.out_of_fuel

end BinarySearch.Interp
