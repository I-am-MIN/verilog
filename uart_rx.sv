/******************************************************************************
    File name        : uart_rx.sv                                                                                                    
                                                                             
    Written by       : Min Yoo (isp4289@naver.com)                             
    
    Description      :                                                          
                                                                             
 ******************************************************************************/



module uart_rx #(
    parameter DATA_WIDTH    = 8
)(
    input   logic                       clk,
    
    input   logic                       i_rx_en,
    input   logic                       i_rx_serial,
    
    input   logic                       i_cfg_parity,
    input   logic [1:0]                 i_cfg_bits,
    input   logic [1:0]                 i_cfg_baud,
    
    output  logic [DATA_WIDTH-1:0]      o_rx_data,
    output  logic                       o_rx_busy,
    output  logic                       o_rx_done,
            
    input   logic                       rst_n                
);

//------------------------------------------------------------------------------
// Parameters, Wires
//                                                                              
                                                                              
    enum {IDLE, START, DATA, PARITY, STOP} state;
    
    logic [15:0]                    baud_cnt;
    logic [15:0]                    baud_cnt_lmt;
    
    logic [2:0]                     bit_cnt;
    logic [2:0]                     bit_lmt;
    
    logic [7:0]                     rx_data_reg;
    logic                           rx_parity_err;

//------------------------------------------------------------------------------
// Combinational logic
//

    // configure baud rate
    always_comb begin
        baud_cnt_lmt        = '0;
        case (i_cfg_baud)
            2'b00: baud_cnt_lmt     = 14'd867;      // Baud Rate: 115200
            2'b01: baud_cnt_lmt     = 14'd5207;     // Baud Rate: 19200
            2'b10: baud_cnt_lmt     = 14'd10415;    // Baud Rate: 9600
        endcase
    end
    
    // configure # of bit
    always_comb begin
        case (i_cfg_bits)
            2'b00: bit_lmt          = 3'd4;
            2'b01: bit_lmt          = 3'd5;
            2'b10: bit_lmt          = 3'd6;
            2'b11: bit_lmt          = 3'd7;
        endcase
    end
    assign o_rx_busy    = ~(state == IDLE);
    

//------------------------------------------------------------------------------
// Sequential logic, Synchronous
//


    always_ff @ (posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            state           <= IDLE;
            baud_cnt        <= '0;
            bit_cnt         <= '0;  
            o_rx_data         <= '0;
            rx_data_reg     <= '0;
            rx_parity_err   <= 1'b0; 
            o_rx_done       <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    rx_parity_err       <= 1'b0;
                    o_rx_done           <= 1'b0;
                    if (~o_rx_busy && i_rx_en && ~i_rx_serial) begin
     
                        state           <= START;
                    end
                end
                START: begin
                    if (baud_cnt == baud_cnt_lmt[13:1]) begin
                        baud_cnt        <= '0;
                        if (~i_rx_serial) state           <= DATA;
                    end else begin
                        baud_cnt        <= baud_cnt + 1'b1;
                    end
                end
                DATA: begin
                    if (baud_cnt == baud_cnt_lmt) begin
                        baud_cnt        <= '0;
                        rx_data_reg[bit_cnt] <= i_rx_serial;
                        rx_parity_err   <= rx_parity_err ^ i_rx_serial;
                        if (bit_cnt == bit_lmt) begin
                            bit_cnt         <= '0;
                            state           <= (i_cfg_parity) ? PARITY : STOP;
                        end else begin
                            bit_cnt         <= bit_cnt +1'b1;
                        end                      
                    end else begin
                        baud_cnt        <= baud_cnt + 1'b1;
                    end
                end
                PARITY: begin
                    if (baud_cnt == baud_cnt_lmt) begin
                        baud_cnt        <= '0;
                        state           <= STOP;
                        rx_parity_err   <= rx_parity_err ^ i_rx_serial;
                    end else begin
                        baud_cnt        <= baud_cnt + 1'b1;
                    end
                end
                STOP: begin
                    if (baud_cnt == baud_cnt_lmt + baud_cnt_lmt[13:1]) begin
                        baud_cnt        <= '0;
                        state           <= IDLE;
                        o_rx_data       <= rx_data_reg;
                        o_rx_done       <= 1'b1;
                    end else begin
                        baud_cnt        <= baud_cnt + 1'b1;
                    end
                end
            endcase
        end
    end


//------------------------------------------------------------------------------
// Instantiations
//




endmodule