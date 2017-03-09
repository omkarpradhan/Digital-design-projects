### Synopsis


This project includes the HDL (Verilog) code to implement a traffic controller circuit using digital logic along with the testbench environment to test it.
### Requirements
* States:
 
 SAFE, NS_GREEN, NS_YELLOW, NS_RED, EW_GREEN, EW_YELLOW, EW_RED
 
* Inputs:

  Clock, reset
  
* Outputs:

  Enable signals for the 6 possible traffic signal lights i.e. (ns_green, ns_yellow,..., ns_red)

### Modules
1. traffic_controller_v1
  
  Since only 7 states are explicitely mentioned in the requirements an additional SAFE state is added so that a cyclic state transition 
  is implemented.
  
2. traffic_controller_v2
  
  Only 7 states are used and a NS/EW direction check logic is included.
  
3. traffic_controller_v2
  
  Some changes are made to v2 after the Vivado synthesis step removed certain signals (for e.g. hold time registers should be continously assigned instead of setting them inside the counter ff).
### Tests

Use 'testbench.sv' to instantiate an approprite memory module (e.g. traffic_controller)

## Contributors

Omkar Pradhan

