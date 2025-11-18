module VLD_RDY_PIPE_LINE(
                    clk,
                    rst_n,
                    in_data_vld,
                    in_data_rdy,
                    in_data,
                    out_data_vld,
                    out_data_rdy,
                    out_data);

parameter D_WIDTH  = 16*8 ;
parameter PIPE_NUM = 3    ;

input                clk           ;
input                rst_n         ;

input                in_data_vld;
output               in_data_rdy;
input  [D_WIDTH-1:0] in_data;

output               out_data_vld;
input                out_data_rdy;
output [D_WIDTH-1:0] out_data;

wire [PIPE_NUM:0]    pipe_data_vld;
wire [PIPE_NUM:0]    pipe_data_rdy;
wire [(PIPE_NUM+1)*D_WIDTH-1:0] pipe_data;

assign pipe_data_vld[0]        = in_data_vld;
assign in_data_rdy             = pipe_data_rdy[0];
assign pipe_data_rdy[PIPE_NUM] = out_data_rdy;
assign out_data_vld            = pipe_data_vld[PIPE_NUM];
assign pipe_data[D_WIDTH-1:0]  = in_data;
assign out_data                = pipe_data[(PIPE_NUM+1)*D_WIDTH-1:PIPE_NUM*D_WIDTH];

genvar k;
generate 
    for(k=0;k<PIPE_NUM;k=k+1)
    begin:genblk0
        VLD_RDY_PIPE #(.DATA_WIDTH(D_WIDTH))
        u_pipe(
                    .clk         (clk                             ),             
                    .rst_n       (rst_n                           ),               
                    .in_data_vld (pipe_data_vld[k]                ),                     
                    .in_data_rdy (pipe_data_rdy[k]                ),                     
                    .in_data     (pipe_data[(k+1)*D_WIDTH-1:k*D_WIDTH]),                 
                    .out_data_vld(pipe_data_vld[k+1]              ),                      
                    .out_data_rdy(pipe_data_rdy[k+1]              ),                      
                    .out_data    (pipe_data[(k+2)*D_WIDTH-1:(k+1)*D_WIDTH]));

    end
endgenerate

endmodule
         


