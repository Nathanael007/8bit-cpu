# Test Program - Assembly Version

This is the human-readable assembly version of the test program included in the CPU.

## Program: Basic Arithmetic and Memory Operations

```asm
; Test Program for 8-Bit CPU
; Demonstrates: Immediate loads, register arithmetic, memory access, jumps
; Expected output shown in comments

; Memory address 0x00
addi r0, 5      ; R0 = 5
                ; Expected: R0 = 0x05, R1 = 0x00

; Memory address 0x01
addi r1, 7      ; R1 = 7
                ; Expected: R0 = 0x05, R1 = 0x07

; Memory address 0x02
add  r0, r1     ; R0 = R0 + R1 = 5 + 7 = 12
                ; Expected: R0 = 0x0C, R1 = 0x07

; Memory address 0x03
sub  r1, r0     ; R1 = R1 - R0 = 7 - 12 = -5
                ; Expected: R0 = 0x0C, R1 = 0xFB (two's complement -5)

; Memory address 0x04
addi r0, 4      ; R0 = R0 + 4 = 12 + 4 = 16
                ; Expected: R0 = 0x10, R1 = 0xFB

; Memory address 0x05
addm r1, r0     ; R1 = R1 + mem[R0] = -5 + mem[0x10]
                ; mem[0x10] contains 0x75 (117 decimal)
                ; R1 = -5 + 117 = 112
                ; Expected: R0 = 0x10, R1 = 0x70

; Memory address 0x06
jmp  7          ; Jump forward 7 bytes to address 0x0D
                ; (PC after fetch would be 0x07, so 0x07 + 0x07 = 0x0E)
                ; Program continues at address 0x0D

; Memory address 0x07-0x0F: Not executed (skipped by jump)

; Memory address 0x10: Data (not instruction)
; Contains value 0x75 (117 decimal) used by ADDM instruction
.byte 0x75      ; Data: 117

; Memory addresses 0x11-0xFF: Unused
```

## Hex Encoding

The above assembly translates to the following machine code:

```
Address  | Hex   | Binary      | Instruction
---------|-------|-------------|------------------
0x00     | 0x35  | 0011 0101   | addi r0, 5
0x01     | 0x3F  | 0011 1111   | addi r1, 7
0x02     | 0x14  | 0001 0100   | add  r0, r1
0x03     | 0x48  | 0100 1000   | sub  r1, r0
0x04     | 0x34  | 0011 0100   | addi r0, 4
0x05     | 0x28  | 0010 1000   | addm r1, r0
0x06     | 0xF7  | 1111 0111   | jmp  7
0x07-0x0F| 0x00  | 0000 0000   | (unused)
0x10     | 0x75  | 0111 0101   | (data: 117)
0x11-0xFF| 0x00  | 0000 0000   | (unused)
```

## Instruction Breakdown

### 1. ADDI R0, 5 [0x35]

```
Binary: 0011 0101
        ─┬─┘ └┬┘
         │    └─ Immediate = 5 (101 in binary)
         │       ds = 0 (R0)
         └────── Opcode = 0011 (ADDI)

Operation: R0 ← R0 + 5
Result: R0 = 5
```

### 2. ADDI R1, 7 [0x3F]

```
Binary: 0011 1111
        ─┬─┘ └┬┘
         │    └─ Immediate = 7 (111 in binary)
         │       ds = 1 (R1)
         └────── Opcode = 0011 (ADDI)

Operation: R1 ← R1 + 7
Result: R1 = 7
```

### 3. ADD R0, R1 [0x14]

```
Binary: 0001 0100
        ─┬─┘ │││
         │   ││└─ Extra bits
         │   │└── s = 0 (source = R0... wait, this is wrong!)
         │   └─── ds = 1 (wait, also seems wrong)

Let me recalculate:
Binary: 0001 0100
        ─┬─┘ │││
         │   ││└─ Extra bits (00)
         │   │└── s = 1 (source = R1) ✓
         │   └─── ds = 0 (dest = R0) ✓
         └────── Opcode = 0001 (ADD)

Operation: R0 ← R0 + R1 = 5 + 7
Result: R0 = 12 (0x0C)
```

### 4. SUB R1, R0 [0x48]

```
Binary: 0100 1000
        ─┬─┘ │││
         │   ││└─ Extra bits (00)
         │   │└── s = 0 (source = R0) ✓
         │   └─── ds = 1 (dest = R1) ✓
         └────── Opcode = 0100 (SUB)

Operation: R1 ← R1 - R0 = 7 - 12 = -5
Result: R1 = 0xFB (two's complement of -5)
```

