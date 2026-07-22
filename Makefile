.PHONY: emit-cpp test-cpp test clean

CXX ?= g++
CXXFLAGS ?= -std=c++17 -Wall -Wextra
CLANG_FORMAT ?= clang-format

EMIT_CPP_DIR := emit/cpp
GENERATED_CPP := $(EMIT_CPP_DIR)/generated/binary_search.cpp
CPP_HARNESS := $(EMIT_CPP_DIR)/test_main.cpp
CPP_RUNNER := $(EMIT_CPP_DIR)/run_tests

# Regenerate the C++ source from the Lean IR, then format it for readability
# (emitStmt itself doesn't track indentation - the output is correct but flat).
emit-cpp:
	lake exe emit_cpp
	$(CLANG_FORMAT) -i $(GENERATED_CPP)

# Regenerate, compile, and run the C++ tests.
test-cpp: emit-cpp
	$(CXX) $(CXXFLAGS) -o $(CPP_RUNNER) $(GENERATED_CPP) $(CPP_HARNESS)
	./$(CPP_RUNNER)

# Umbrella target for all emitted-language test suites (add test-rust here later).
test: test-cpp

clean:
	rm -f $(GENERATED_CPP) $(CPP_RUNNER)
