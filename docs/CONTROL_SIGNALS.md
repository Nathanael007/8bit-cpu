# Control Signals Reference

This document describes all 21 control signals used in the 8-bit CPU and their functions.

---

## Overview

The CPU uses a microcode-based control unit with **21 control signals** that orchestrate data movement and operations across **17 states** in the state machine.

### Signal Categories

1. **Register Control (14 signals):** Control data flow to/from registers
2. **ALU Control (3 signals):** Control ALU operations
3. **Memory Control (2 signals):** Control memory read/write
4. **Special Control (2 signals):** Bus multiplexing and offset handling

---

## Register Control Signals

### Program Counter (PC)

#### **PCin** — PC Input Enable
- **Function:** Loads the value from the Z register into the PC
- **Active:** High (1)
- **Usage:** Updating PC after increment or during jumps
- **Example States:** State 2 (normal increment), State 16 (jump)

#### **PCout** — PC Output Enable
- **Function:** Places the PC value onto the bus
- **Active:** High (1)
- **Usage:** Fetching instructions (send PC to MAR), jump calculations
- **Example States:** State 0 (instruction fetch)

### Instruction Register (IR)

#### **IRin** — IR Input Enable
- **Function:** Loads instruction from MDR into IR
- **Active:** High (1)
- **Usage:** Completing instruction fetch
- **Example States:** State 3 (load fetched instruction)

#### **IRout** — IR Output Enable
- **Function:** Places IR contents (or fields) onto bus
- **Active:** High (1)
- **Usage:** Accessing immediate values or offsets during execution
- **Example States:** State 8 (immediate instructions), State 11 (jumps)
- **Note:** Can output full IR or specific fields based on Bus Control

### General Purpose Registers (R0, R1)

In the original design, these were named R0in/R0out/R1in/R1out. In the final implementation with dynamic register selection, they're renamed:

#### **Rdsin** — Destination Register Input Enable
- **Function:** Loads value from Z register into destination register (specified by IR bit 3)
- **Active:** High (1)
- **Selection:** IR[3] = 0 → R0, IR[3] = 1 → R1
- **Usage:** Writing ALU results back to registers
- **Example States:** State 6 (register-register ops), State 9 (immediate ops)

#### **Rdsout** — Destination Register Output Enable
- **Function:** Places destination register onto bus or into X register
- **Active:** High (1)
- **Selection:** IR[3] = 0 → R0, IR[3] = 1 → R1
- **Usage:** Reading first ALU operand
- **Example States:** State 5 (before ALU operation)

#### **Rsin** — Source Register Input Enable
- **Function:** (Not typically used; registers are only written via Rdsin)
- **Active:** High (1)
- **Note:** In most architectures, source register is read-only during operation

#### **Rsout** — Source Register Output Enable
- **Function:** Places source register onto bus
- **Active:** High (1)
- **Selection:** IR[2] = 0 → R0, IR[2] = 1 → R1
- **Usage:** Reading second ALU operand or memory address
- **Example States:** State 4 (register arithmetic), State 13 (memory addressing)

### Memory Data Register (MDR)

#### **MDRin** — MDR Input Enable
- **Function:** Loads data from memory into MDR
- **Active:** High (1)
- **Usage:** Reading from memory during instruction fetch or data loads
- **Example States:** State 3 (instruction fetch), State 14 (memory read)
- **Note:** Typically level-triggered (always capturing when enabled)

#### **MDRout** — MDR Output Enable
- **Function:** Places MDR contents onto bus
- **Active:** High (1)
- **Usage:** Sending fetched data to IR or ALU
- **Example States:** State 3 (to IR), State 15 (memory operand to ALU)

### Memory Address Register (MAR)

#### **MARin** — MAR Input Enable
- **Function:** Loads address from bus into MAR
- **Active:** High (1)
- **Usage:** Specifying memory address for read/write operations
- **Example States:** State 0 (PC to MAR for fetch), State 13 (register to MAR for memory access)
- **Note:** MAR does not have an "out" signal; its output goes directly to memory

### ALU Operand Registers

#### **Xin** — X Register Input Enable
- **Function:** Loads value from bus into X register (first ALU operand)
- **Active:** High (1)
- **Usage:** Storing first operand before ALU operation
- **Example States:** State 0 (PC during increment), State 4 (register operand), State 14 (memory load)

