import BinarySearch.Basic
import BinarySearch.EmitCpp
import BinarySearch.EmitCppProgram
import BinarySearch.EmitRust
import BinarySearch.EmitRustProgram
import BinarySearch.Fake
import BinarySearch.Interp
import BinarySearch.IR
import BinarySearch.Program
import BinarySearch.ProgramCorrect
import BinarySearch.ProgramDriver
import BinarySearch.ProgramTest

/-! Root module that imports every component of the project: the reference
Lean implementation and its proofs, the IR and its interpreter, the IR
correctness proof, the code emitters, and their tests. -/
