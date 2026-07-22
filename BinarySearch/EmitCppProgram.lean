import BinarySearch.EmitCpp
import BinarySearch.Program

/-! Emit C++ code for the BinarySearch program -/

namespace BinarySearch.EmitCppProgram

def cppProgram : String :=
  "#include <vector>\n#include <optional>\n\n" ++
  "std::optional<size_t> binary_search(const std::vector<size_t>& arr, size_t target) {\n" ++
  (EmitCpp.emitStmt BinarySearch.Program.binarySearchIR) ++
  "}\n"

end BinarySearch.EmitCppProgram