#### **Zin** — Z Register Input Enable
- **Function:** Loads ALU result into Z register
- **Active:** High (1)
- **Usage:** Storing ALU output before writing to destination
- **Example States:** State 1 (PC+1), State 5 (register arithmetic), State 15 (memory arithmetic)

#### **Zout** — Z Register Output Enable
- **Function:** Places Z register contents onto bus
- **Active:** High (1)
- **Usage:** Transferring ALU results to destination
- **Example States:** State 2 (updated PC), State 6 (arithmetic result), State 16 (jump target)

### Constant Register (#1)

#### **#1out** — Constant "1" Output Enable
- **Function:** Places the constant value 1 onto the bus
- **Active:** High (1)
- **Usage:** Incrementing PC during instruction fetch
- **Example States:** State 1 (PC increment)
- **Note:** This is a special read-only register containing the value 1

---

## ALU Control Signals

The ALU performs one of four operations based on two control signals:

#### **ALU0** — ALU Control Bit 0
- **Function:** Selects ALU operation (LSB)
- **Active:** High (1) or Low (0)
- **Encoding:** See table below

#### **ALU1** — ALU Control Bit 1
- **Function:** Selects ALU operation (MSB)
- **Active:** High (1) or Low (0)
- **Encoding:** See table below

### ALU Operation Encoding

| ALU1 | ALU0 | Operation | Function | Used By |
|------|------|-----------|----------|---------|
| 0    | 0    | NAND      | ~(A & B) | NAND instruction |
| 0    | 1    | Multiply  | A × B    | MULT instruction (future) |
| 1    | 0    | Subtract  | A - B    | SUB instruction |
| 1    | 1    | Add       | A + B    | ADD, ADDI, ADDM, PC increment |

**Common Patterns:**
- PC increment: ALU1=1, ALU0=1 (PC + 1)
- Register addition: ALU1=1, ALU0=1
- Register subtraction: ALU1=1, ALU0=0

---

## Memory Control Signals

#### **MemRead** — Memory Read Enable
- **Function:** Requests data from memory at address in MAR
- **Active:** High (1)
- **Usage:** Instruction fetch and data load operations
- **Example States:** State 0-2 (instruction fetch), State 14 (data read)
- **Timing:** Data appears in MDR in the same cycle (combinational read)

#### **MemWrite** — Memory Write Enable
- **Function:** Writes data from MDR to memory at address in MAR
- **Active:** High (1)
- **Usage:** Store operations (not used in current ISA)
- **Example States:** None in current test program
- **Note:** Not implemented in minimal ISA but present for future extensions

---

## Special Control Signals

#### **BusControl** (or **Bus**)
- **Function:** Controls bus multiplexer to select different data sources
- **Active:** High (1)
- **Usage:** Selecting between register/memory data and immediate/offset values
- **States:** State 1 (during fetch), State 5 (register ops), State 15 (memory ops)
- **Note:** Exact behavior depends on Logisim implementation of multiplexers

#### **Offset**
- **Function:** Selects sign-extended offset field from IR for jump calculations
- **Active:** High (1)
- **Usage:** Jump instructions only
- **Example States:** State 11 (during jump execution)
- **Effect:** When active, IR bits [3:0] are sign-extended and placed on bus
- **Sign Extension:** 
  - If IR[3] = 0: offset is 0000_xxxx (positive)
  - If IR[3] = 1: offset is 1111_xxxx (negative)

---

## Control Signal Timing

### Example: Instruction Fetch (States 0-3)

```
State | Signals Active                           | Description
------|------------------------------------------|---------------------------
0     | PCout, MARin, MemRead, Xin              | MAR ← PC, X ← PC
1     | #1out, ALU0, ALU1, Zin, MemRead, Bus    | Z ← PC + 1
2     | PCin, Zout, MemRead                     | PC ← Z
3     | MDRout, IRin, MemRead                   | IR ← MDR (fetched instruction)
```

### Example: ADD R0, R1 (States 4-6)

```
State | Signals Active                           | Description
------|------------------------------------------|---------------------------
4     | Rsout, Xin                              | X ← R1 (source)
5     | Rdsout, Zin, ALU0, ALU1, Bus            | Z ← R0 + R1
6     | Rdsin, Zout                             | R0 ← Z
```

### Example: ADDI R0, 5 (States 4-6)

```
State | Signals Active                           | Description
------|------------------------------------------|---------------------------
4     | MARin, Xin                              | X ← R0
5     | IRout, Zin, ALU0, ALU1, Bus             | Z ← R0 + immediate
6     | Rdsin, Zout                             | R0 ← Z
```

