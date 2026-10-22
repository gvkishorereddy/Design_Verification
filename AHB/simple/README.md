# Simple AHB-Lite verification

Runnable example: https://www.edaplayground.com/x/jXkh

Validated with Synopsys VCS 2025.06, seed 42: **100 transfers, 55 writes,
45 reads, zero scoreboard errors**. Reads included values from previous writes.
This is a focused simulation result, not a complete protocol verification claim.

This version follows the same small-class structure as the simple AXI-Lite example:
transaction, generator, driver, monitor and scoreboard. There is no UVM or separate
test class, no automatic readback and no extra random-delay controls.

## Flow

1. Generator randomizes one request and puts it in `mbxgd`.
2. Driver sends its address/control in an AHB address phase, then handles its data
   phase. It drives on falling clock edges and checks completion on rising edges.
3. Monitor independently captures accepted address/control, then samples data and
   response when that transfer completes. It does not read DUT internals.
4. Scoreboard stores writes in reference memory or checks reads, then triggers
   `sconext` to request the next randomized transaction.

The top creates/connects objects, mailboxes, the shared event and interface.
It runs the components concurrently and checks all 100 requests completed.

## What is randomized?

- Read versus write (`hwrite`).
- Byte address: 0, 4, 8, 12 or 16.
- Write data: 1 through 50.
- `hsize` is constrained to 010 (32 bits) and `hburst` to 000 (SINGLE).

Reads and writes access the same five locations, so random reads revisit earlier
writes without an extra readback loop. Initial memory words are 0x0c0c0c0c, as in
the original example's per-byte initialization. An unwritten read is compared to
this expected value, rather than being automatically treated as a pass.

## Protocol and scope

The included small RAM has 256 bytes, accepts legal aligned 32-bit transfers,
and inserts zero wait states. It captures address/control before using the next
data phase's HWDATA. For this one-slave bus, HREADYOUT directly supplies HREADY.
AHB-Lite HRESP is one bit. Correct HTRANS values are IDLE=00, BUSY=01,
NONSEQ=10 and SEQ=11.

This beginner stimulus issues one SINGLE transaction at a time. It does not
verify bursts, subword accesses, wait states, invalid-address error responses,
back-to-back throughput or reset during a transfer. Unsupported address/size
requests cause a simulation assertion failure. No complete protocol, functional
coverage or code coverage claim is made. Existing AHB/src and AHB/testbench
files remain the separate original burst example.

## Run

From this directory, use a SystemVerilog simulator supporting constrained
randomization, mailboxes and virtual interfaces, for example Synopsys VCS:

```
vcs -sverilog -f files.f
./simv +ntb_random_seed=42
```

Clock period: 10 ns (100 MHz). A watchdog catches hangs and scoreboard errors
fail simulation. The Playground version combines these same source files into
two editor panes for convenient execution; repository files remain separate.
