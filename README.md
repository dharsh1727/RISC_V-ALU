# RV32I ALU with Immediate Generator (SystemVerilog Verified)

## Overview
This project implements a 32-bit ALU (Arithmetic Logic Unit) compatible with the RISC-V RV32I instruction set, along with an Immediate Generator (Extend Unit) and a SystemVerilog constrained-random verification environment.

The design supports both:
* Register-Register operations (R-type)
* Register-Immediate operations (I-type)

---
Author
Priyadharshan L 
BE.ECE @ CEG, Anna University
---

## Architecture

### ALU (Arithmetic Logic Unit)
The ALU performs core arithmetic and logical operations based on a 4-bit control signal.

| Operation | Description |
| :--- | :--- |
| **ADD** | Addition |
| **SUB** | Subtraction |
| **AND** | Bitwise AND |
| **OR** | Bitwise OR |
| **XOR** | Bitwise XOR |
| **SLL** | Shift Left Logical |
| **SRL** | Shift Right Logical |
| **SRA** | Shift Right Arithmetic |
| **SLT** | Signed comparison |
| **SLTU** | Unsigned comparison |

### Operand Selection
* **alu_src = 0**: SrcA and SrcB (R-type)
* **alu_src = 1**: SrcA and Immediate (I-type)

### Zero Flag
* **zero = 1**: ALU result is 0
* **zero = 0**: otherwise
Used for branch decisions like **BEQ** (Branch if Equal).

---

## Immediate Generator (Extend Unit)
Generates 32-bit immediates from instruction fields. It handles sign extension and bit rearrangement (especially for B-type and J-type instructions).

**Supported Types:**
* **I-type**: ADDI, ANDI, LW
* **S-type**: SW
* **B-type**: BEQ, BNE
* **J-type**: JAL
* **U-type**: LUI, AUIPC

---

## Verification (SystemVerilog)
A constrained-random testbench is used for verification to ensure industrial-grade reliability.

### Key Features
* **Random input generation**: Uses `rand` for wide coverage.
* **Corner case injection**: Tests 0, -1, and max/min values.
* **Golden model**: A reference ALU inside the testbench for validation.
* **Scoreboard**: Automated comparison between DUT and Golden Model.
* **Assertions**: Checks for zero flag correctness.
* **Scalability**: Validated with 1000+ randomized test vectors.

### Verification Flow
1.  Generate random inputs.
2.  Apply to DUT (ALU).
3.  Compute expected result (Golden Model).
4.  Compare DUT vs Expected.
5.  Log mismatches.

---

## File Structure

| File | Description |
| :--- | :--- |
| `alu.v` | Main ALU implementation |
| `extend.v` | Immediate generator |
| `tb_alu.sv` | SystemVerilog testbench with scoreboard |

---

## Key Highlights

-  Implements RV32I-compliant ALU.
-  Supports signed and unsigned operations.
-  Handles shift operations correctly (5-bit masking).
-  Includes industrial-style verification methodology.
-  Clean separation of datapath and immediate generation.

## Applications
-  RISC-V Processor Design
-  CPU Datapath Implementation
-  Digital System Design
-  ASIC/FPGA Prototyping

