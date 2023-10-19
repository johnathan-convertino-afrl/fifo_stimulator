# AFRL FIFO Stimulator
### FIFO Stimulator modules
---

   author: Jay Convertino   
   
   date: 2022.08.10  
   
   details: FIFO Stimulator, create and write device under test data to and from a file.   
   
   license: MIT   
   
---

### Version
#### Current
  - V1.0.0 - initial release

#### Previous
  - none

### Dependencies
#### Build
  - AFRL:utility:helper:1.0.0
  - AFRL:vpi:binary_file_io:1.0.0
  
#### Simulation
  - AFRL:simulation:clock_stimulator
  - AFRL:utility:sim_helper

### IP USAGE
#### INSTRUCTIONS

This core contains two modules. A writer, and reader that should be placed on the  
output, and input of the device under test. This will stream data through till  
is has read all data.

### COMPONENTS
#### SRC

* tm_stim_fifo.v
  
#### TB

* tb_fifo.v
  
### fusesoc

* fusesoc_info.core created.
* Simulation uses icarus to run data through the core.

#### TARGETS

* RUN WITH: (fusesoc run --target=sim VENDER:CORE:NAME:VERSION)
  - default (for IP integration builds)
  - sim
  - sim_rand_data
  - sim_rand_full_rand_data
  - sim_8bit_count_data
  - sim_rand_full_8bit_count_data
