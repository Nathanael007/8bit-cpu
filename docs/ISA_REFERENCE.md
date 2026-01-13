# Instruction Set Architecture (ISA) Reference

## Overview

This document provides a complete reference for the 8-bit CPU instruction set, including encoding formats, operation semantics, and cycle counts.

---

## Instruction Formats

### A-Type: Register-Register Operations

```
 7   6   5   4   3   2   1   0
┌───┴───┴───┴───┬───┬───┬───┴───┐
│    Opcode     │ds │ s │ extra │
└───────────────┴───┴───┴───────┘
```

- **Opcode [7:4]:** 4-bit operation code
- **ds [3]:** Destination register select (0 = R0, 1 = R1)
- **s [2]:** Source register select (0 = R0, 1 = R1)
- **extra [1:0]:** Reserved for future use

### B-Type: Register-Immediate Operations

```
 7   6   5   4   3   2   1   0
┌───┴───┴───┴───┬───┬───┴───┴───┐
│    Opcode     │ds │ Immediate │
└───────────────┴───┴───────────┘
```

- **Opcode [7:4]:** 4-bit operation code
- **ds [3]:** Destination register select (0 = R0, 1 = R1)
- **Immediate [2:0]:** 3-bit unsigned immediate value (0-7)
  - **NOT sign-extended** (zero-extended to 8 bits)

### C-Type: Control Flow Operations

```
 7   6   5   4   3   2   1   0
┌───┴───┴───┴───┬───┴───┴───┴───┐
│    Opcode     │     Offset    │
└───────────────┴───────────────┘
```

- **Opcode [7:4]:** 4-bit operation code
- **Offset [3:0]:** 4-bit signed offset (-8 to +7)
  - **Sign-extended** to 8 bits before addition to PC
  - Allows relative jumps: PC_new = PC + sign_extend(offset)

---

## Complete Instruction Set

### Arithmetic Operations

#### ADD — Add Registers
- **Opcode:** `0001` (0x1)
- **Format:** A-Type
- **Syntax:** `add rds, rs`
- **Operation:** `rds ← rds + rs`
- **Flags:** None
- **Cycles:** 7 (Fetch: 4, Execute: 3)
- **Example:**
  ```
  add r0, r1    ; R0 = R0 + R1
  Encoding: 0001 0100 = 0x14 (R0 = dest, R1 = src)
  ```

#### ADDI — Add Immediate
- **Opcode:** `0011` (0x3)
- **Format:** B-Type
- **Syntax:** `addi rds, imm`
- **Operation:** `rds ← rds + zero_extend(imm)`
- **Flags:** None
- **Cycles:** 7 (Fetch: 4, Execute: 3)
- **Note:** Immediate is zero-extended (NOT sign-extended)
- **Example:**
  ```
  addi r0, 5    ; R0 = R0 + 5
  Encoding: 0011 0101 = 0x35 (R0 = dest, imm = 5)
  ```

#### ADDM — Add from Memory
- **Opcode:** `0010` (0x2)
- **Format:** A-Type
- **Syntax:** `addm rds, rs`
- **Operation:** `rds ← rds + mem[rs]`
- **Flags:** None
- **Cycles:** 11 (Fetch: 4, Execute: 7)
- **Note:** Uses rs as memory address
- **Example:**
  ```
  addm r1, r0   ; R1 = R1 + mem[R0]
  Encoding: 0010 1000 = 0x28 (R1 = dest, R0 = addr src)
  ```

#### SUB — Subtract Registers
- **Opcode:** `0100` (0x4)
- **Format:** A-Type
- **Syntax:** `sub rds, rs`
- **Operation:** `rds ← rds - rs`
- **Flags:** None
- **Cycles:** 7 (Fetch: 4, Execute: 3)
- **Example:**
  ```
  sub r1, r0    ; R1 = R1 - R0
  Encoding: 0100 1000 = 0x48 (R1 = dest, R0 = src)
  ```

### Logical Operations

#### NAND — Bitwise NAND
- **Opcode:** `0000` (0x0)
- **Format:** A-Type
- **Syntax:** `nand rds, rs`
- **Operation:** `rds ← ~(rds & rs)`
- **Flags:** None
- **Cycles:** 7 (Fetch: 4, Execute: 3)
- **Note:** NAND is functionally complete (can implement any logic function)
- **Example:**
  ```
  nand r0, r1   ; R0 = ~(R0 & R1)
  Encoding: 0000 0100 = 0x04 (R0 = dest, R1 = src)
  ```

