/******************************************************************************
    File name        : spram.sv                                            
                                                                                
    Description      :                                                         
                                                                             
    Written by       : Min Yoo (isp4289@naver.com)                                                                                      
                                                                             
 ******************************************************************************/



module spram #(
    parameter ADDR_WIDTH    = 32,
    parameter DATA_WIDTH    = 32,
    parameter DEPTH         = 64
)(
    input   logic                       clk,        
    input   logic                       reset,
    
    input   logic                       ce,
    input   logic                       we,
    
    input   logic [ADDR_WIDTH-1:0]      addr,
    
    input   logic [DATA_WIDTH-1:0]      wdata,
    output  logic [DATA_WIDTH-1:0]      rdata       
);

//------    Local variables     -------------------------------------//

    logic [DATA_WIDTH-1:0]      mem [DEPTH];
    logic [ADDR_WIDTH-1:0]      addr_r;


//------    Logic definition    ------------------------------------//

    assign rdata            = mem[addr_r];
    

//------    Functional description  --------------------------------//

    always_ff @ (posedge clk, negedge reset) begin
        if (~reset) begin
        end
        else if (ce) begin
            if (we)
                mem[addr]   <= wdata;
            addr_r      <= addr;
        end
    end


//------    Instances   --------------------------------------------//

    /* EMPTY */


endmodule