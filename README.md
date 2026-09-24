# AMBA APB to BRAM Slave Bridge

## Overview

This project implements an AMBA APB to BRAM Slave Bridge using Verilog HDL.

The main purpose of this project is to connect an APB master with a Block RAM (BRAM). The bridge receives read and write requests through the APB interface and converts them into the required control, address, and data signals for the BRAM.

The BRAM used in this project contains 32 locations, with each location storing 32 bits of data.

## Architecture

The project consists of four main modules:

### 1. top

The top module connects the APB slave controller and the BRAM module.

It acts as the main integration module for the design.

### 2. apb

This module works as the APB slave controller.

It is responsible for:

* Handling APB setup and access phases
* Detecting read and write operations
* Generating BRAM control signals
* Passing the address and write data to the BRAM
* Returning read data to the APB master
* Generating pready after completing a transfer
* Generating pslverr when an invalid address is accessed

The APB controller is implemented using a simple FSM with three states: idle, setup, and access.

### 3. bram

This module implements the memory.

The memory contains:

* 32 locations
* 32-bit data width

The address is used to select the required memory location for read and write operations.

### 4. tb

The testbench is used to verify the complete APB to BRAM connection.

It generates the clock and reset signals and applies APB read and write transactions to the design.

The testbench also generates a VCD file so that the signals can be observed using a waveform viewer.

## APB Interface

| Signal  | Direction |   Width | Description                             |
| ------- | --------- | ------: | --------------------------------------- |
| pclk    | Input     |   1 bit | APB clock                               |
| prst    | Input     |   1 bit | Active-high reset                       |
| psel    | Input     |   1 bit | Selects the APB slave                   |
| penable | Input     |   1 bit | Indicates the APB access phase          |
| pwrite  | Input     |   1 bit | 1 for write, 0 for read                 |
| paddr   | Input     | 32 bits | APB address                             |
| pwdata  | Input     | 32 bits | Data provided during a write            |
| prdata  | Output    | 32 bits | Data returned during a read             |
| pready  | Output    |   1 bit | Indicates that the transfer is complete |
| pslverr | Output    |   1 bit | Indicates an invalid address            |

## BRAM Interface

| Signal     | Direction |   Width | Description                   |
| ---------- | --------- | ------: | ----------------------------- |
| bram_en    | Internal  |   1 bit | Enables the BRAM              |
| bram_we    | Internal  |   1 bit | Controls BRAM write operation |
| bram_addr  | Internal  | 32 bits | BRAM address                  |
| bram_wdata | Internal  | 32 bits | Data written into BRAM        |
| bram_rdata | Internal  | 32 bits | Data read from BRAM           |

## APB FSM

The APB controller uses three states to handle the APB transaction.

### Idle

This is the default state after reset.

The controller waits for the APB master to select the slave by asserting psel.

When psel is high and penable is low, the controller moves to the setup state.

### Setup

In this state, the APB transaction is prepared.

When psel and penable are both high, the controller moves to the access state.

### Access

This is where the actual read or write operation takes place.

During this state:

* The BRAM is enabled
* The address is passed to the BRAM
* Write data is passed to the BRAM for write operations
* Read data is received from the BRAM for read operations
* pready is asserted
* The address is checked for errors

After the transfer is completed, the controller returns to the appropriate state for the next transaction.

## Address Checking

The BRAM has 32 memory locations, so the valid address range is 0 to 31.

If an address greater than 31 is accessed, the bridge considers it an invalid address and asserts pslverr.

This allows the APB master to know that the requested address is outside the available BRAM range.

## Verification

The testbench is used to check both write and read operations.

The basic test sequence is:

1. Apply reset.
2. Release the reset.
3. Perform an APB write transaction.
4. Wait for pready.
5. Perform an APB read transaction.
6. Wait for the transfer to complete.
7. Check the signals and waveform to verify the operation.

The testbench also uses $monitor to observe important signals and FSM states during simulation.

## Simulation

I used Icarus Verilog for simulation and GTKWave to view the generated waveforms.

### Compile

```bash
iverilog -o sim_top tb.v top.v
```

### Run

```bash
vvp sim_top
```

### View Waveform

```bash
gtkwave top.vcd
```

The project can also be simulated using tools such as Synopsys VCS or Cadence Xcelium.

### Synopsys VCS

```bash
vcs -full64 tb.v top.v -debug_access+all -o simv
./simv
```

### Cadence Xcelium

```bash
xrun tb.v top.v -access +rwc
```

##**EDA playground link:
for design:https://www.edaplayground.com/x/QzWt


## Project Structure

```text
APB-to-BRAM/
├── top.v
├── apb.v
├── bram.v
├── tb.v
├── top.vcd
└── README.md
```

## What I Practiced in This Project

Through this project, I worked on:

* APB protocol basics
* APB setup and access phases
* APB slave design
* FSM implementation
* BRAM read and write operations
* Address checking
* APB error handling
* Connecting multiple Verilog modules
* Testbench development
* Simulation and waveform debugging
