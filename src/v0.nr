/// +---------+----------------------------+----------------------+--------------+-----------------+
/// | Package | Function                   | Expression Width     | ACIR Opcodes | Brillig Opcodes |
/// +---------+----------------------------+----------------------+--------------+-----------------+
/// | tckn    | main                       | Bounded { width: 4 } | 93           | 17              |
/// +---------+----------------------------+----------------------+--------------+-----------------+
/// | tckn    | directive_invert           | N/A                  | N/A          | 9               |
/// +---------+----------------------------+----------------------+--------------+-----------------+
/// | tckn    | directive_integer_quotient | N/A                  | N/A          | 8               |
/// +---------+----------------------------+----------------------+--------------+-----------------+

pub fn validate_tckn(tckn: [Field; 11]) {
    for digit in tckn {
        // cast & lt check: +154 ops = 14 ops per digit
        // assert(digit as u32 < 10, "each digit must be in the range 0-9");

        // less-than check: +715 ops = 65 ops per digit
        // assert(digit.lt(10), "each digit must be in the range 0-9");

        // bit-check: +22 ops = 2 ops per digit
        (digit - 0).assert_max_bit_size::<4>();
        (digit + (15 - 9)).assert_max_bit_size::<4>();

        // vanish check: +187 ops = 17 ops per digit
        // let prod = (digit)
        //     * (digit - 1)
        //     * (digit - 2)
        //     * (digit - 3)
        //     * (digit - 4)
        //     * (digit - 5)
        //     * (digit - 6)
        //     * (digit - 7)
        //     * (digit - 8)
        //     * (digit - 9);
        // assert_eq(prod, 0, "each digit must be in the range 0-9");
    }

    // this version did not have digit checks, the LLM missed it
    // first digit cannot be 0
    assert(tckn[0] != 0, "first digit cannot be 0");

    // the last digit must be even
    let last_digit_u32 = tckn[10] as u32;
    assert_eq(last_digit_u32 % 2, 0, "last digit must be even");

    // 10th digit is calculated using positions 1-9:
    // - multiply the sum of digits at positions (1,3,5,7,9) by 7,
    // - add it to the sum of digits at positions (2,4,6,8) multiplied by 9,
    // - take the "ones" digit of the result
    let odd_sum = tckn[0] + tckn[2] + tckn[4] + tckn[6] + tckn[8]; // positions 1,3,5,7,9 (0-indexed)
    let even_sum = tckn[1] + tckn[3] + tckn[5] + tckn[7]; // positions 2,4,6,8 (0-indexed)
    let tenth_digit_calc_u32 = (odd_sum * 7 + even_sum * 9) as u32 % 10;
    let tenth_digit_calc = tenth_digit_calc_u32 as Field;
    assert_eq(tckn[9], tenth_digit_calc, "tenth digit is invalid");

    // 11th digit is calculated using odd-positioned digits:
    // take the ones digit of 8 times the sum of digits at positions (1,3,5,7,9)
    let eleventh_digit_calc_u32 = (odd_sum * 8) as u32 % 10;
    let eleventh_digit_calc = eleventh_digit_calc_u32 as Field;
    assert_eq(tckn[10], eleventh_digit_calc, "eleventh digit is invalid");

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
    let first_ten_sum_mod = (first_ten_sum as u32) % 10;
    assert_eq(
        tckn[10],
        first_ten_sum_mod as Field,
        "sum of first 10 digits modulo 10 must equal the 11th digit",
    );
}