### 5. ADDI R0, 4 [0x34]

```
Binary: 0011 0100
        ─┬─┘ └┬┘
         │    └─ Immediate = 4 (100 in binary)
         │       ds = 0 (R0)
         └────── Opcode = 0011 (ADDI)

Operation: R0 ← R0 + 4 = 12 + 4
Result: R0 = 16 (0x10)
```

### 6. ADDM R1, R0 [0x28]

```
Binary: 0010 1000
        ─┬─┘ │││
         │   ││└─ Extra bits (00)
         │   │└── s = 0 (address source = R0) ✓
         │   └─── ds = 1 (dest = R1) ✓
         └────── Opcode = 0010 (ADDM)

Operation: R1 ← R1 + mem[R0] = -5 + mem[0x10]
           mem[0x10] = 0x75 (117 decimal)
           R1 = 251 + 117 = 368 (overflow)
           R1 = 368 mod 256 = 112 (0x70)

Actually in two's complement:
           R1 (0xFB) = -5 in signed
           mem[0x10] (0x75) = 117 in unsigned
           -5 + 117 = 112 (0x70)
Result: R1 = 112 (0x70)
```

### 7. JMP 7 [0xF7]

```
Binary: 1111 0111
        ─┬─┘ └┬─┘
         │    └─ Offset = 7 (0111 in binary)
         └────── Opcode = 1111 (JMP)

Operation: PC ← PC + sign_extend(7)
           Current PC after fetch = 0x07
           New PC = 0x07 + 0x07 = 0x0E
Result: Jump to address 0x0E
```

## Expected Register States After Each Instruction

| Instruction | After PC | R0   | R1   | Notes |
|-------------|----------|------|------|-------|
| Initial     | 0x00     | 0x00 | 0x00 | Power-on state |
| addi r0, 5  | 0x01     | 0x05 | 0x00 | R0 initialized |
| addi r1, 7  | 0x02     | 0x05 | 0x07 | R1 initialized |
| add r0, r1  | 0x03     | 0x0C | 0x07 | 5 + 7 = 12 |
| sub r1, r0  | 0x04     | 0x0C | 0xFB | 7 - 12 = -5 |
| addi r0, 4  | 0x05     | 0x10 | 0xFB | 12 + 4 = 16 |
| addm r1, r0 | 0x06     | 0x10 | 0x70 | -5 + 117 = 112 |
| jmp 7       | 0x0E     | 0x10 | 0x70 | Jump executed |

## Two's Complement Explanation

The value 0xFB represents -5 in 8-bit two's complement:

```
0xFB = 1111 1011 (binary)

To find the decimal value:
1. Invert all bits:  0000 0100
2. Add 1:            0000 0101 = 5
3. Result: -5

To verify: -5 in two's complement
1. Start with 5:     0000 0101
2. Invert all bits:  1111 1010
3. Add 1:            1111 1011 = 0xFB ✓
```

## Memory Layout

```
Address Range | Contents           | Purpose
--------------|-------------------|------------------
0x00 - 0x06   | Instructions      | Program code
0x07 - 0x0F   | Zeros (0x00)      | Unused (jumped over)
0x10          | Data (0x75)       | Data accessed by ADDM
0x11 - 0xFF   | Zeros (0x00)      | Unused memory
```

## Execution Timeline

```
Clock Cycles: 0    4    8    12   16   20   24   28   32   36   40   44   48   52
              │    │    │    │    │    │    │    │    │    │    │    │    │    │
Instructions: └──1─┴──2─┴──3─┴──4─┴──5─┴────6────┴──7─┴
              
1: addi r0, 5    (7 cycles: 4 fetch + 3 execute)
2: addi r1, 7    (7 cycles)
3: add r0, r1    (7 cycles)
4: sub r1, r0    (7 cycles)
5: addi r0, 4    (7 cycles)
6: addm r1, r0   (11 cycles: 4 fetch + 7 execute)
7: jmp 7         (7 cycles)

Total: 53 cycles
```

## Notes

1. **Memory at 0x10:** The value 0x75 (117) is placed at address 0x10 specifically for the ADDM instruction to access.

2. **Jump Destination:** The jump instruction at address 0x06 jumps to 0x0E, which is beyond the current program, effectively halting execution.

3. **Arithmetic Overflow:** The 8-bit CPU does not detect overflow. The ADDM operation effectively performs modulo-256 arithmetic.

4. **Signed vs Unsigned:** The CPU treats all values as unsigned during arithmetic, but the programmer can interpret them as signed (two's complement) when needed.