### Example: JMP offset (States 10-12)

```
State | Signals Active                           | Description
------|------------------------------------------|---------------------------
10    | PCout, Xin                              | X ← PC
11    | IRout, Zin, ALU0, ALU1, Offset          | Z ← PC + sign_extend(offset)
12    | PCin, Zout                              | PC ← Z
```

---

## Boolean Equations for Control Signals

From the microcode truth table, control signals can be expressed as boolean functions of the current state (Y4-Y0):

### Examples:

**PCin** (Load PC from Z):
```
PCin = State2 + State12 + State16
     = (Y4'·Y3'·Y2'·Y1'·Y0'·Y0) + (Y4·Y3'·Y2·Y1'·Y0') + (Y4·Y3'·Y2'·Y1'·Y0')
```

**IRin** (Load IR from MDR):
```
IRin = State3
     = (Y4'·Y3'·Y2'·Y1·Y0)
```

**ALU0** (ALU control bit 0):
```
ALU0 = State1 + State5 + State8 + State11 + State15
     = Operations requiring addition or subtraction
```

**MemRead** (Read from memory):
```
MemRead = State0 + State1 + State2 + State3 + State13 + State14
        = All instruction fetch states + memory access states
```

---

## Control Signal Dependencies

### Mutually Exclusive Signals

These signals should **never be active simultaneously**:

1. **PCin and IRin** — Cannot load both PC and IR at once
2. **Rdsin and Rsin** — Cannot write to both register fields simultaneously
3. **Rdsout and Rsout** — Cannot read from both registers to bus at once
4. **MemRead and MemWrite** — Cannot read and write memory simultaneously

### Common Signal Combinations

These signals **often appear together**:

1. **ALU0 + ALU1 + Zin** — Performing addition (PC increment, arithmetic)
2. **PCout + MARin** — Loading PC into MAR for instruction fetch
3. **MDRout + IRin** — Completing instruction fetch
4. **Rdsin + Zout** — Writing ALU result to destination register
5. **MemRead + MARin** — Reading from memory address

---

## Tri-State Bus Control

The single bus architecture requires careful control to avoid bus conflicts:

### Bus Drivers (Sources)

Only **ONE** of these should be active at any time:
- PCout
- IRout
- Rdsout
- Rsout
- MDRout
- Zout
- #1out

### Bus Receivers (Destinations)

Multiple receivers can be active simultaneously:
- PCin
- IRin
- MARin
- Rdsin
- MDRin
- Xin

**Example:** In State 0, PCout and MARin are both active, allowing PC → MAR transfer.

---

## Signal Verification Checklist

When implementing or debugging the control unit, verify:

- ✅ Only one bus driver is active per cycle
- ✅ MemRead and MemWrite are never both active
- ✅ ALU operations have correct ALU0/ALU1 encoding
- ✅ Sign extension (Offset signal) is only active during jumps
- ✅ Register selection (ds, s bits) correctly routes to R0/R1
- ✅ Every state has a defined next state
- ✅ All 17 states are reachable from State 0
- ✅ Instruction fetch (States 0-3) is common to all instructions

---

## Implementation Notes

### Level-Triggered vs. Edge-Triggered

- **MDR and IR:** Recommended to be **level-triggered** for reliable operation
  - This means they capture data whenever the input enable signal is high
  - Ensures data is stable when transferred
  
- **Other Registers:** Can be **edge-triggered** (capture on clock edge)
  - More typical for synchronous digital design
  - Requires careful timing analysis

### Timing Considerations

1. **Setup Time:** Bus data must be stable before register input enable
2. **Hold Time:** Data must remain stable after input enable
3. **Clock Period:** Must be long enough for:
   - ALU computation
   - Bus propagation
   - Register setup/hold requirements

### Debugging Tips

1. **Use Logisim's Probe Tool:** Click components to see values
2. **Single-Step Execution:** Use "Tick Once" (Ctrl+T) to step through states
3. **Watch the Bus:** Monitor bus value to see data transfers
4. **Check State Machine:** Verify current state vs. expected state
5. **Verify Control ROM:** Ensure truth table matches specification

---

*For microcode state machine details, see [MICROCODE.md](MICROCODE.md)*
*For instruction execution flow, see [ISA_REFERENCE.md](ISA_REFERENCE.md)*
