// a. use bit check for evenness
// b. use less `as u32` conversions
// c. use an uncoinstrained function for the `mod 10` checks

unconstrained fn to_mod_10(num: Field) -> (Field, Field) {
    let n_quot = ((num as u32) / 10) as Field;
    let n_rem = ((num as u32) % 10) as Field;
    (n_quot, n_rem)
}

/// Asserts that the last digit of `num` is equal to `target`.
fn assert_eq_mod_10(num: Field, target: Field) {
    // safety: we assume num is a valid Field and target is a digit (0-9)
    let (num_quot, num_rem) = unsafe { to_mod_10(num) };
    // we dont have to check if num_rem is less than 10, because we now target is a digit
    assert_eq(num_rem, target, "assert_eq_mod_10: last digit must equal target");
    assert_eq(num_quot * 10 + num_rem, num, "assert_eq_mod_10: a10 + a1 * 10 must equal num");
}

pub fn validate_tckn(tckn: [Field; 11]) {
    // TODO: how to make sure all are digits?

    // first digit cannot be 0
    assert(tckn[0] != 0, "first digit cannot be 0");

    // the last digit must be even
    // let last_digit_u32 = tckn[10] as u32;
    // assert(last_digit_u32 % 2 == 0, "last digit must be even");
    assert_eq(tckn[10].to_le_bits::<4>()[0], 0); // if number is even, its least significant bit must be 0

    // 10th digit is calculated using positions 1-9:
    // - multiply the sum of digits at positions (1,3,5,7,9) by 7,
    // - add it to the sum of digits at positions (2,4,6,8) multiplied by 9,
    // - take the "ones" digit of the result
    let odd_sum = tckn[0] + tckn[2] + tckn[4] + tckn[6] + tckn[8]; // positions 1,3,5,7,9 (0-indexed)
    let even_sum = tckn[1] + tckn[3] + tckn[5] + tckn[7]; // positions 2,4,6,8 (0-indexed)
    assert_eq_mod_10(odd_sum * 7 + even_sum * 9, tckn[9]);
    // let tenth_digit_calc_u32 = (odd_sum * 7 + even_sum * 9) as u32 % 10;
    // let tenth_digit_calc = tenth_digit_calc_u32 as Field;
    // assert(tckn[9] == tenth_digit_calc, "tenth digit is invalid");

    // 11th digit is calculated using odd-positioned digits:
    // take the ones digit of 8 times the sum of digits at positions (1,3,5,7,9)
    assert_eq_mod_10(odd_sum * 8, tckn[10]);
    // let eleventh_digit_calc_u32 = (odd_sum * 8) as u32 % 10;
    // let eleventh_digit_calc = eleventh_digit_calc_u32 as Field;
    // assert(tckn[10] == eleventh_digit_calc, "eleventh digit is invalid");

    // sum of first 10 digits modulo 10 gives the 11th digit
    let first_ten_sum = tckn[0]
        + tckn[1]
        + tckn[2]
        + tckn[3]
        + tckn[4]
        + tckn[5]
        + tckn[6]
        + tckn[7]
        + tckn[8]
        + tckn[9];
    assert_eq_mod_10(first_ten_sum, tckn[10]);
    // let first_ten_sum_mod = (first_ten_sum as u32) % 10;
    // assert(
    //     tckn[10] == first_ten_sum_mod as Field,
    //     "sum of first 10 digits modulo 10 must equal the 11th digit",
    // );
}

#[test]
fn test_valid_tckn() {
    // 10000000146 (smallest prefixed TCKN)
    let valid_tckn: [Field; 11] = [1, 0, 0, 0, 0, 0, 0, 0, 1, 4, 6];
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
    let valid_tckn2: [Field; 11] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 5, 0];
    validate_tckn(valid_tckn2);
}

#[test(should_fail)]
fn test_invalid_first_digit() {
    // first digit cannot be 0
    let invalid_tckn: [Field; 11] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
    validate_tckn(invalid_tckn);
}

#[test(should_fail)]
fn test_invalid_last_digit_odd() {
    // last digit must be even
    let invalid_tckn: [Field; 11] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 5, 3];
    validate_tckn(invalid_tckn);
}

#[test(should_fail)]
fn test_invalid_tenth_digit() {
    let invalid_tckn: [Field; 11] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 7, 0];
    validate_tckn(invalid_tckn);
}

#[test(should_fail)]
fn test_invalid_eleventh_digit() {
    let invalid_tckn: [Field; 11] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 5, 2];
    validate_tckn(invalid_tckn);
}
