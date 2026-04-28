`include "transaction.sv"  // Add this line at the top

class generator;
  transaction trans;
  // ... rest of your code
  mailbox gen2drv;       // Mailbox to send data to the Driver
  event ended;           // Event to tell the Testbench we are done
  int repeat_count;      // How many packets to send

  function new(mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task main();
    repeat(repeat_count) begin
      trans = new();
      if(!trans.randomize()) $fatal("Gen: Randomization Failed!");
      
      trans.display("Generator");
      gen2drv.put(trans); // Put the "letter" in the mailbox for the Driver
    end
    -> ended; // Trigger the "I'm finished" event
  endtask
endclass
