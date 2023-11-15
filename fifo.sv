/******************************************************************************
    File name        : fifo.sv                                                                                                    
                                                                             
    Written by       : Min Yoo (isp4289@naver.com)                             
    
    Description      :                                                          
                                                                             
 ******************************************************************************/



module fifo #(
    parameter WIDTH         = 32,
    parameter DEPTH         = 64
)(
    input   logic                       clk,
    
    input   logic                       i_push,
    input   logic [WIDTH-1:0]           i_wdata,
    
    input   logic                       i_pop,
    output  logic [WIDTH-1:0]           o_rdata,
    
    output  logic                       o_full,
    output  logic                       o_empty,
            
    input   logic                       rst_n                
);

//------------------------------------------------------------------------------
// Parameters, Wires
//                                                                              

    localparam  PTR_W   = &clog2(DEPTH);

    logic [WIDTH-1:0]               mem [DEPTH];
    
    logic [PTR_W:0]                 wptr, rptr;

//------------------------------------------------------------------------------
// Combinational logic
//

    // empty, full state description
    always_comb begin
        o_empty     = 0;
        o_full      = 0;
        if (wptr == rptr) begin
            o_empty     = 1;
            if (wptr[PTR_W] != rptr[PTR_W]) o_full = 1;
        end 
    end

    assign o_rdata      = mem[rptr[PTR_W-1:0]];

//------------------------------------------------------------------------------
// Sequential logic, Synchronous
//

    // push operation
    always_ff @ (posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            for (int i = 0; i < DEPTH; i++)
                mem[i]                  <= '0;
            wptr                    <= '0;
        end else begin
            if (~o_full && i_push) begin
                mem[wptr[PTR_W-1:0]]    <= i_wdata;
                wptr                    <= wptr + 1'b1;
            end
        end
    end
    
    always_ff @ (posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            rptr                    <= '0;
        end else begin
            if (~o_empty && i_pop) begin
                rptr                    <= rptr + 1'b1;
            end
        end
    end


//------------------------------------------------------------------------------
// Instantiations
//




endmodule