// +---------+--------------------+----------------------+--------------+-----------------+
// | Package | Function           | Expression Width     | ACIR Opcodes | Brillig Opcodes |
// +---------+--------------------+----------------------+--------------+-----------------+
// | tckn    | main               | Bounded { width: 4 } | 50           | 61              |
// +---------+--------------------+----------------------+--------------+-----------------+
// | tckn    | to_mod_10          | N/A                  | N/A          | 35              |
// +---------+--------------------+----------------------+--------------+-----------------+
// | tckn    | directive_invert   | N/A                  | N/A          | 9               |
// +---------+--------------------+----------------------+--------------+-----------------+
// | tckn    | directive_to_radix | N/A                  | N/A          | 17              |
// +---------+--------------------+----------------------+--------------+-----------------+

// a. use bit check for evenness
// b. use the optimal digit checks
unconstrained fn to_mod_10(num: Field) -> (Field, Field) {
    let n_quot = ((num as u32) / 10) as Field;
    let n_rem = ((num as u32) % 10) as Field;
    (n_quot, n_rem)
}

/// Asserts that the last digit of `num` is equal to `target`.
fn assert_eq_mod_10(num: Field, target: Field) {
    // safety: we assume target is a digit (0-9)
    let (num_quot, num_rem) = unsafe { to_mod_10(num) };
    // we dont have to check if num_rem is less than 10, because we know target is a digit
    assert_eq(num_rem, target, "assert_eq_mod_10: last digit must equal target");
    assert_eq(num_quot * 10 + num_rem, num, "assert_eq_mod_10: quot + rem * 10 must equal num");
}

pub fn validate_tckn(tckn: [Field; 11]) {
    // assert that digits are in the range 0-9
    for digit in tckn {
        (digit - 0).assert_max_bit_size::<4>();
        (digit + (15 - 9)).assert_max_bit_size::<4>();
    }

    // first digit cannot be 0
    assert(tckn[0] != 0, "first digit cannot be 0");

    // the last digit must be even
    assert_eq(tckn[10].to_le_bits::<4>()[0], 0); // if number is even, its least significant bit must be 0

    // 10th digit is calculated using positions 1-9:
    // - multiply the sum of digits at positions (1,3,5,7,9) by 7,
    // - add it to the sum of digits at positions (2,4,6,8) multiplied by 9,
    // - take the "ones" digit of the result
    let odd_sum = tckn[0] + tckn[2] + tckn[4] + tckn[6] + tckn[8]; // positions 1,3,5,7,9 (0-indexed)
    let even_sum = tckn[1] + tckn[3] + tckn[5] + tckn[7]; // positions 2,4,6,8 (0-indexed)
    assert_eq_mod_10(odd_sum * 7 + even_sum * 9, tckn[9]);

    // 11th digit is calculated using odd-positioned digits:
    // take the ones digit of 8 times the sum of digits at positions (1,3,5,7,9)
    assert_eq_mod_10(odd_sum * 8, tckn[10]);

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
}
