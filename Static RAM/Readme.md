### Synopsis


This project includes the HDL (Verilog) code to implement a Static RAM (SRAM) circuit along with the testbench environment to test it.


### Modules
1. SRAM_DFF_v1
  
  All the necessary address decode, memory storage and read data demultiplexing is combined into a single module along with detailed commenting to be consistent with industry standard best coding practices.
  
2. SRAM_DFF_v2
  
  Submodules are instantiated in this module. The sub modules handle address decode logic, D-FF based memory logic and read data multiplexing. The sub module HDL code can be found in the "Digitial-design-projects/Common Modules" folder.

### Tests
----------------------------------------------------------------------------------------------------------------------------------------
Use 'testbench.sv' to instantiate an approprite memory module (e.g. SRAM_DFF) to which address and write data can be passed as input to the module and then data from the selected memory location can be read as an output from the module.

## Contributors

Omkar Pradhan

