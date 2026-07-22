import BinarySearch.EmitRust
import BinarySearch.Program

/-! Emit Rust code for the BinarySearch program -/

namespace BinarySearch.EmitRustProgram

-- `emitExpr`/`emitStmt` always fully parenthesize and always emit `mut` rather
-- than doing the analysis needed to know when either is unnecessary (see
-- BinarySearch/EmitRust.lean) - both are safe, just sometimes redundant, so
-- silence the resulting warnings instead of teaching the emitter that analysis.
def rustProgram : String :=
  "#![allow(unused_parens, unused_mut)]\n\n" ++
  "pub fn binary_search(arr: &[usize], target: usize) -> Option<usize> {\n" ++
  (EmitRust.emitStmt BinarySearch.Program.binarySearchIR) ++
  "}\n"

end BinarySearch.EmitRustProgram
