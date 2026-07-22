.PHONY: emit-cpp test-cpp emit-rust test-rust test clean

CXX ?= g++
CXXFLAGS ?= -std=c++17 -Wall -Wextra
CLANG_FORMAT ?= clang-format
CARGO ?= cargo

EMIT_CPP_DIR := emit/cpp
GENERATED_CPP := $(EMIT_CPP_DIR)/generated/binary_search.cpp
CPP_HARNESS := $(EMIT_CPP_DIR)/test_main.cpp
CPP_RUNNER := $(EMIT_CPP_DIR)/run_tests

EMIT_RUST_DIR := emit/rust
GENERATED_RUST := $(EMIT_RUST_DIR)/src/lib.rs

# Regenerate the C++ source from the Lean IR, then format it for readability
# (emitStmt itself doesn't track indentation - the output is correct but flat).
emit-cpp:
	lake exe emit_cpp
	@if $(CLANG_FORMAT) --version >/dev/null 2>&1; then \
		$(CLANG_FORMAT) -i $(GENERATED_CPP); \
	else \
		echo "warning: '$(CLANG_FORMAT)' not found on PATH - skipping formatting (emitted C++ is still correct, just unformatted)"; \
	fi

# Regenerate, compile, and run the C++ tests.
test-cpp: emit-cpp
	$(CXX) $(CXXFLAGS) -o $(CPP_RUNNER) $(GENERATED_CPP) $(CPP_HARNESS)
	./$(CPP_RUNNER)

# Regenerate the Rust source from the Lean IR, then format it for readability
# (same reasoning as emit-cpp above).
emit-rust:
	lake exe emit_rust
	@if $(CARGO) fmt --version >/dev/null 2>&1; then \
		$(CARGO) fmt --manifest-path $(EMIT_RUST_DIR)/Cargo.toml; \
	else \
		echo "warning: 'cargo fmt' not available - skipping formatting (emitted Rust is still correct, just unformatted)"; \
	fi

# Regenerate and run the Rust tests (tests/binary_search_test.rs, via cargo's
# own idiomatic test runner - no hand-rolled harness needed).
test-rust: emit-rust
	$(CARGO) test --manifest-path $(EMIT_RUST_DIR)/Cargo.toml

# Umbrella target for all emitted-language test suites.
test: test-cpp test-rust

clean:
	rm -f $(GENERATED_CPP) $(CPP_RUNNER)
	rm -f $(GENERATED_RUST)
	rm -rf $(EMIT_RUST_DIR)/target
