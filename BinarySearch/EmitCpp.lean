import BinarySearch.IR

/-! Emit C++ code from the IR -/

namespace BinarySearch.EmitCpp

open BinarySearch.IR.Expr BinarySearch.IR.Stmt BinarySearch.IR.Var

/-- Renders an IR expression as a C++ expression. -/
def emitExpr : IR.Expr → String
  | var low => "low"
  | var high => "high"
  | var mid => "mid"
  | target => "target"
  | literal n => toString n
  | add e1 e2 => "(" ++ (emitExpr e1) ++ " + " ++  (emitExpr e2) ++ ")"
  | div e1 e2 => "(" ++ (emitExpr e1) ++ " / " ++ (emitExpr e2) ++ ")"
  | array_get e => "arr[" ++ (emitExpr e) ++ "]"
  | array_len => "arr.size()"
  | less_than e1 e2 => "(" ++ (emitExpr e1) ++ " < " ++ (emitExpr e2) ++ ")"
  | equal e1 e2 => "(" ++ (emitExpr e1) ++ " == " ++ (emitExpr e2) ++ ")"

/-- Renders an IR variable as the name of its C++ counterpart. -/
def emitVar : IR.Var → String
  | low => "low"
  | high => "high"
  | mid => "mid"

/-- Renders an IR statement as a block of C++ statements. -/
def emitStmt : IR.Stmt → String
  | declare v expr => "size_t " ++ (emitVar v) ++ " = " ++ (emitExpr expr) ++ ";\n"
  | assign v expr => (emitVar v) ++ " = " ++ (emitExpr expr) ++ ";\n"
  | if_then cond thenStmt elseStmf =>
    "if (" ++ (emitExpr cond) ++ ") {\n" ++ (emitStmt thenStmt) ++ "} else {\n" ++ (emitStmt elseStmf) ++ "}\n"
  | while_do cond body =>
    "while (" ++ (emitExpr cond) ++ ") {\n" ++ (emitStmt body) ++ "}\n"
  | return_index expr => "return " ++ (emitExpr expr) ++ ";\n"
  | return_none => "return std::nullopt;\n"
  | seq stmt1 stmt2 => (emitStmt stmt1) ++ (emitStmt stmt2)

end BinarySearch.EmitCpp
