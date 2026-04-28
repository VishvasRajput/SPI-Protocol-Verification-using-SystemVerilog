interface spi_if(input logic clk, input logic rst_n);
    // Signals matching the RTL ports
    logic [7:0] data_in;
    logic       start;
    logic       mosi;
    logic       sclk;
    logic       busy;

    // Clocking block for the Driver (Synchronous Drive)
    clocking drv_cb @(posedge clk);
        default input #1ns output #1ns;
        output data_in;
        output start;
        input  busy;
    endclocking

    // Clocking block for the Monitor (Synchronous Sample)
    clocking mon_cb @(posedge clk);
        default input #1ns output #1ns;
        input data_in;
        input start;
        input mosi;
        input sclk;
        input busy;
    endclocking

    // Modports define the direction of signals for different components
    modport DRV (clocking drv_cb, input clk, rst_n);
    modport MON (clocking mon_cb, input clk, rst_n);

endinterface
