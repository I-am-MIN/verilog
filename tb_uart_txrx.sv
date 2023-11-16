`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/16 15:41:39
// Design Name: 
// Module Name: tb_uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_uart_txrx;

    logic                       clk;
    logic                       rst_n;
    
    // tx
    logic                       i_tx_en;
    logic [7:0]                 i_tx_data;
    
    logic                       o_tx_busy;
    logic                       o_tx_done;
                
    //
    logic                       serial;
    
    logic                       i_cfg_parity;
    logic [1:0]                 i_cfg_bits;
    logic [1:0]                 i_cfg_baud;
    
    // rx    
    logic                       i_rx_en;
    
    logic [7:0]                 o_rx_data;
    logic                       o_rx_busy;
    logic                       o_rx_done;
            
                
    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end
    
    initial begin
        i_tx_en         = 0;
        i_tx_data       = '0;
        i_rx_en         = 0;
        i_cfg_parity    = '0;
        i_cfg_bits      = '0;
        i_cfg_baud      = '0;
        rst_n           = 0;
        #20
        rst_n           = 1;
        @(posedge clk);
        i_tx_en         = 1;
        i_rx_en         = 1;
        i_tx_data       = 8'ha6;
        i_cfg_parity    = 1;
        i_cfg_bits      = 2'b11;
        i_cfg_baud      = 2'b00;
        @(posedge o_rx_done);
        @(posedge clk);
        $finish;
    end
    
    uart_tx #() dut_uart_tx(.o_tx_serial(serial), .*);
    uart_rx #() dut_uart_rx(.i_rx_serial(serial), .*);
    
endmodule
