// Same array and expected results as BinarySearch/ProgramTest.lean and
// BinarySearch/Basic.lean. `src/lib.rs` is generated (by `lake exe emit_rust`
// from BinarySearch/EmitRustProgram.lean) - this file is hand-written and is
// never overwritten.

use binary_search_emitted::binary_search;

fn array() -> Vec<usize> {
    vec![1, 3, 5, 7, 7, 9]
}

#[test]
fn finds_5_at_index_2() {
    assert_eq!(binary_search(&array(), 5), Some(2));
}

#[test]
fn does_not_find_2() {
    assert_eq!(binary_search(&array(), 2), None);
}

#[test]
fn finds_9_at_index_5() {
    assert_eq!(binary_search(&array(), 9), Some(5));
}

#[test]
fn finds_1_at_index_0() {
    assert_eq!(binary_search(&array(), 1), Some(0));
}

#[test]
fn does_not_find_0() {
    assert_eq!(binary_search(&array(), 0), None);
}

#[test]
fn finds_7_at_index_3() {
    assert_eq!(binary_search(&array(), 7), Some(3));
}

// Same array and expected results as BinarySearch/ProgramTest.lean and
// BinarySearch/Basic.lean's `emptyArray`.

#[test]
fn does_not_find_in_empty_array() {
    assert_eq!(binary_search(&[], 5), None);
}

// Same array and expected results as BinarySearch/ProgramTest.lean and
// BinarySearch/Basic.lean's `singletonArray`.

fn singleton() -> Vec<usize> {
    vec![42]
}

#[test]
fn finds_only_element() {
    assert_eq!(binary_search(&singleton(), 42), Some(0));
}

#[test]
fn does_not_find_missing_element_in_singleton() {
    assert_eq!(binary_search(&singleton(), 7), None);
}

// Same array and expected results as BinarySearch/ProgramTest.lean and
// BinarySearch/Basic.lean's `pairArray`.

fn pair() -> Vec<usize> {
    vec![10, 20]
}

#[test]
fn finds_first_of_pair() {
    assert_eq!(binary_search(&pair(), 10), Some(0));
}

#[test]
fn finds_second_of_pair() {
    assert_eq!(binary_search(&pair(), 20), Some(1));
}

#[test]
fn does_not_find_between_pair() {
    assert_eq!(binary_search(&pair(), 15), None);
}

// Same array and expected results as BinarySearch/ProgramTest.lean and
// BinarySearch/Basic.lean's `largeArray`: duplicate runs at both the start
// and the end, as well as in the middle.

fn large() -> Vec<usize> {
    vec![1, 1, 3, 4, 4, 4, 6, 8, 8, 10, 12, 15, 15]
}

#[test]
fn finds_leading_duplicate_run() {
    assert_eq!(binary_search(&large(), 1), Some(1));
}

#[test]
fn finds_trailing_duplicate_run() {
    assert_eq!(binary_search(&large(), 15), Some(12));
}

#[test]
fn finds_middle_duplicate_run() {
    assert_eq!(binary_search(&large(), 4), Some(3));
}

#[test]
fn finds_another_middle_duplicate_run() {
    assert_eq!(binary_search(&large(), 8), Some(8));
}

#[test]
fn finds_unique_middle_element() {
    assert_eq!(binary_search(&large(), 12), Some(10));
}

#[test]
fn does_not_find_below_range() {
    assert_eq!(binary_search(&large(), 0), None);
}

#[test]
fn does_not_find_between_elements() {
    assert_eq!(binary_search(&large(), 5), None);
}

#[test]
fn does_not_find_above_range() {
    assert_eq!(binary_search(&large(), 20), None);
}
