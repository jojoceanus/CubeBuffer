module vld_rdy_fifo#(
parameter FIFO_WIDTH = 8, 
parameter FIFO_DEPTH = 16
)
(
    input clk,
    input rst_n,

    input [FIFO_WIDTH-1:0] fifo_i_data,
    input fifo_i_vld,
    output fifo_i_rdy,

    output [FIFO_WIDTH-1:0] fifo_o_data,
    output fifo_o_vld,
    input fifo_o_rdy
);

localparam PTR_WIDTH=$clog2(FIFO_DEPTH);
reg [PTR_WIDTH:0] fifo_wptr;
reg [PTR_WIDTH:0] fifo_rptr;

wire fifo_wen;
wire fifo_ren;

wire fifo_full;
wire fifo_empty;

reg [FIFO_WIDTH-1:0] fifo_mem[0:FIFO_DEPTH-1];

assign fifo_wen=fifo_i_vld&fifo_i_rdy;
assign fifo_ren=fifo_o_vld&fifo_o_rdy;

always @ (posedge clk or negedge rst_n)begin
       if (~rst_n)
          fifo_wptr[PTR_WIDTH-1:0] <= 0;
       else if(fifo_wen && (fifo_wptr[PTR_WIDTH-1:0] == FIFO_DEPTH-1))
          fifo_wptr[PTR_WIDTH-1:0] <= 0;
       else if(fifo_wen)
          fifo_wptr[PTR_WIDTH-1:0] <= fifo_wptr[PTR_WIDTH-1:0] +1'b1;
end

always @ (posedge clk or negedge rst_n)begin
       if (~rst_n)
          fifo_wptr[PTR_WIDTH] <=0;
       else if(fifo_wen && (fifo_wptr[PTR_WIDTH-1:0] == FIFO_DEPTH-1))
          fifo_wptr[PTR_WIDTH] <= ~fifo_wptr[PTR_WIDTH];
end

always @(posedge clk or negedge rst_n)begin
      if(~rst_n)
        fifo_rptr[PTR_WIDTH-1:0]<=0;
      else if(fifo_ren && (fifo_rptr[PTR_WIDTH-1:0] == FIFO_DEPTH-1))
        fifo_rptr[PTR_WIDTH-1:0]<=0;
      else if(fifo_ren)
        fifo_rptr[PTR_WIDTH-1:0]<=fifo_rptr[PTR_WIDTH-1:0] + 1;
end

always @(posedge clk or negedge rst_n)begin
      if(~rst_n)
        fifo_rptr[PTR_WIDTH]<=0;
      else if(fifo_ren && (fifo_rptr[PTR_WIDTH-1:0] == FIFO_DEPTH-1))
        fifo_rptr[PTR_WIDTH]<=~fifo_rptr[PTR_WIDTH];
end

assign fifo_full=(fifo_wptr[PTR_WIDTH]^fifo_rptr[PTR_WIDTH]==1)&&(fifo_wptr[PTR_WIDTH-1:0]==fifo_rptr[PTR_WIDTH-1:0]);
assign fifo_empty=(fifo_wptr==fifo_rptr);

always @(posedge clk)begin
    if(fifo_wen)
        fifo_mem[fifo_wptr[PTR_WIDTH-1:0]]<=fifo_i_data;
end

assign fifo_o_data=fifo_mem[fifo_rptr[PTR_WIDTH-1:0]];

assign fifo_i_rdy=~fifo_full;
assign fifo_o_vld=~fifo_empty;

endmodule





