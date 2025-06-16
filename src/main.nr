// mod v0;
// use v0::validate_tckn;

// mod v0_5;
// use v0_5::validate_tckn;

mod v1;
use v1::validate_tckn;

fn main(tckn: [Field; 11]) {
    validate_tckn(tckn);
}

#[test]
fn test_valid_tckn() {
    // 10000000146 (smallest prefixed TCKN)
    let valid_tckn: [_; 11] = [1, 0, 0, 0, 0, 0, 0, 0, 1, 4, 6];
    validate_tckn(valid_tckn);
}

#[test]
fn test_another_valid_tckn() {
    // we'll use 12345678901 and calculate the correct last two digits
    // positions 1,3,5,7,9: 1,3,5,7,9 = sum 25
    // positions 2,4,6,8: 2,4,6,8 = sum 20
    // 10th digit: (25*7 + 20*9) % 10 = (175 + 180) % 10 = 355 % 10 = 5
    // 11th digit: (25*8) % 10 = 200 % 10 = 0
    // sum of first 10 = 1+2+3+4+5+6+7+8+9+5 = 50, 50%10 = 0 (valid)
    let valid_tckn2: [_; 11] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 5, 0];
    validate_tckn(valid_tckn2);
}

#[test(should_fail)]
fn test_invalid_first_digit() {
    // first digit cannot be 0
    let invalid_tckn: [_; 11] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
    validate_tckn(invalid_tckn);
}

#[test(should_fail)]
fn test_invalid_last_digit_odd() {
    // last digit must be even
    let invalid_tckn: [_; 11] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 5, 3];
    validate_tckn(invalid_tckn);
}

#[test(should_fail)]
fn test_invalid_tenth_digit() {
    let invalid_tckn: [_; 11] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 7, 0];
    validate_tckn(invalid_tckn);
}

#[test(should_fail)]
fn test_invalid_eleventh_digit() {
    let invalid_tckn: [_; 11] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 5, 2];
    validate_tckn(invalid_tckn);
}
