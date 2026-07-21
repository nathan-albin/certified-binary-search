import BinarySearch.IR

/-! Interpreter for the IR grammar defined in IR.lean -/

namespace BinarySearch.Interp

open BinarySearch.IR.Expr BinarySearch.IR.Stmt BinarySearch.IR.Var

structure State where
  low : Nat
  high : Nat
  mid : Nat
  deriving BEq

structure Environment where
  arr : Array Nat
  target : Nat

inductive Result where
  | success (newState : State) : Result
  | return_index (i : Nat) : Result
  | return_none : Result
  | out_of_fuel : Result
  deriving BEq

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

def updateState (state : State) (v : IR.Var) (value : Nat) : State :=
  match v with
  | low => { state with low := value }
  | high => { state with high := value }
  | mid => { state with mid := value }

def interp (env : Environment) (state : State) : Nat → IR.Stmt → Result
  | 0, _ => Result.out_of_fuel
  | n+1, stmt =>
    match stmt with
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
