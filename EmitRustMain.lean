import BinarySearch.EmitRustProgram

/-! Executable entry point that writes the emitted Rust source to disk. -/

def outputPath : System.FilePath := "emit/rust/src/lib.rs"

def main : IO Unit := do
  IO.FS.createDirAll "emit/rust/src"
  IO.FS.writeFile outputPath BinarySearch.EmitRustProgram.rustProgram
  IO.println s!"Wrote {outputPath}"
