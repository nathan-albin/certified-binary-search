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
