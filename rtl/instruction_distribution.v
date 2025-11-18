module instruction_distribution(

input                   clk             ,
input                   rst_n           ,

input   [63:0]          mem_ctrl_ins    ,//Interface with the master controller
input                   mem_ctrl_ins_vld,
output                  mem_ctrl_ins_rdy,

output  [63:0]          buf00_ins       ,//Interface with data buffer units 0-11.
output                  buf00_ins_vld   ,
input                   buf00_ins_rdy   ,

output  [63:0]          buf01_ins       ,
output                  buf01_ins_vld   ,
input                   buf01_ins_rdy   ,

output  [63:0]          buf02_ins       ,
output                  buf02_ins_vld   ,
input                   buf02_ins_rdy   ,

output  [63:0]          buf03_ins       ,
output                  buf03_ins_vld   ,
input                   buf03_ins_rdy   ,

output  [63:0]          buf04_ins       ,
output                  buf04_ins_vld   ,
input                   buf04_ins_rdy   ,

output  [63:0]          buf05_ins       ,
output                  buf05_ins_vld   ,
input                   buf05_ins_rdy   ,

output  [63:0]          buf06_ins       ,
output                  buf06_ins_vld   ,
input                   buf06_ins_rdy   ,

output  [63:0]          buf07_ins       ,
output                  buf07_ins_vld   ,
input                   buf07_ins_rdy   ,

output  [63:0]          buf08_ins       ,
output                  buf08_ins_vld   ,
input                   buf08_ins_rdy   ,

output  [63:0]          buf09_ins       ,
output                  buf09_ins_vld   ,
input                   buf09_ins_rdy   

);

/***************** wire ******************/ 
//top port
wire        buf_ins_vld;
wire        buf_ins_rdy;
//fifo output port
wire [63:0] buf_ins_fifo    ;
wire        buf_ins_fifo_vld;
reg         buf_ins_fifo_rdy;

//top vld_rdy to buf_fifo  
assign mem_ctrl_ins_rdy = buf_ins_rdy ;
assign buf_ins_vld      = mem_ctrl_ins_vld;

//FIFO for instruction buffer
vld_rdy_fifo#(
    .FIFO_WIDTH (64), 
    .FIFO_DEPTH (8)
)
buffer_ins_fifo
(
    .clk        (clk              ),
    .rst_n      (rst_n            ),
                                  
    .fifo_i_data(mem_ctrl_ins),
    .fifo_i_vld (buf_ins_vld ),
    .fifo_i_rdy (buf_ins_rdy ),
    
    .fifo_o_data(buf_ins_fifo    ),
    .fifo_o_vld (buf_ins_fifo_vld),
    .fifo_o_rdy (buf_ins_fifo_rdy)
);

wire   [3:0] to_buff_id;
assign to_buff_id      = buf_ins_fifo[60:57];
      
//Instructions sent to data buffer 0-11 modules
assign buf00_ins_vld = (to_buff_id == 4'b0000) ? buf_ins_fifo_vld : 1'b0;
assign buf01_ins_vld = (to_buff_id == 4'b0001) ? buf_ins_fifo_vld : 1'b0;
assign buf02_ins_vld = (to_buff_id == 4'b0010) ? buf_ins_fifo_vld : 1'b0;
assign buf03_ins_vld = (to_buff_id == 4'b0011) ? buf_ins_fifo_vld : 1'b0;
assign buf04_ins_vld = (to_buff_id == 4'b0100) ? buf_ins_fifo_vld : 1'b0;
assign buf05_ins_vld = (to_buff_id == 4'b0101) ? buf_ins_fifo_vld : 1'b0;
assign buf06_ins_vld = (to_buff_id == 4'b0110) ? buf_ins_fifo_vld : 1'b0;
assign buf07_ins_vld = (to_buff_id == 4'b0111) ? buf_ins_fifo_vld : 1'b0;
assign buf08_ins_vld = (to_buff_id == 4'b1000) ? buf_ins_fifo_vld : 1'b0;
assign buf09_ins_vld = (to_buff_id == 4'b1001) ? buf_ins_fifo_vld : 1'b0;
                          
always@(*)
begin
    case(to_buff_id)
        4'b0000:buf_ins_fifo_rdy = buf00_ins_rdy;
        4'b0001:buf_ins_fifo_rdy = buf01_ins_rdy;
        4'b0010:buf_ins_fifo_rdy = buf02_ins_rdy;
        4'b0011:buf_ins_fifo_rdy = buf03_ins_rdy;
        4'b0100:buf_ins_fifo_rdy = buf04_ins_rdy;
        4'b0101:buf_ins_fifo_rdy = buf05_ins_rdy;
        4'b0110:buf_ins_fifo_rdy = buf06_ins_rdy;
        4'b0111:buf_ins_fifo_rdy = buf07_ins_rdy;
        4'b1000:buf_ins_fifo_rdy = buf08_ins_rdy;
        4'b1001:buf_ins_fifo_rdy = buf09_ins_rdy;
        default:buf_ins_fifo_rdy = 1'd0;
    endcase
end                          
                           
assign buf00_ins = (to_buff_id == 4'b0000) ? buf_ins_fifo : 64'd0;
assign buf01_ins = (to_buff_id == 4'b0001) ? buf_ins_fifo : 64'd0;
assign buf02_ins = (to_buff_id == 4'b0010) ? buf_ins_fifo : 64'd0;
assign buf03_ins = (to_buff_id == 4'b0011) ? buf_ins_fifo : 64'd0;
assign buf04_ins = (to_buff_id == 4'b0100) ? buf_ins_fifo : 64'd0;
assign buf05_ins = (to_buff_id == 4'b0101) ? buf_ins_fifo : 64'd0;
assign buf06_ins = (to_buff_id == 4'b0110) ? buf_ins_fifo : 64'd0;
assign buf07_ins = (to_buff_id == 4'b0111) ? buf_ins_fifo : 64'd0;
assign buf08_ins = (to_buff_id == 4'b1000) ? buf_ins_fifo : 64'd0;
assign buf09_ins = (to_buff_id == 4'b1001) ? buf_ins_fifo : 64'd0;

endmodule



