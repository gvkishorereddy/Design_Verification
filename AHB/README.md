# AHB examples

Start with [simple/README.md](simple/README.md) for the small generator-based
AHB-Lite example matching the simple AXI verification structure. It uses
transaction, generator, driver, independent monitor and scoreboard classes.

Run it online: https://www.edaplayground.com/x/jXkh

The original `src/`, `testbench/` and `files.f` remain the separate burst-learning
example. They were not validated by the new simple example's simulation. In
particular, the original transfer-type encodings and internal-address monitoring
must be reviewed before treating it as protocol-correct verification.
