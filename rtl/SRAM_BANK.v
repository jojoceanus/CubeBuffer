module SRAM_BANK(
                     clk       ,
                     rst_n     ,

                    
                     cmd_vld   ,
                     cmd_rdy   ,
                     hit_flag  ,
                     rw_flag   ,
                     in_addr   ,
                     in_data   ,
                    
                     out_vld  ,
                     out_rdy  ,
                     true_data_flag,
                     out_data       
);

parameter  DEPTH   = 3072;
parameter  A_WIDTH = 12  ;
parameter  D_WIDTH = 16  ;

input                      clk       ;
input                      rst_n     ;


input                      cmd_vld;
output                     cmd_rdy;
input                      hit_flag; //0 for not hit, do not access sram but generate false output to sync with other banks
input                      rw_flag; //0 for read, 1 for write
input     [A_WIDTH-1:0]    in_addr;
input     [D_WIDTH-1:0]    in_data;

output                     out_vld ;
input                      out_rdy ;
output                     true_data_flag ; //1 for read data, when did not hit or write sram, generate 0 to sync with other banks 
output    [D_WIDTH-1:0]    out_data;

wire      [A_WIDTH+D_WIDTH:0] in_pipe_data;
wire      [D_WIDTH-1:0]       out_sram_data;
wire      [1:0]               pipe_data;

//dc_debug
wire                       in_data_vld;
wire                       in_data_rdy;
wire                       out_sram_vld;
wire                       out_sram_rdy;

VLD_RDY_PIPE_LINE #(.D_WIDTH(2),.PIPE_NUM(4))
u_vld_rdy_pipe_line(.clk         (clk               ),             
                    .rst_n       (rst_n             ),               
                    .in_data_vld (cmd_vld           ),                     
                    .in_data_rdy (cmd_rdy           ),                     
                    .in_data     ({hit_flag,rw_flag}),                 
                    .out_data_vld(out_vld           ),                      
                    .out_data_rdy(out_rdy           ),                      
                    .out_data    (pipe_data         ));

//hit and read
wire in_pipe_vld;
wire in_pipe_rdy;

assign true_data_flag = pipe_data[1] & (~pipe_data[0]);

VLD_RDY_PIPE #(.DATA_WIDTH(A_WIDTH+D_WIDTH+1))
u_input_reg(
            .clk         (clk  ),             
            .rst_n       (rst_n),               
            .in_data_vld (cmd_vld & cmd_rdy & hit_flag),                     
            .in_data_rdy (            ),                     
            .in_data     ({rw_flag,in_addr,in_data}),                 
            .out_data_vld(in_pipe_vld ),                      
            .out_data_rdy(in_pipe_rdy ),                      
            .out_data    (in_pipe_data));

//ram instance
VLD_RDY_SRAM #(
       .D_WIDTH(D_WIDTH  ),
       .DEPTH  (DEPTH    ),
       .A_WIDTH(A_WIDTH  ))
u_vld_rdy_sram (
                .clk       (clk      ),
                .rst_n     (rst_n    ),

                .cmd_vld   (in_pipe_vld  ),
                .cmd_rdy   (in_pipe_rdy  ),
                .rw_flag   (in_pipe_data[A_WIDTH+D_WIDTH]          ),
                .in_addr   (in_pipe_data[A_WIDTH+D_WIDTH-1:D_WIDTH]),
                .in_data   (in_pipe_data[D_WIDTH-1:0]              ),

                .out_vld   (out_sram_vld  ),
                .out_rdy   (out_sram_rdy  ),
                .out_data  (out_sram_data ));

wire    [D_WIDTH-1:0]    out_data_tmp;
VLD_RDY_PIPE #(.DATA_WIDTH(D_WIDTH))
u_output_reg(
            .clk         (clk  ),             
            .rst_n       (rst_n),               
            .in_data_vld (out_sram_vld ),                     
            .in_data_rdy (out_sram_rdy ),                     
            .in_data     (out_sram_data),                 
            .out_data_vld(        ),                      
            .out_data_rdy(out_vld & out_rdy & true_data_flag ),                      
            .out_data    (out_data_tmp));

assign out_data = true_data_flag ? out_data_tmp : {D_WIDTH{1'b0}};


endmodule
