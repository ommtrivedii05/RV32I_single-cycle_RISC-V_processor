# 🖥️ 32-bit RISC-V Style CPU (RV32I) – Verilog Implementation

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![Architecture](https://img.shields.io/badge/Architecture-RISC--V-green)
![Status](https://img.shields.io/badge/Project-70%25%20Complete-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

A **32-bit RISC-style processor** inspired by the **RV32I instruction set architecture**, implemented entirely in **Verilog HDL**.

This project focuses on building a **modular single-cycle RISC-V CPU** to understand processor design, datapath architecture, and hardware verification.

> ⚠️ **Project Status:** ~70% complete. Verification and testing are currently in progress.

---

# 📚 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Supported Instructions](#supported-instructions)
- [Simulation](#simulation)
- [Verification Status](#verification-status)
- [Future Work](#future-work)
- [Author](#author)
- [License](#license)

---

# 🔍 Overview

This project implements a **single-cycle 32-bit RISC-V style processor** with a modular RTL design.

The goal is to explore:

- Processor datapath design
- Control unit implementation
- Instruction decoding
- Register file design
- Memory interfacing
- Hardware verification using testbenches

All modules are written in **synthesizable Verilog**.

---

# 🧠 Architecture

The CPU follows a **single-cycle datapath architecture**, where each instruction is executed within one clock cycle.

### Core Components

- **Program Counter (PC)**
- **Instruction Memory**
- **Instruction Decoder / Controller**
- **Register File**
- **Immediate Generator**
- **ALU Control Unit**
- **Arithmetic Logic Unit (ALU)**
- **Branch Unit**
- **Data Memory**
- **Next PC Logic**

---
32-bit-risc-style-cpu
│
├── alu-control.v # Generates ALU control signals
├── alu.v # Arithmetic Logic Unit
├── branchunit.v # Branch decision logic
├── datamem.v # Data memory module
├── decoder_controller.v # Instruction decoder & control signals
├── immgen.v # Immediate generator
├── instrmem.v # Instruction memory
├── pc_next.v # Next PC calculation logic
├── pc_reg.v # Program counter register
└── regfile.v # Register file (32 registers)


---

# ⚙️ Supported Instructions

Currently implemented instructions include a subset of **RV32I**.

### Arithmetic / Logical

- ADD
- SUB
- AND
- OR
- XOR

### Immediate Instructions

- ADDI
- ANDI
- ORI

### Memory Operations

- LW
- SW

### Branch Instructions

- BEQ
- BNE

### Planned

- JAL
- JALR
- SLT
- Full RV32I support

---

# 🧪 Simulation

The design can be simulated using:

- **Icarus Verilog**
- **ModelSim**
- **Vivado Simulator**
- **GTKWave**

### Example (Icarus Verilog)

```bash
iverilog -o cpu_tb *.v
vvp cpu_tb
gtkwave dump.vcd

🚀 Future Work

Complete testbench verification

Add support for full RV32I instruction set

Implement pipeline architecture

Add FPGA synthesis support

Improve documentation and diagrams
