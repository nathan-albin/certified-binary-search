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

// Same array and expected results as BinarySearch/ProgramTest.lean and BinarySearch/Basic.lean.
const std::vector<size_t> kArray = {1, 3, 5, 7, 7, 9};
const Case kCases[] = {
    {5, true, 2},
    {2, false, 0},
    {9, true, 5},
    {1, true, 0},
    {0, false, 0},
    {7, true, 3},
};

}  // namespace

int main() {
    int failures = 0;
    for (const auto& c : kCases) {
        auto result = binary_search(kArray, c.target);
        bool ok = c.found ? (result.has_value() && *result == c.index)
                           : !result.has_value();
        if (!ok) {
            std::printf("FAIL: target=%zu expected_found=%d expected_index=%zu got=%s\n",
                         c.target, c.found, c.index,
                         result.has_value() ? std::to_string(*result).c_str() : "none");
            failures++;
        }
    }

    if (failures == 0) {
        std::printf("All %zu test cases passed.\n", sizeof(kCases) / sizeof(kCases[0]));
    }
    return failures;
}
