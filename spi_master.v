
module spi_master (
    input  wire       clk,      // System Clock
    input  wire       rst_n,    // Active Low Reset
    input  wire [7:0] data_in,  // Byte to send
    input  wire       start,    // Trigger signal
    output reg        mosi,     // Master Out Slave In
    output reg        sclk,     // SPI Clock
    output reg        busy      // High during transfer
);

    // FSM States
    localparam IDLE     = 2'b00;
    localparam TRANSFER = 2'b01;
    localparam DONE     = 2'b10;

    reg [1:0] state;
    reg [7:0] shift_reg;
    reg [2:0] bit_count; // Tracks 0-7 bits
    reg       sclk_en;   // Enables the SPI clock output

    // --- 1. SPI Clock Generation ---
    // For simplicity, SCLK = System Clock / 2
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            sclk <= 1'b0;
        else if (sclk_en)
            sclk <= ~sclk;
        else
            sclk <= 1'b0;
    end

    // --- 2. Main FSM Logic ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            mosi      <= 1'b0;
            busy      <= 1'b0;
            bit_count <= 3'b0;
            sclk_en   <= 1'b0;
            shift_reg <= 8'b0;
        end else begin
            case (state)
                IDLE: begin
                    busy    <= 1'b0;
                    sclk_en <= 1'b0;
                    if (start) begin
                        shift_reg <= data_in; // Load data
                        state     <= TRANSFER;
                        busy      <= 1'b1;
                        bit_count <= 3'b0;
                    end
                end

                TRANSFER: begin
                    sclk_en <= 1'b1;
                    busy    <= 1'b1;
                    
                    // We change MOSI on the falling edge of SCLK
                    // So that the Slave can sample it on the rising edge
                    if (sclk == 1'b0) begin 
                        mosi <= shift_reg[7]; // Send MSB first
                    end else begin
                        // On SCLK rising edge, prepare next bit
                        shift_reg <= {shift_reg[6:0], 1'b0};
                        if (bit_count == 3'd7) begin
                            state <= DONE;
                        end else begin
                            bit_count <= bit_count + 1'b1;
                        end
                    end
                end

                DONE: begin
                    // One cycle to clean up
                    sclk_en <= 1'b0;
                    mosi    <= 1'b0;
                    state   <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule