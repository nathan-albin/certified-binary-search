#include <cstdio>
#include <optional>
#include <string>
#include <vector>

// Declared here, defined in generated/binary_search.cpp (emitted by `lake exe emit_cpp`
// from BinarySearch/EmitCppProgram.lean).
std::optional<size_t> binary_search(const std::vector<size_t>& arr, size_t target);

namespace {

struct Case {
    size_t target;
    bool found;
    size_t index;
};

struct Suite {
    const char* name;
    std::vector<size_t> arr;
    std::vector<Case> cases;
};

// Same arrays and expected results as BinarySearch/ProgramTest.lean and BinarySearch/Basic.lean.
const std::vector<Suite> kSuites = {
    {"testArray",
     {1, 3, 5, 7, 7, 9},
     {
         {5, true, 2},
         {2, false, 0},
         {9, true, 5},
         {1, true, 0},
         {0, false, 0},
         {7, true, 3},
     }},
    {"emptyArray", {}, {{5, false, 0}}},
    {"singletonArray", {42}, {{42, true, 0}, {7, false, 0}}},
    {"pairArray",
     {10, 20},
     {
         {10, true, 0},
         {20, true, 1},
         {15, false, 0},
     }},
    {"largeArray",
     {1, 1, 3, 4, 4, 4, 6, 8, 8, 10, 12, 15, 15},
     {
         {1, true, 1},
         {15, true, 12},
         {4, true, 3},
         {8, true, 8},
         {12, true, 10},
         {0, false, 0},
         {5, false, 0},
         {20, false, 0},
     }},
};

}  // namespace

int main() {
    int failures = 0;
    int total = 0;
    for (const auto& suite : kSuites) {
        for (const auto& c : suite.cases) {
            total++;
            auto result = binary_search(suite.arr, c.target);
            bool ok = c.found ? (result.has_value() && *result == c.index)
                               : !result.has_value();
            if (!ok) {
                std::printf("FAIL: suite=%s target=%zu expected_found=%d expected_index=%zu got=%s\n",
                             suite.name, c.target, c.found, c.index,
                             result.has_value() ? std::to_string(*result).c_str() : "none");
                failures++;
            }
        }
    }

    if (failures == 0) {
        std::printf("All %d test cases passed.\n", total);
    }
    return failures;
}
