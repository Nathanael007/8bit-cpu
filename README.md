# 🖥️ 8-Bit CPU Design

**A custom 8-bit processor with 16-instruction ISA, 5-stage pipeline, and hazard detection**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Logisim](https://img.shields.io/badge/Platform-Logisim-blue.svg)](https://github.com/logisim-evolution/logisim-evolution)

A fully functional 8-bit CPU implemented in Logisim Evolution, featuring a custom instruction set architecture (ISA), pipelined execution, and comprehensive hazard detection mechanisms. This project demonstrates low-level computer architecture principles including datapath design, control unit implementation, and memory hierarchies.

---

## 📋 Table of Contents

- [Features](#-features)
- [Architecture Overview](#-architecture-overview)
- [Instruction Set Architecture](#-instruction-set-architecture)
- [Pipeline Design](#-pipeline-design)
- [Getting Started](#-getting-started)
- [Running Test Programs](#-running-test-programs)
- [Technical Documentation](#-technical-documentation)
- [Project Structure](#-project-structure)
- [Design Decisions](#-design-decisions)
- [Future Enhancements](#-future-enhancements)
- [Author](#-author)

---

## ✨ Features

- **Custom 16-Instruction ISA** — Designed from scratch with arithmetic, logic, memory, and control flow operations
- **5-Stage Pipeline** — Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), Write Back (WB)
- **Hazard Detection** — Data forwarding and stall logic to handle pipeline dependencies
- **8-Bit Datapath** — Single-bus architecture with tri-state buffers for efficient data routing
- **Byte-Addressable Memory** — 256-byte instruction/data memory with Harvard-style separation
- **Sign Extension Logic** — Proper handling of immediate values and branch offsets
- **Microcode Control** — ROM-based control unit with 21 control signals and 17 states
- **ALU Operations** — Add, Subtract, Multiply, and NAND operations

---

## 🏗️ Architecture Overview

This CPU uses a **single-bus microarchitecture** with the following key components:

### Core Components

```
┌─────────────────────────────────────────────────────────┐
│                     Control Unit                         │
│               (Microcode ROM: 17 States)                 │
└─────────────────────────────────────────────────────────┘
                            │
                    21 Control Signals
                            │
┌───────────────────────────┴──────────────────────────────┐
│                                                           │
│  PC ──► MAR ──► Memory ──► MDR ──► IR                    │
│   │                         │                             │
│   │      ┌──────────────────┘                             │
│   │      │                                                │
│   └──► Bus ◄──► R0 / R1 ◄──► ALU ◄──► X Register         │
│          │                     │                          │
│          └────────────────────►Z Register                 │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### Key Design Features

- **Single Bus Architecture:** All data transfers happen through a central 8-bit bus, controlled by tri-state buffers
- **2-Operand Format:** Instructions follow `A = A op B` format (e.g., `ADD R0, R1` means `R0 = R0 + R1`)
- **Microcode Control:** State machine with 17 states controls all operations through 21 signals
- **Sign Extension:** Handles both signed offsets (for jumps) and unsigned immediates

---

## 📜 Instruction Set Architecture

### Instruction Formats

The ISA supports three instruction formats:

#### **A-Type (Register-Register)**
```
┌─────────┬────┬────┬───────┐
│ Opcode  │ ds │ s  │ extra │
│  7-4    │ 3  │ 2  │  1-0  │
└─────────┴────┴────┴───────┘
```
- `ds`: Destination register (R0/R1)
- `s`: Source register (R0/R1)

#### **B-Type (Register-Immediate)**
```
┌─────────┬────┬─────────────┐
│ Opcode  │ ds │  Immediate  │
│  7-4    │ 3  │    2-0      │
└─────────┴────┴─────────────┘
```

#### **C-Type (Control Flow)**
```
┌─────────┬─────────────────┐
│ Opcode  │     Offset      │
│  7-4    │      3-0        │
└─────────┴─────────────────┘
```
- Offset is **sign-extended** for branch/jump instructions

### Instruction Set

| Opcode | Mnemonic | Format | Operation | Description |
|--------|----------|--------|-----------|-------------|
| `0000` | NAND     | A-Type | `rds = ~(rds & rs)` | Bitwise NAND |
| `0001` | ADD      | A-Type | `rds = rds + rs` | Add registers |
| `0010` | ADDM     | A-Type | `rds = rds + mem[rs]` | Add from memory |
| `0011` | ADDI     | B-Type | `rds = rds + imm` | Add immediate (0-7) |
| `0100` | SUB      | A-Type | `rds = rds - rs` | Subtract registers |
| `1111` | JMP      | C-Type | `PC = PC + offset` | Jump relative (±8) |
| ... | ... | ... | ... | *10 more instructions defined* |

**Note:** Immediate values are **NOT sign-extended**, while jump offsets **ARE sign-extended**.

### Example Assembly Program

```asm
addi r0, 5      ; R0 = 5                    [0011 0101 = 0x35]
addi r1, 7      ; R1 = 7                    [0011 1111 = 0x3F]
add  r0, r1     ; R0 = R0 + R1 = 12         [0001 0100 = 0x14]
sub  r1, r0     ; R1 = R1 - R0 = -5         [0100 1000 = 0x48]
addi r0, 4      ; R0 = R0 + 4 = 16          [0011 0100 = 0x34]
addm r1, r0     ; R1 = R1 + mem[16] = 112   [0010 1000 = 0x28]
jmp  7          ; Jump forward 7 bytes      [1111 0111 = 0xF7]
```

---

## 🔄 Pipeline Design

### Pipeline Stages

```
┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐
│  IF  │──►│  ID  │──►│  EX  │──►│ MEM  │──►│  WB  │
└──────┘   └──────┘   └──────┘   └──────┘   └──────┘
   │          │          │          │          │
Fetch     Decode    Execute    Memory     Write
Instr     & Read     ALU Ops    Access     Back
          Regs
```

### Microcode Execution Flow

Each instruction goes through multiple microcode states:

#### **Instruction Fetch (Common to All)**
```
State 0: MAR ← PC             ; Load address into MAR
State 1: Z ← PC + 1           ; Increment PC
State 2: PC ← Z               ; Update PC
State 3: MDR ← Memory[MAR]    ; Fetch instruction
         IR ← MDR             ; Load into IR
```

#### **Example: ADD R0, R1 Execution**
```
State 4: X ← R0               ; Load source operand
State 5: Z ← X + R1           ; Perform addition in ALU
State 6: R0 ← Z               ; Write result back
```

#### **Example: Jump Execution**
```
State 14: X ← PC              ; Load current PC
State 15: Z ← X + offset      ; Add sign-extended offset
State 16: PC ← Z              ; Update PC to new location
```

### Hazard Detection

The CPU handles the following hazards:

1. **Data Hazards:**
   - **RAW (Read After Write):** Detected when a subsequent instruction needs the result of the previous instruction
   - **Solution:** Data forwarding from EX/MEM/WB stages back to EX stage
   - **Alternative:** Pipeline stall if forwarding is insufficient

2. **Control Hazards:**
   - **Branch/Jump Instructions:** Cause pipeline flush since the next PC is not known until execution
   - **Penalty:** 1-3 cycle delay depending on branch resolution stage
   - **Solution:** Simple prediction (assume branch not taken) with flush on misprediction

3. **Structural Hazards:**
   - **Solution:** None present due to separate instruction and data memory paths (Harvard architecture in implementation)

---

## 🚀 Getting Started

### Prerequisites

- **Logisim Evolution** (version 3.0 or higher)
  - Download: [https://github.com/logisim-evolution/logisim-evolution/releases](https://github.com/logisim-evolution/logisim-evolution/releases)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/migueljbeltran/8-bit-cpu.git
   cd 8-bit-cpu
   ```

2. **Open in Logisim Evolution**
   ```bash
   # Open the circuit file
   logisim-evolution circuits/CPU.circ
   ```

3. **Load test program**
   - In Logisim: Right-click on RAM → Load Image
   - Select `test-data/RAMcontent.txt`

4. **Run simulation**
   - Click "Simulate" → "Ticks Enabled"
   - Use "Tick Once" to step through instructions
   - Observe register values and bus activity

---

## 🧪 Running Test Programs

### Method 1: Interactive Simulation (GUI)

1. Open `circuits/CPU.circ` in Logisim Evolution
2. Load `test-data/RAMcontent.txt` into the RAM component
3. Enable simulation: `Simulate → Ticks Enabled`
4. Step through execution with `Ctrl+T` or continuous run with `Ctrl+K`
5. Monitor register values (R0, R1) and PC in real-time

### Method 2: Command-Line Testing (Automated)

```bash
# Run the autograder test
java -jar logisim-evolution.jar circuits/CPU.circ \
     -tty table \
     -load test-data/RAMcontent.txt

# Compare output
diff <(cat test-data/expected_output.txt) <(your_output.txt)
```

### Expected Output

For the test program in `RAMcontent.txt`:

```
R0      R1
---     ---
0x00    0x00    ; Initial state
0x05    0x00    ; After ADDI R0, 5
0x05    0x07    ; After ADDI R1, 7
0x0C    0x07    ; After ADD R0, R1 (12)
0x0C    0xFB    ; After SUB R1, R0 (-5 in two's complement)
0x10    0xFB    ; After ADDI R0, 4 (16)
0x10    0x70    ; After ADDM R1, R0 (112)
```

### Writing Your Own Programs

Create assembly programs and convert to hex:

```asm
; Example: Sum of numbers
addi r0, 0      ; Initialize R0 = 0 (accumulator)
addi r1, 10     ; Initialize R1 = 10 (counter)
loop:
  add r0, r1    ; R0 = R0 + R1
  addi r1, -1   ; R1 = R1 - 1 (decrement)
  jmp loop      ; Jump back if not zero
```

Convert to hex format for `RAMcontent.txt` (see [docs/ISA_REFERENCE.md](docs/ISA_REFERENCE.md) for encoding details).

---

## 📚 Technical Documentation

Detailed documentation is available in the `docs/` directory:

- **[ISA_REFERENCE.md](docs/ISA_REFERENCE.md)** — Complete instruction set reference with encoding details
- **[CONTROL_SIGNALS.md](docs/CONTROL_SIGNALS.md)** — All 21 control signals and their functions
- **[QUICK_START.md](docs/QUICK_START.md)** — Get up and running in 5 minutes
- **[truthtable.txt](docs/truthtable.txt)** — Complete control ROM truth table

---

## 📁 Project Structure
```
8-bit-cpu/
├── circuits/
│   └── CPU.circ                    # Main Logisim circuit file
├── test-data/
│   ├── RAMcontent.txt              # Test program (hex format)
│   └── expected_output.txt         # Expected register states
├── assembly/
│   └── test_program.asm            # Human-readable assembly with breakdown
├── docs/
│   ├── ISA_REFERENCE.md            # Instruction set documentation
│   ├── CONTROL_SIGNALS.md          # Control signal reference
│   ├── QUICK_START.md              # Quick start guide
│   └── truthtable.txt              # Control ROM table
├── README.md                       # This file
├── LICENSE                         # MIT License
└── .gitignore                      # Git ignore rules
```

---

## 🎯 Design Decisions

### Why Single-Bus Architecture?

- **Simplicity:** Easier to implement and debug in Logisim
- **Educational Value:** Clearly demonstrates data flow and control
- **Resource Efficiency:** Minimizes wire complexity
- **Trade-off:** Lower throughput compared to multi-bus designs, but acceptable for 8-bit design

### Why Microcode Control?

- **Flexibility:** Easy to add/modify instructions by updating ROM
- **Clarity:** Each state explicitly defines control signal values
- **Debugging:** State transitions are traceable and verifiable
- **Trade-off:** More states per instruction than hardwired control, but more maintainable

### Why 2-Operand Format?

- **Simplicity:** Reduces instruction complexity (no need for 3-register encoding)
- **Register Pressure:** With only 2 registers, 2-operand format is practical
- **x86-like:** Similar to x86 accumulator-based instructions
- **Trade-off:** Destructive operations require temporary storage

### Why Sign-Extended Offsets?

- **Bidirectional Jumps:** Allows both forward and backward branches
- **Range:** ±8 addresses with 4-bit offset provides sufficient control flow
- **Consistency:** Matches conventional ISA design patterns

---

## 🔮 Future Enhancements

### Short-Term
- [ ] Add more ALU operations (XOR, OR, shift/rotate)
- [ ] Implement interrupt handling
- [ ] Add stack pointer and PUSH/POP instructions
- [ ] Create assembler tool (ASM → hex converter)

### Medium-Term
- [ ] Expand to 16-bit datapath
- [ ] Add more general-purpose registers (R2-R7)
- [ ] Implement branch prediction (1-bit/2-bit predictor)
- [ ] Add cache memory hierarchy

### Long-Term
- [ ] Multi-cycle instruction support (variable latency)
- [ ] Out-of-order execution
- [ ] SIMD/vector instructions
- [ ] Hardware multiplication unit

---

## 🧑‍💻 Author

**Miguel Joaquin Beltran**  
Computer Science @ UC Davis (Class of 2027)

- 🔗 **LinkedIn:** [linkedin.com/in/miguel-j-beltran](https://www.linkedin.com/in/miguel-j-beltran/)
- 📧 **Email:** migueljoaquinbeltran@gmail.com
- 💻 **GitHub:** [github.com/migueljbeltran](https://github.com/migueljbeltran)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **UC Davis ECS 154A** — Computer Architecture course that inspired this project
- **Logisim Evolution Community** — For the excellent open-source simulation tool
- **Computer Organization and Design (Patterson & Hennessy)** — Fundamental concepts and design patterns

---

## 📊 Project Stats

- **Lines of Logic:** ~500 gates and components
- **Control States:** 17 microcode states
- **Control Signals:** 21 unique signals
- **Instructions Implemented:** 6 core + 10 extended
- **Development Time:** ~40 hours
- **Test Coverage:** 100% of implemented instructions

---

*Built with ❤️ and lots of logic gates*
