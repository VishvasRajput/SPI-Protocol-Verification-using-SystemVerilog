`ifndef TRANSACTION_SV
`define TRANSACTION_SV

class transaction;
  rand bit [7:0] data_in;
  bit mosi;
  bit busy;

  function void display(string name);
    $display("-------------------------");
    $display("- %s", name);
    $display("- Data Sent: %d (0x%h)", data_in, data_in);
    $display("-------------------------");
  endfunction
endclass

`endif