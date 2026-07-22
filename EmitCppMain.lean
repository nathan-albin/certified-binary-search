import BinarySearch.EmitCppProgram

/-! Executable entry point that writes the emitted C++ source to disk. -/

/-- Where the generated C++ source is written. -/
def outputPath : System.FilePath := "emit/cpp/generated/binary_search.cpp"

/-- Writes `EmitCppProgram.cppProgram` to `outputPath`. -/
def main : IO Unit := do
  IO.FS.createDirAll "emit/cpp/generated"
  IO.FS.writeFile outputPath BinarySearch.EmitCppProgram.cppProgram
  IO.println s!"Wrote {outputPath}"
