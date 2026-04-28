`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV
`include "transaction.sv"

class scoreboard;
  mailbox mon2scb;
  int count = 0;

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task main();
    transaction trans;
    forever begin
      mon2scb.get(trans); // Get data from Monitor
      count++;
      if(trans.data_in !== 8'hxx) begin
        $display("[SCOREBOARD] Packet #%0d Verified! Data: %h", count, trans.data_in);
      end else begin
        $error("[SCOREBOARD] Packet #%0d ERROR: Invalid Data Captured!", count);
      end
    end
  endtask
endclass
`endif
