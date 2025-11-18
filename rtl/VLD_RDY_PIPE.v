module VLD_RDY_PIPE(
                    clk,
                    rst_n,
                    in_data_vld,
                    in_data_rdy,
                    in_data,
                    out_data_vld,
                    out_data_rdy,
                    out_data);

parameter DATA_WIDTH = 16*8 + 2;

input              clk           ;
input              rst_n         ;

input                   in_data_vld;
output                  in_data_rdy;
input  [DATA_WIDTH-1:0] in_data;

output                  out_data_vld;
input                   out_data_rdy;
output [DATA_WIDTH-1:0] out_data;

reg                   out_data_vld;
reg  [DATA_WIDTH-1:0] out_data;

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        out_data_vld <=  1'b0;
    else if(in_data_vld)
        out_data_vld <=  1'b1;
    else if(out_data_rdy)
        out_data_vld <=  1'b0;
end

assign in_data_rdy = ~out_data_vld | out_data_rdy;

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        out_data <=  'b0;
    else if(in_data_vld & in_data_rdy)
        out_data <=  in_data;
end

endmodule
         
       


