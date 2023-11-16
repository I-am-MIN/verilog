/******************************************************************************
    File name        : uart_tx.sv                                                                                                    
                                                                             
    Written by       : Min Yoo (isp4289@naver.com)                             
    
    Description      :                                                          
                                                                             
 ******************************************************************************/



module uart_tx #(
    parameter DATA_WIDTH    = 8
)(
    input   logic                       clk,
    
    input   logic                       i_tx_en,
    input   logic [DATA_WIDTH-1:0]      i_tx_data,
    
    input   logic                       i_cfg_parity,
    input   logic [1:0]                 i_cfg_bits,
    input   logic [1:0]                 i_cfg_baud,
    
    output  logic                       o_tx_serial,
    output  logic                       o_tx_busy,
    output  logic                       o_tx_done,
            
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
    
    logic [7:0]                     tx_data_reg;
    logic                           tx_parity_reg;

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
    
    // tx_serial output
    always_comb begin
        o_tx_serial = 1'b1;
        case (state)
            IDLE:   o_tx_serial = 1'b1;
            START:  o_tx_serial = 1'b0;
            DATA:   o_tx_serial = tx_data_reg[bit_cnt];
            PARITY: o_tx_serial = tx_parity_reg;
            STOP:   o_tx_serial = 1'b1;
        endcase
    end
    assign o_tx_busy    = ~(state == IDLE);

//------------------------------------------------------------------------------
// Sequential logic, Synchronous
//

    always_ff @ (posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            state           <= IDLE;
            baud_cnt        <= '0;
            bit_cnt         <= '0;  
            tx_data_reg     <= '0;
            tx_parity_reg   <= 0; 
            o_tx_done       <= 1'b0; 
        end else begin
            case (state)
                IDLE: begin
                    o_tx_done       <= 1'b0;
                    if (~o_tx_busy && i_tx_en) begin
                        tx_data_reg     <= i_tx_data;
                        tx_parity_reg   <= 1'b0;
                        state           <= START;                        
                    end
                end
                START: begin
                    if (baud_cnt == baud_cnt_lmt) begin
                        baud_cnt        <= '0;
                        state           <= DATA;                        
                    end else begin
                        baud_cnt        <= baud_cnt + 1'b1;
                    end
                end
                DATA: begin
                    if (baud_cnt == baud_cnt_lmt) begin
                        baud_cnt        <= '0;
                        tx_parity_reg   <= tx_parity_reg ^ tx_data_reg[bit_cnt];
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
                    end else begin
                        baud_cnt        <= baud_cnt + 1'b1;
                    end
                end
                STOP: begin
                    if (baud_cnt == baud_cnt_lmt) begin
                        baud_cnt        <= '0;
                        state           <= IDLE;
                        o_tx_done       <= 1'b1;                        
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