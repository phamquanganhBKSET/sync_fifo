# Directory layout
```bash
.
├───doc         # Design specs
├───hdl         # HDL code
├───inc         # Include file which declares all constants
├───libs
│   └───model   # Model which is used to check outputs of design
└───sim         # Simulation files
    ├───tb      # Top testbench
    └───work    # Scripts for simulation
```

# How to simulate by Questasim/Modelsim
1. Go to directory sim/work
2. Run the following commands
```sh
$ source run_bash.sh
$ vc
```
or simulate on GUI of Questasim/Modelsim
