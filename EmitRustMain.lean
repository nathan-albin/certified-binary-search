import BinarySearch.EmitRustProgram

/-! Executable entry point that writes the emitted Rust source to disk. -/

/-- Where the generated Rust source is written. -/
def outputPath : System.FilePath := "emit/rust/src/lib.rs"

/-- Writes `EmitRustProgram.rustProgram` to `outputPath`. -/
def main : IO Unit := do
  IO.FS.createDirAll "emit/rust/src"
  IO.FS.writeFile outputPath BinarySearch.EmitRustProgram.rustProgram
  IO.println s!"Wrote {outputPath}"
