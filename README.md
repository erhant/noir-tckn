# noir-tckn

> [_original snippet from Turkish Wikipedia page on Turkish ID_](https://tr.wikipedia.org/wiki/T.C._Kimlik_Numaras%C4%B1):
>
> T.C. Kimlik No, on bir (11) haneden oluşan, Nüfus ve Vatandaşlık İşleri Genel Müdürlüğü tarafından Türk vatandaşlarına verilmiş 11 rakamdan oluşan ve son rakamı bir çift sayı olan kişiye özgü bir sayıdır.
>
> Üzerinde basit bir pariteyle hata bulma özelliği bulunmaktadır; ilk 10 rakamın toplamının birler basamağı, 11. rakamı vermektedir. Bu algoritmayı kullanan oluşturucularla yaklaşık 900 milyon kadar geçerli T.C. kimlik numarası üretilebilmektedir.[1]
>
> Ayrıca; 1, 3, 5, 7 ve 9. rakamın toplamının 7 katı ile 2, 4, 6 ve 8. rakamın toplamının 9 katının toplamının birler basamağı 10. rakamı; 1, 3, 5, 7 ve 9. rakamın toplamının 8 katının birler basamağı 11. rakamı vermektedir.[2]

This translates to the following rules for a Turkish National ID (TCKN):

1. A Turkish National ID number consists of **11 digits**.
2. The **last digit** (11th digit) must be an **even number**.
3. There are several validation rules:
   - The ones digit of the sum of the first 10 digits gives the 11th digit
   - To find the 10th digit: Multiply the sum of digits at positions (1,3,5,7,9) by 7, add it to the sum of digits at positions (2,4,6,8) multiplied by 9, and take the ones digit of the result
   - To find the 11th digit: Take the ones digit of 8 times the sum of digits at positions (1,3,5,7,9)

Using these rules, approximately 900 million valid Turkish National ID numbers can be generated.

This is a [Noir](https://noir-lang.org/) implementation of the Turkish National ID validation rules. The project allows validation of TCKN using zero-knowledge proofs.

## Installation

Make sure you have Nargo (Noir's package manager) installed. If not, follow the [installation instructions](https://noir-lang.org/getting_started/installation).

Clone this repository:

```sh
git clone https://github.com/erhant/noir-tckn.git
cd noir-tckn
```

## Usage

To verify a TCKN number:

```bash
nargo execute
```

> `nargo execute` reads the input from [`Prover.toml`](./Prover.toml)
>
> ```toml
> tckn = ["1","0","0","0","0","0","0","0","1","4","6"]
> ```

## Performance

We have 3 versions implemented:

- [`v0`](./src/v0.nr) uses a `Field` input, does occasional castings.
- [`v0.5`](./src/v0_5.nr) gets rids of casting around the place by accepting the casted value as input, albeit at the cost of more gates.
- [`v1`](./src/v1.nr) uses a better evenness check & unconstrained and hinted mod 10 trick.

| Version | ACIR Opcodes | Circuit Size |
| ------- | ------------ | ------------ |
| v0      | 93           | 3614         |
| v0.5    | 122          | 2910         |
| v1      | 50           | 79           |

We use the following commands for this:

- `nargo info` to get ACIR opcodes
- `bb gates -b ./target/tckn.json` to get Circuit Size

## Testing

The project includes test cases for valid and invalid TCKN numbers:

```bash
nargo test
```

## License

This project is open source and available under the [MIT License](LICENSE).
