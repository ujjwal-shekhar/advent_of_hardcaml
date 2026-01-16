# Advent of Code 2025 - Day 3 Solution

This repository contains my solution for Day 3 of Advent of Code 2025, implemented in **HardCaml**.

## The Challenge
The problem asks us to find the maximum possible joltage from a sequence of batteries. 
- **Part 1:** Select 2 batteries per bank (max subseq of size 2).
- **Part 2:** Select 12 batteries per bank (max subseq of size 12).

## Architectural Approach: Streaming Priority Registers
Instead of buffering the input lines (which would require Block RAM and introduce latency) or using a standard software sorting algorithm, I implemented a **single-pass streaming architecture**.

### Design Highlights
* **Zero-RAM / Register Only:** The design does not use BRAM. It processes data strictly as it arrives from the UART/Interface.
* **O(1) Space:** For Part 2, we utilize a 12-stage priority register pipeline to mimic a clever DP. 
* **O(N) Time:** The circuit processes one character per clock cycle. The maximum value is available immediately upon receiving the newline character.

### Logic
We maintain a vector of $K$ registers (where $K=2$ for Part 1 and $K=12$ for Part 2). 
- Register $i$ holds the "Maximum $i$-digit number found so far in the current sequence."
- On every clock cycle, we calculate a candidate value: `(Value of Reg[i-1] * 10) + Current_Digit`.
- We compare this candidate against the current value of `Reg[i]` and store the maximum.
- All 12 stages (for part 2, 2 stages for part1) update in parallel on every clock cycle.

## Project Structure
* `lib/`: Contains the Hardcaml logic (`part1.ml`, `part2.ml`).
* `bin/`: Contains the testbench (`main.ml`) and RTL generator.
* `data/`: Input puzzle data.

## How to Run

### Prerequisites
* OCaml
* Dune build system
* Hardcaml

### Run the Simulation (Testbench)
This runs the logic against the provided `day3_input.txt` and verifies the result.
```bash
dune clean
dune build
dune exec bin/main.exe
```

### Generate Verilog (RTL)
To prove synthesizability and generate the standard hardware description files (`.v`), run the generators. This outputs the Verilog to standard output, which can be redirected to a file:

```bash
# Generate Part 1 RTL
dune exec bin/gen_part1.exe > day3_part1.v

# Generate Part 2 RTL
dune exec bin/gen_part2.exe > day3_part2.v
```


## Resources & Acknowledgements
* **Library:** [Hardcaml](https://github.com/janestreet/hardcaml)
* **Input Data:** [Advent of Code](https://adventofcode.com/)