### Control Flow

#### JMP — Jump Relative
- **Opcode:** `1111` (0xF)
- **Format:** C-Type
- **Syntax:** `jmp offset`
- **Operation:** `PC ← PC + sign_extend(offset)`
- **Flags:** None
- **Cycles:** 7 (Fetch: 4, Execute: 3)
- **Note:** Offset is sign-extended, allows ±8 instruction range
- **Example:**
  ```
  jmp 7         ; Jump forward 7 bytes
  Encoding: 1111 0111 = 0xF7 (offset = +7)
  
  jmp -3        ; Jump backward 3 bytes
  Encoding: 1111 1101 = 0xFD (offset = -3, two's complement)
  ```

---

## Sign Extension Behavior

### Immediate Values (B-Type)

Immediate values in ADDI instructions are **zero-extended**:

```
Instruction: addi r0, 5    [0011 0101]
                            ─────
Immediate field: 101 (3 bits)
Zero-extended:   0000 0101 (8 bits) = 5
```

**Valid range:** 0 to 7

### Jump Offsets (C-Type)

Jump offsets are **sign-extended** for bidirectional branching:

```
Instruction: jmp 7         [1111 0111]
                            ────────
Offset field:    0111 (4 bits) = +7
Sign-extended:   0000 0111 (8 bits) = +7

Instruction: jmp -3        [1111 1101]
                            ────────
Offset field:    1101 (4 bits) = -3 (two's complement)
Sign-extended:   1111 1101 (8 bits) = -3
```

**Valid range:** -8 to +7

---

## Encoding Examples

### Example 1: Simple Arithmetic

```asm
addi r0, 5      ; R0 = 5
addi r1, 7      ; R1 = 7
add  r0, r1     ; R0 = R0 + R1 = 12
```

**Hex Encoding:**
```
0x35    ; addi r0, 5  → 0011 0101
0x3F    ; addi r1, 7  → 0011 1111
0x14    ; add  r0, r1 → 0001 0100
```

### Example 2: Memory Access

```asm
addi r0, 16     ; R0 = 16 (memory address)
addm r1, r0     ; R1 = R1 + mem[16]
```

**Hex Encoding:**
```
0x30    ; addi r0, 16 → 0011 0000  (note: 16 mod 8 = 0)
0x28    ; addm r1, r0 → 0010 1000
```

### Example 3: Loops

```asm
loop:
  addi r0, 1    ; R0 = R0 + 1
  jmp -2        ; Jump back to loop
```

**Hex Encoding:**
```
0x31    ; addi r0, 1  → 0011 0001
0xFE    ; jmp -2      → 1111 1110
```

---

## Register Encoding

The CPU has **2 general-purpose registers**:

| Register | Bit Value | Usage |
|----------|-----------|-------|
| R0       | 0         | General-purpose accumulator |
| R1       | 1         | General-purpose accumulator |

### Register Field Encoding

In A-Type and B-Type instructions:

- **ds (bit 3):** Destination register
  - `0` → R0
  - `1` → R1
  
- **s (bit 2):** Source register (A-Type only)
  - `0` → R0
  - `1` → R1

**Examples:**

| Operation | ds | s | Decoded |
|-----------|----|----|---------|
| `add r0, r0` | 0 | 0 | R0 = R0 + R0 |
| `add r0, r1` | 0 | 1 | R0 = R0 + R1 |
| `add r1, r0` | 1 | 0 | R1 = R1 + R0 |
| `add r1, r1` | 1 | 1 | R1 = R1 + R1 |

---

## ALU Operations

The ALU supports 4 operations, controlled by ALU0 and ALU1 signals:

| Operation | ALU0 | ALU1 | Function |
|-----------|------|------|----------|
| Add       | 1    | 1    | A + B |
| Subtract  | 1    | 0    | A - B |
| Multiply  | 0    | 1    | A × B |
| NAND      | 0    | 0    | ~(A & B) |

---

## Memory Model

### Address Space

- **Size:** 256 bytes (0x00 to 0xFF)
- **Addressability:** Byte-addressable
- **Access:** 1 cycle for read/write
- **Architecture:** Unified instruction/data memory (Von Neumann)

### Memory Map

```
0x00 - 0x0F    Instructions (16 bytes = ~16 instructions)
0x10 - 0xFF    Data memory (240 bytes)
```

**Note:** This is a logical layout; the CPU does not enforce separation. Instructions and data can be intermixed.

---

## Instruction Cycle Breakdown

### Standard Register-Register (e.g., ADD, SUB, NAND)

