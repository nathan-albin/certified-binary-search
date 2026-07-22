import BinarySearch.IR

/-! Emit Rust code from the IR -/

namespace BinarySearch.EmitRust

open BinarySearch.IR.Expr BinarySearch.IR.Stmt BinarySearch.IR.Var

/-- Renders an IR expression as a Rust expression. -/
def emitExpr : IR.Expr → String
  | var low => "low"
  | var high => "high"
  | var mid => "mid"
  | target => "target"
  | literal n => toString n
  | add e1 e2 => "(" ++ (emitExpr e1) ++ " + " ++  (emitExpr e2) ++ ")"
  | sub e1 e2 => "(" ++ (emitExpr e1) ++ " - " ++ (emitExpr e2) ++ ")"
  | div e1 e2 => "(" ++ (emitExpr e1) ++ " / " ++ (emitExpr e2) ++ ")"
  | array_get e => "arr[" ++ (emitExpr e) ++ "]"
  | array_len => "arr.len()"
  | less_than e1 e2 => "(" ++ (emitExpr e1) ++ " < " ++ (emitExpr e2) ++ ")"
  | equal e1 e2 => "(" ++ (emitExpr e1) ++ " == " ++ (emitExpr e2) ++ ")"

/-- Renders an IR variable as the name of its Rust counterpart. -/
def emitVar : IR.Var → String
  | low => "low"
  | high => "high"
  | mid => "mid"

/-- Renders an IR statement as a block of Rust statements.

`low`/`high`/`mid` are declared once (with `mut`, since every one of them gets
reassigned later) and only ever plainly reassigned after that - see `declare`
vs `assign` below. No variable needs a fresh `let` per loop iteration. -/
def emitStmt : IR.Stmt → String
  | declare v expr => "let mut " ++ (emitVar v) ++ ": usize = " ++ (emitExpr expr) ++ ";\n"
  | assign v expr => (emitVar v) ++ " = " ++ (emitExpr expr) ++ ";\n"
  | if_then cond thenStmt elseStmt =>
    "if " ++ (emitExpr cond) ++ " {\n" ++ (emitStmt thenStmt) ++ "} else {\n" ++ (emitStmt elseStmt) ++ "}\n"
  | while_do cond body =>
    "while " ++ (emitExpr cond) ++ " {\n" ++ (emitStmt body) ++ "}\n"
  | return_index expr => "return Some(" ++ (emitExpr expr) ++ ");\n"
  | return_none => "return None;\n"
  | seq stmt1 stmt2 => (emitStmt stmt1) ++ (emitStmt stmt2)

end BinarySearch.EmitRust
