`include "spi_master.v"
`include "spi_if.sv"
`include "environment.sv"

module testbench;
  // 1. Generate Clock and Reset
  logic clk;
  logic rst_n;
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end
  
  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  // 2. Instantiate Interface
  spi_if intf(clk, rst_n);

  // 3. Instantiate RTL (DUT - Device Under Test)
  spi_master dut (
    .clk(intf.clk),
    .rst_n(intf.rst_n),
    .data_in(intf.data_in),
    .start(intf.start),
    .mosi(intf.mosi),
    .sclk(intf.sclk),
    .busy(intf.busy)
  );

 // 4. Run the Test
  environment env;
  
  initial begin
    env = new(intf);
    env.gen.repeat_count = 5; // Send 5 random bytes
    
    // --- ADD THIS DELAY ---
    #50; 
    
    env.test();
    
    // --- INCREASE THIS FINISH TIME ---
    #5000; 
    $finish;
  end
  
endmodule