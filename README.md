# Design Verification

## Simple class-based bus verification

Both examples use separate transaction, generator, driver, monitor and scoreboard
files. The generator randomizes one request and waits for the scoreboard before
sending the next. No UVM or separate test class is used.

| Project | Source and explanation | Runnable Playground | Validation |
|---|---|---|---|
| AHB-Lite | [AHB/simple](AHB/simple/README.md) | [Run AHB](https://www.edaplayground.com/x/jXkh) | 100 transfers, zero errors |
| AXI4-Lite subset | [Axi_lite/simple](Axi_lite/simple/README.md) | [Run AXI](https://www.edaplayground.com/x/kZRD) | 100 transfers, zero errors |

Validated with Synopsys VCS 2025.06, seed 42. Each example checked 55 writes and
45 reads. These are focused beginner examples, not full protocol verification:
AHB stimulus uses 32-bit SINGLE accesses; AXI is full-word-only without WSTRB.
Read each example's README for its precise scope and run instructions.

Original learning examples remain in their existing folders.
