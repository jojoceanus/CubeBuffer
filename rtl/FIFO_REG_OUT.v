//----------------------------------------------------------------------------//
//                                                                            //
//  COPYRIGHT (C) 2020, XXX Group,  xxx  University                           //
//                                                                            //
//----------------------------------------------------------------------------//
// Filename       : FIFO_REG_OUT.v                                            //
// Author         : xxxxxxxxxxxxxxxxx                                         //
// Email          : xxxxxxxxxxxxxxxxx                                         //
// Created        : 2020-5-29 16:49:50                                        //
//----------------------------------------------------------------------------//
// Description    : synchronize fifo ;                                        //
//                                                                            //
// $Id$                                                                       //
//----------------------------------------------------------------------------//
module  FIFO_REG_OUT #(parameter FIFO_WIDTH = 10*16, FIFO_DEPTH = 8)( 
    clk, 
    rst_n,

    fifo_i_vld,
    fifo_i_rdy,
    fifo_i_data,  

    fifo_o_vld,
    fifo_o_rdy,
    fifo_o_data     
);


input  clk                           ;
input  rst_n                         ;

input  fifo_i_vld                    ;
output fifo_i_rdy                    ;
input  [FIFO_WIDTH-1:0] fifo_i_data  ;

output fifo_o_vld                    ;
input  fifo_o_rdy                    ;
output [FIFO_WIDTH-1:0] fifo_o_data  ;

wire    clk                          ; 
wire    rst_n                        ;

wire    fifo_i_vld                   ;
wire    fifo_i_rdy                   ;

reg     fifo_o_vld                   ;
wire    fifo_o_rdy                   ;

wire   [FIFO_WIDTH-1:0] fifo_i_data ;
reg    [FIFO_WIDTH-1:0] fifo_o_data ;

function integer clogb2 (input integer depth);
    integer temp_depth;
begin
    temp_depth = depth;
    for (clogb2=0; temp_depth>0; clogb2=clogb2+1)
        temp_depth = temp_depth >>1;                           
end
endfunction   

localparam PTR_WIDTH = clogb2(FIFO_DEPTH-1);
            

wire  fifo_wen;
wire  fifo_ren ;
wire  fifo_full;
wire  fifo_empty;

assign fifo_wen = fifo_i_vld & fifo_i_rdy;
assign fifo_ren = ~fifo_o_vld || fifo_o_rdy;


//pointers
//the highest bit is used for fifo_full/fifo_empty judgment
reg [PTR_WIDTH:0] fifo_wptr;    
reg [PTR_WIDTH:0] fifo_rptr;   

//wr pointer;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) fifo_wptr <= 0;
    else if(fifo_wen) begin
        if(fifo_wptr[PTR_WIDTH-1:0]==FIFO_DEPTH-1) begin
            fifo_wptr[PTR_WIDTH] <= ~fifo_wptr[PTR_WIDTH];
            fifo_wptr[PTR_WIDTH-1:0] <= 0;
        end
        else
            fifo_wptr <= fifo_wptr + 1'b1;
    end
end

//rd pointer;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) fifo_rptr <= 0;
    else if(~fifo_empty & fifo_ren) begin
        if(fifo_rptr[PTR_WIDTH-1:0]==FIFO_DEPTH-1) begin
            fifo_rptr[PTR_WIDTH] <= ~fifo_rptr[PTR_WIDTH];
            fifo_rptr[PTR_WIDTH-1:0] <= 0;
        end
        else
            fifo_rptr <= fifo_rptr + 1'b1;
    end
end

//fifo_full/fifo_empty flag
assign fifo_full = (fifo_wptr[PTR_WIDTH-1:0]== fifo_rptr[PTR_WIDTH-1:0]) && (fifo_wptr[PTR_WIDTH] ^ fifo_rptr[PTR_WIDTH] == 1);  //highest bit is not same but rests bit is same;
assign fifo_empty = (fifo_wptr[PTR_WIDTH-1:0]== fifo_rptr[PTR_WIDTH-1:0]) && (fifo_wptr[PTR_WIDTH] ^ fifo_rptr[PTR_WIDTH] == 0); //every bit is same;
 
//FIFO definition
reg [FIFO_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

//write data to fifo
always @(posedge clk) begin
    if (fifo_wen)
        fifo_mem[fifo_wptr[PTR_WIDTH-1:0]] <= fifo_i_data;
end


//fifo_i_rdy
assign fifo_i_rdy = ~fifo_full;

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        fifo_o_vld <= 1'b0;
    else if(~fifo_empty)
        fifo_o_vld <= 1'b1;
    else if(fifo_o_rdy)
        fifo_o_vld <= 1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        fifo_o_data <= {FIFO_WIDTH{1'b0}};
    else if(~fifo_empty && fifo_ren)
        fifo_o_data <= fifo_mem[fifo_rptr[PTR_WIDTH-1:0]];
end


endmodule
