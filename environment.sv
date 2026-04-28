`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"    // Added
`include "scoreboard.sv" // Added

class environment;
  // Handles for all components
  generator  gen;
  driver     drv;
  monitor    mon;       // Added
  scoreboard scb;       // Added

  // Mailboxes
  mailbox    gen2drv;   // Generator to Driver
  mailbox    mon2scb;   // Monitor to Scoreboard (Added)

  virtual spi_if vif;

  function new(virtual spi_if vif);
    this.vif = vif;
    
    // 1. Initialize Mailboxes
    gen2drv = new();
    mon2scb = new();    // Added
    
    // 2. Initialize Components
    gen = new(gen2drv);
    drv = new(vif, gen2drv);
    mon = new(vif, mon2scb); // Added
    scb = new(mon2scb);      // Added
  endfunction

  task test();
    // Start all components in parallel
    fork
      gen.main(); 
      drv.main(); 
      mon.main(); // Added
      scb.main(); // Added
    join_any      
    
    // Small delay to allow the last packet to finish in the Scoreboard
    #100;
  endtask
endclass