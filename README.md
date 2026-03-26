# AMBA-AXI3-Protocol-Verification

# AXI Burst Feature Verification — UVM Testbench

A UVM-based verification environment for the **AXI (Advanced eXtensible Interface) burst feature**, covering all three AXI burst types: **FIXED**, **INCR (Incrementing)**, and **WRAP**.

---

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [AXI Burst Types](#axi-burst-types)
- [Signal Configuration](#signal-configuration)
- [Sequences & Tests](#sequences--tests)
- [Scoreboard & Coverage](#scoreboard--coverage)
- [How to Run](#how-to-run)
- [Dependencies](#dependencies)

---

## Overview

This project implements a complete UVM verification environment for an AXI master-slave interface with burst transaction support. The testbench drives AXI write and read transactions with configurable burst types and validates correctness through a self-checking scoreboard.

**Key parameters (defined in `axi_common.sv`):**

| Parameter    | Value |
|-------------|-------|
| `DATA_WIDTH` | 64 bits |
| `ADDR_WIDTH` | 32 bits |
| `STRB_WIDTH` | 8 bits (DATA_WIDTH / 8) |

---

## Project Structure

```
axi_burst/
├── axi_common.sv       # Shared macros, typedefs, and static counters
├── axi_tx.sv           # AXI sequence item (transaction object)
├── axi_seq_lib.sv      # Sequence library (wr_rd_seq, axi_2wr_rd_seq)
├── axi_sqr.sv          # Sequencer (typedef of uvm_sequencer)
├── axi_intrf.sv        # AXI interface definition (all 5 channels)
├── axi_driver.sv       # Master driver — drives all AXI channel phases
├── axi_monitor.sv      # Shared monitor — used by both master & slave agents
├── axi_cov.sv          # Functional coverage (write/read covergroup)
├── axi_magent.sv       # Master agent (driver + sequencer + monitor + coverage)
├── axi_responder.sv    # Slave responder — handles handshakes & burst logic
├── axi_sagent.sv       # Slave agent (responder + monitor)
├── axi_sbd.sv          # Scoreboard — compares master vs slave transactions
├── axi_env.sv          # Environment (master agent + slave agent + scoreboard)
├── axi_test_lib.sv     # Test library (base_test, test_1wr, test_2wr_rd)
├── top.sv              # Top-level testbench module
├── list.svh            # Compilation include list (ordered)
└── run.do              # QuestaSim run script
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        axi_env                          │
│                                                         │
│  ┌──────────────────────┐   ┌────────────────────────┐  │
│  │      axi_magent      │   │      axi_sagent        │  │
│  │  (Master Agent)      │   │  (Slave Agent)         │  │
│  │                      │   │                        │  │
│  │  ┌──────────────┐    │   │  ┌──────────────────┐  │  │
│  │  │  axi_driver  │    │   │  │  axi_responder   │  │  │
│  │  └──────┬───────┘    │   │  └──────────────────┘  │  │
│  │         │            │   │                        │  │
│  │  ┌──────┴───────┐    │   │  ┌──────────────────┐  │  │
│  │  │   axi_sqr    │    │   │  │   axi_monitor    │  │  │
│  │  └──────────────┘    │   │  └────────┬─────────┘  │  │
│  │                      │   │           │            │  │
│  │  ┌──────────────┐    │   └───────────┼────────────┘  │
│  │  │  axi_monitor │    │               │               │
│  │  └──────┬───────┘    │               │               │
│  │         │            │    ┌──────────▼──────────┐    │
│  │  ┌──────▼───────┐    │    │      axi_sbd        │    │
│  │  │   axi_cov    │    │    │   (Scoreboard)      │    │
│  │  └──────────────┘    │    └─────────────────────┘    │
│  └──────────────────────┘                               │
└─────────────────────────────────────────────────────────┘
                        │
               ┌────────▼────────┐
               │   axi_intrf     │
               │  (Interface)    │
               └─────────────────┘
```

---

## AXI Burst Types

The responder (`axi_responder.sv`) fully implements all three AXI burst modes:

### FIXED
- Address stays constant for every beat.
- Data beats are pushed into a flat FIFO queue on writes and popped on reads.
- Useful for repeated access to the same register or FIFO-mapped peripheral.

### INCR (Incrementing)
- Address increments by `2^size` bytes after each beat.
- Data is stored in/read from an associative memory (`mem[addr]`) byte by byte.
- The most commonly used burst type for block memory transfers.

### WRAP
- Address increments like INCR but wraps around within a calculated boundary.
- Wrap boundaries are computed as:
  - `total_bytes = (2^size) × (len + 1)`
  - `wrap_lower  = addr − (addr % total_bytes)`
  - `wrap_upper  = wrap_lower + total_bytes − 1`
- Used for cache-line fills where the critical word is fetched first.

---

## Signal Configuration

The `axi_intrf` interface covers all five AXI channels:

| Channel              | Key Signals |
|----------------------|-------------|
| Write Address (AW)   | `awid`, `awaddr`, `awlen`, `awsize`, `awburst`, `awvalid`, `awready` |
| Write Data (W)       | `wid`, `wdata`, `wstrb`, `wlast`, `wvalid`, `wready` |
| Write Response (B)   | `bid`, `bresp`, `bvalid`, `bready` |
| Read Address (AR)    | `arid`, `araddr`, `arlen`, `arsize`, `arburst`, `arvalid`, `arready` |
| Read Data (R)        | `rid`, `rdata`, `rresp`, `rlast`, `rvalid`, `rready` |

---

## Sequences & Tests

### Sequence Library (`axi_seq_lib.sv`)

| Sequence         | Description |
|-----------------|-------------|
| `base_seq`       | Base sequence class |
| `wr_rd_seq`      | Performs one write followed by one read with matching address, id, len, size, and burst (INCR, size=3) |
| `axi_2wr_rd_seq` | Runs `wr_rd_seq` twice back-to-back |

### Test Library (`axi_test_lib.sv`)

| Test            | Sequence Used     | Description |
|----------------|-------------------|-------------|
| `base_test`     | —                 | Instantiates env; prints topology |
| `test_1wr`      | `wr_rd_seq`       | Single write-read pair |
| `test_2wr_rd`   | `axi_2wr_rd_seq`  | Two write-read pairs |

> **Note:** `top.sv` calls `run_test("test_5wr_rd")` — add `test_5wr_rd` to `axi_test_lib.sv` before running, or change the test name to an existing test.

---

## Scoreboard & Coverage

### Scoreboard (`axi_sbd.sv`)
- Receives transactions from the **master monitor** via `write_ap` and from the **slave monitor** via `read_ap`.
- Compares each master transaction against the corresponding slave transaction using UVM's built-in `compare()`.
- Prints a **TEST-PASSED / TEST-FAILED** summary with match/mismatch counts in the report phase.

### Coverage (`axi_cov.sv`)
- Implements a `uvm_subscriber` connected to the master monitor's analysis port.
- Covergroup `axi_c` samples the `wr_rd` field to track write and read transaction coverage.

---

## How to Run

The project targets **QuestaSim / ModelSim** and uses **UVM 1.2**.

1. Open QuestaSim and set the working directory to the `axi_burst/` folder.
2. Run the simulation script:

```tcl
do run.do
```

The script performs three steps:
- **Compile:** `vlog ../list.svh +incdir+<UVM_SRC_PATH>`
- **Elaborate:** `vsim -novopt top` with the UVM DPI library
- **Run:** `run -all` with all interface signals added to the wave window

> Update the UVM source path and DPI library path in `run.do` to match your local installation if they differ from the defaults.

---

## Dependencies

| Tool / Library  | Version  |
|----------------|----------|
| QuestaSim      | 10.7c (or compatible) |
| UVM            | 1.2      |
| SystemVerilog  | IEEE 1800-2012 or later |
