
`ifndef MONITOR_SV
`define MONITOR_SV
`include "transaction.sv"

class monitor;
  virtual spi_if vif;
  mailbox mon2scb; // Mailbox to talk to Scoreboard

  function new(virtual spi_if vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction

  task main();
    forever begin
      transaction trans;
      trans = new();
      
      // 1. Wait for busy to go high (Start of transfer)
      @(posedge vif.busy);
      
      // 2. Sample 8 bits on the rising edges of SCLK
      repeat(8) begin
        @(posedge vif.sclk);
        trans.data_in = {trans.data_in[6:0], vif.mosi};
      end
      
      // 3. Wait for busy to go low (End of transfer)
      @(negedge vif.busy);
      
      $display("[MONITOR] Captured Data from SPI Bus: %h", trans.data_in);
      mon2scb.put(trans); // Send to Scoreboard
    end
  endtask
endclass
`endif