| State | Cycle | Action | Control Signals |
|-------|-------|--------|-----------------|
| 0     | 1     | MAR ← PC | PCout, MARin |
| 1     | 2     | MDR ← mem[MAR], Z ← PC + 1 | MemRead, Zin, #1out, ALU0, ALU1 |
| 2     | 3     | PC ← Z | PCin, Zout |
| 3     | 4     | IR ← MDR | MDRout, IRin |
| 4     | 5     | X ← Rsrc | Rsout, Xin |
| 5     | 6     | Z ← X op Rdst | Rdsout, Zin, ALU0, ALU1, Bus |
| 6     | 7     | Rdst ← Z | Rdsin, Zout |

**Total:** 7 cycles (4 fetch + 3 execute)

### Register-Immediate (e.g., ADDI)

Same as register-register but source comes from IR immediate field.

### Memory Access (e.g., ADDM)

| State | Cycle | Action | Control Signals |
|-------|-------|--------|-----------------|
| 0-3   | 1-4   | (Standard fetch) | — |
| 4     | 5     | MAR ← Rsrc | Rsout, MARin |
| 5     | 6     | X ← Rdst | Rdsout, Xin |
| 6     | 7     | MDR ← mem[MAR] | MemRead |
| 7     | 8     | Z ← X + MDR | MDRout, Zin, ALU0, ALU1, Bus |
| 8     | 9     | Rdst ← Z | Rdsin, Zout |

**Total:** 11 cycles (4 fetch + 7 execute)

### Jump (JMP)

| State | Cycle | Action | Control Signals |
|-------|-------|--------|-----------------|
| 0-3   | 1-4   | (Standard fetch) | — |
| 4     | 5     | X ← PC | PCout, Xin |
| 5     | 6     | Z ← X + offset | IRout, Zin, ALU0, ALU1, Offset |
| 6     | 7     | PC ← Z | PCin, Zout |

**Total:** 7 cycles (4 fetch + 3 execute)

---

## Programming Patterns

### Pattern 1: Move Immediate to Register

```asm
addi r0, 0      ; Clear R0
addi r0, 5      ; R0 = 5
```

### Pattern 2: Copy Register

```asm
; Copy R1 to R0 using addition
addi r0, 0      ; R0 = 0
add  r0, r1     ; R0 = R0 + R1 = R1
```

### Pattern 3: Negate a Register

```asm
; Negate R0 (two's complement)
nand r0, r0     ; R0 = ~R0
addi r0, 1      ; R0 = R0 + 1 = -R0
```

### Pattern 4: Conditional Branching (Simulated)

```asm
; Since we lack flags, conditional jumps must be emulated
; This is a limitation of the minimal ISA
; Workaround: Use unconditional jumps with computed offsets
```

---

## Instruction Set Limitations

1. **No Flags:** No zero, carry, or overflow flags
   - Cannot detect arithmetic overflow
   - No native conditional branching

2. **Limited Registers:** Only R0 and R1
   - Requires frequent memory access for complex operations

3. **Small Immediate Range:** Only 0-7 for immediates
   - Larger values require loading from memory

4. **Small Jump Range:** Only ±8 instructions
   - Long jumps require multiple jump instructions

5. **No Stack Operations:** No PUSH/POP or stack pointer
   - Function calls must be manually managed

---

## Future ISA Extensions

### Proposed New Instructions

| Opcode | Mnemonic | Operation | Priority |
|--------|----------|-----------|----------|
| `0101` | MULT     | `rds = rds * rs` | High |
| `0110` | OR       | `rds = rds | rs` | Medium |
| `0111` | XOR      | `rds = rds ^ rs` | Medium |
| `1000` | SHL      | `rds = rds << 1` | Medium |
| `1001` | SHR      | `rds = rds >> 1` | Medium |
| `1010` | LOAD     | `rds = mem[imm]` | High |
| `1011` | STORE    | `mem[imm] = rds` | High |
| `1100` | BEQ      | Branch if equal | High |
| `1101` | BNE      | Branch if not equal | High |
| `1110` | NOP      | No operation | Low |

---

## Assembler Guidelines

When writing assembly for this CPU:

1. **Always initialize registers** before use (no implicit zero)
2. **Plan memory layout** carefully (instructions vs. data)
3. **Manually calculate jump offsets** (no labels yet)
4. **Use NAND creatively** to implement other logic operations
5. **Minimize memory access** due to longer cycle count

---

*For microcode-level details, see [MICROCODE.md](MICROCODE.md)*
