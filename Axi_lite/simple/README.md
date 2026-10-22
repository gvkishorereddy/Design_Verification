# Simple generator-based AXI-Lite verification

Playground: https://www.edaplayground.com/x/kZRD

Plain SystemVerilog classes, close to the original GitHub organization:
transaction, generator, driver, monitor, scoreboard. No UVM or separate test class.

## Flow

1. Generator creates and randomizes one transaction, puts it into `gen_drv`,
   and waits for `next_input`.
2. Driver gets it and performs a write or read through the interface.
3. Monitor independently captures actual rising-clock VALID/READY handshakes.
4. Scoreboard receives the observed operation through `mon_sco`, checks it,
   increments its count, and triggers the event allowing the next request.

The top module creates/connects everything, resets the DUT, and starts driver,
monitor and scoreboard concurrently while running the generator.

## What is randomized?

- Operation: read or write (`rand bit op`).
- Write and read byte addresses: 0, 4, 8, 12, or 16.
- Write data: 0 through 11.

There are 100 total randomized requests. No extra readback requests are inserted.
Reads select these same five locations, so they naturally revisit previously
written locations. A read before any write to that location must return zero,
because the DUT reset and scoreboard both initialize memory to zero.

## Handshakes and checking

The driver sends AW first, then W, then accepts B. For a read, it sends AR and
then accepts R. Each sender holds VALID until a rising-clock handshake.
Driving on falling edges avoids races with rising-edge DUT sampling.
The monitor gets no transaction or completion message from the driver. It
creates a fresh object for every completed write/read and samples response and
read-data signals as four-state logic.
The scoreboard stores successful writes in a 128-word reference array and
compares read data and OKAY responses. Byte addresses are divided by four to
obtain word indices. Errors fail the simulation; a watchdog catches hangs.

## Scope

The included DUT has 128 x 32-bit memory with byte addresses, simulated at
100 MHz (10 ns period). It implements a full-word-only AXI4-Lite subset without
WSTRB/protection attributes. This simple stimulus tests only valid accesses to
five locations, AW-first writes, and one complete operation at a time. It does
not claim invalid-address, W-first/simultaneous-write-channel, backpressure,
multiple-outstanding, mid-transfer-reset, or complete memory/coverage testing.

## Running

Validated with Synopsys VCS 2025.06, random seed 42: 100 transactions,
55 writes, 45 reads, zero scoreboard errors. Reads included nonzero data
stored by earlier random writes. See `simulation_summary.txt`.

Use Synopsys VCS with SystemVerilog enabled, as selected in Playground:

```
vcs -sverilog design.sv testbench.sv
./simv +ntb_random_seed=42
```

Icarus Verilog does not support this testbench's constrained-random
classes, mailboxes and virtual interfaces. Validation uses Playground VCS.
