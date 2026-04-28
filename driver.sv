`include "transaction.sv"

class driver;
  virtual spi_if vif; 
  mailbox gen2drv;    

  function new(virtual spi_if vif, mailbox gen2drv);
    this.vif = vif;
    this.gen2drv = gen2drv;
  endfunction

  // The main task that drives the RTL
  task main();  // <--- Only one 'task main();' here
    forever begin
      transaction trans;
      gen2drv.get(trans); 
      
      // Use the clocking block to drive signals
      vif.drv_cb.data_in <= trans.data_in;
      vif.drv_cb.start   <= 1'b1;
      
      // Wait for TWO clock cycles to ensure the RTL FSM catches it
      repeat(2) @(vif.drv_cb); 
      
      vif.drv_cb.start   <= 1'b0;
      
      // Wait for the RTL to finish
      wait(vif.busy == 1'b1);
      wait(vif.busy == 1'b0);
      
      $display("[DRIVER] Sent Data: %h", trans.data_in);
    end
  endtask
endclass