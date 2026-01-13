# Quick Start Guide

Get up and running with the 8-bit CPU in under 5 minutes!

---

## Prerequisites

Download and install **Logisim Evolution**:
- **Download:** [https://github.com/logisim-evolution/logisim-evolution/releases](https://github.com/logisim-evolution/logisim-evolution/releases)
- **Version:** 3.0 or higher recommended
- **Platform:** Windows, macOS, or Linux

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/migueljbeltran/8-bit-cpu.git
cd 8-bit-cpu
```

---

## Step 2: Open the Circuit

1. Launch Logisim Evolution
2. File → Open → Select `circuits/CPU.circ`
3. You should see the CPU datapath with all components

---

## Step 3: Load the Test Program

1. In Logisim, locate the **RAM** component (large rectangular block)
2. Right-click on RAM → **Load Image**
3. Navigate to and select `test-data/RAMcontent.txt`
4. The RAM should now show hex values starting with `35 3F 14 48...`

---

## Step 4: Run the Simulation

### Option A: Step-by-Step (Recommended for Learning)

1. Click **Simulate** → **Ticks Enabled** (or press Ctrl+K)
2. Click **Simulate** → **Tick Once** (or press Ctrl+T) to execute one cycle
3. Watch the values change in:
   - **R0 and R1 registers** (should show hex values)
   - **PC (Program Counter)** (increments as instructions execute)
   - **IR (Instruction Register)** (shows current instruction)
4. Continue pressing Ctrl+T to step through the program
5. Observe the final values:
   - R0 should end at **0x10** (16)
   - R1 should end at **0x70** (112)

### Option B: Continuous Run

1. Click **Simulate** → **Ticks Enabled** (Ctrl+K)
2. Click **Simulate** → **Auto-Tick Enabled** (Ctrl+E)
3. The simulation runs continuously
4. Click again to pause
5. To reset: **Simulate** → **Reset Simulation** (Ctrl+R)

---

## Step 5: Verify the Output

### Expected Register Values

After the test program completes, you should see:

| Register | Final Value | Decimal |
|----------|-------------|---------|
| R0       | 0x10        | 16      |
| R1       | 0x70        | 112     |

### Execution Trace

| Instruction | R0 (hex) | R1 (hex) | Description |
|-------------|----------|----------|-------------|
| addi r0, 5  | 0x05     | 0x00     | R0 = 5 |
| addi r1, 7  | 0x05     | 0x07     | R1 = 7 |
| add r0, r1  | 0x0C     | 0x07     | R0 = 5 + 7 = 12 |
| sub r1, r0  | 0x0C     | 0xFB     | R1 = 7 - 12 = -5 |
| addi r0, 4  | 0x10     | 0xFB     | R0 = 12 + 4 = 16 |
| addm r1, r0 | 0x10     | 0x70     | R1 = -5 + 117 = 112 |
| jmp 7       | 0x10     | 0x70     | Jump forward |

---

## Understanding What You're Seeing

### Key Components to Watch

1. **Bus (center):** The thick line showing data transfers
   - Data flows through this central path
   - Only one source can write to the bus at a time

2. **PC (Program Counter):** Top left
   - Shows current instruction address
   - Increments after each instruction fetch

3. **IR (Instruction Register):** Top center
   - Displays the currently executing instruction in hex
   - Example: `0x35` = `addi r0, 5`

4. **R0 and R1 (Registers):** Left side
   - General-purpose storage
   - Watch these change as arithmetic operations execute

5. **MAR (Memory Address Register):** Bottom left
   - Shows which memory address is being accessed

6. **MDR (Memory Data Register):** Bottom center
   - Shows data read from or written to memory

7. **ALU (Arithmetic Logic Unit):** Right side
   - Performs add, subtract, multiply, and NAND operations

8. **Z Register:** Far right
   - Temporarily stores ALU results before writing back

---

## Common Issues & Fixes

### Issue: RAM shows all zeros
**Fix:** Make sure you loaded `RAMcontent.txt` correctly:
1. Right-click the RAM component (not just in RAM area)
2. Select "Load Image"
3. Choose the correct file

### Issue: Nothing happens when I click "Tick Once"
**Fix:** Enable ticks first:
1. Simulate → Ticks Enabled (Ctrl+K)
2. Then try Tick Once (Ctrl+T)

### Issue: Registers don't update
**Fix:** Check that the simulation is running:
1. Look for a blinking cursor or changing values
2. Try resetting: Simulate → Reset Simulation (Ctrl+R)
3. Reload the RAM contents

### Issue: Unexpected register values
**Fix:** 
1. Reset the simulation (Ctrl+R)
2. Reload the test program
3. Step through slowly with Ctrl+T
4. Compare each step with the expected trace above

---

## Next Steps

### Explore the Architecture

- **Read the main README:** `README.md` for architecture overview
- **Study the ISA:** `docs/ISA_REFERENCE.md` for instruction details
- **Understand control:** `docs/CONTROL_SIGNALS.md` for signal descriptions

### Write Your Own Programs

1. Create a new assembly file in `assembly/`
2. Use the ISA reference to encode instructions
3. Create a new `.txt` file in hex format (like `RAMcontent.txt`)
4. Load it into the CPU and run!

Example program ideas:
- Sum of numbers 1 through 10
- Factorial calculator
- Fibonacci sequence
- Bitwise operations using NAND

### Modify the CPU

1. Add new instructions by updating the control ROM
2. Add more registers (R2, R3, etc.)
3. Implement a stack pointer
4. Add conditional branching with flags

---

## Keyboard Shortcuts

| Action | Windows/Linux | macOS |
|--------|---------------|-------|
| Tick Once | Ctrl+T | ⌘+T |
| Ticks Enabled | Ctrl+K | ⌘+K |
| Auto-Tick | Ctrl+E | ⌘+E |
| Reset Simulation | Ctrl+R | ⌘+R |
| Zoom In | Ctrl+= | ⌘+= |
| Zoom Out | Ctrl+- | ⌘+- |

---

## Getting Help

- **Issues:** [https://github.com/migueljbeltran/8-bit-cpu/issues](https://github.com/migueljbeltran/8-bit-cpu/issues)
- **Logisim Docs:** [http://www.cburch.com/logisim/docs.html](http://www.cburch.com/logisim/docs.html)
- **Email:** migueljoaquinbeltran@gmail.com

---

## Summary

You've just:
1. ✅ Opened the CPU circuit in Logisim
2. ✅ Loaded a test program into memory
3. ✅ Stepped through instruction execution
4. ✅ Verified correct operation

**Congratulations!** You're now ready to explore the architecture in depth or write your own programs.

---

*For detailed architecture documentation, see the main [README.md](../README.md)*
