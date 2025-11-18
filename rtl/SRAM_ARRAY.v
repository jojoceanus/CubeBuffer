module SRAM_ARRAY(
        clk                          ,
        rst_n                        ,
        DW                           ,
        ins_dec_rw_data_start        ,                    
        sram_array_in_vld            ,
        sram_array_in_rdy            ,
        sram_array_in_rw_flag        ,  //0 for read, 1 for write
        sram_array_in_group_id       ,
        sram_array_in_group_num      ,
        sram_array_in_bank_id        ,
        sram_array_in_bank_num       ,
        sram_array_in_access_num     ,
        sram_array_in_bit_select     ,
        sram_array_in_sram_addr      ,
        sram_array_in_block_offset   ,
        sram_array_in_padding_h      ,
        sram_array_in_padding_c      ,
        sram_array_in_last_flag      ,
        sram_array_in_data           ,

        sram_array_out_vld           ,
        sram_array_out_rdy           ,
        sram_array_out_data          ,
        sram_array_write_data_done   ,
        sram_array_read_data_done    ,
        sram_array_out_last_flag     );

parameter  DEPTH    = 3072;
parameter  A_WIDTH  = 12  ;
parameter  D_WIDTH  = 16  ;
parameter  BANK_NUM = 17  ;
parameter  GROUP_NUM= 10   ;

input                                         clk       ;
input                                         rst_n     ;
input     [1:0]                               DW        ;
input                                         ins_dec_rw_data_start        ;
input                                         sram_array_in_rw_flag        ;
input                                         sram_array_in_last_flag      ;
input     [3:0]                               sram_array_in_group_id       ;
input     [3:0]                               sram_array_in_group_num      ;
input     [4:0]                               sram_array_in_bank_id        ;
input     [4:0]                               sram_array_in_bank_num       ;
input     [6:0]                               sram_array_in_access_num     ;
input     [1:0]                               sram_array_in_bit_select     ;
input     [A_WIDTH-1:0]                       sram_array_in_sram_addr      ;
input     [A_WIDTH-1:0]                       sram_array_in_block_offset   ;
input     [5:0]                               sram_array_in_padding_h      ;
input     [5:0]                               sram_array_in_padding_c      ;
input     [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    sram_array_in_data           ;   
input                                         sram_array_in_vld            ;
output                                        sram_array_in_rdy            ;

output                                        sram_array_out_vld           ;       
input                                         sram_array_out_rdy           ; 
output    [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    sram_array_out_data          ;      
output reg                                    sram_array_write_data_done   ;
output reg                                    sram_array_read_data_done    ;
output                                        sram_array_out_last_flag     ;

wire                                          dec_vld           ;
wire                                          dec_rdy           ;
wire      [GROUP_NUM-1:0]                     dec_group_hit_flag;
wire      [3:0]                               dec_group_id      ;
wire      [3:0]                               dec_group_num     ;
wire      [4:0]                               dec_bank_id       ;
wire      [4:0]                               dec_bank_num      ;
wire      [6:0]                               dec_access_num    ;
wire      [1:0]                               dec_bit_select    ;
wire      [5:0]                               dec_padding_h     ;
wire      [5:0]                               dec_padding_c     ;
wire      [A_WIDTH*GROUP_NUM-1:0]             dec_group_addr    ;
wire      [A_WIDTH-1:0]                       dec_block_offset  ;
wire      [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    dec_data          ;


wire                                         sram_array_in_vld_fifo_o            ;
wire                                         sram_array_in_rdy_fifo_o            ;
wire      [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]   sram_array_in_data_fifo_o           ;
wire                                         sram_array_in_rw_flag_fifo_o        ;
wire                                         sram_array_in_last_flag_fifo_o      ;
wire     [3:0]                               sram_array_in_group_id_fifo_o       ;
wire     [3:0]                               sram_array_in_group_num_fifo_o      ;
wire     [4:0]                               sram_array_in_bank_id_fifo_o        ;
wire     [4:0]                               sram_array_in_bank_num_fifo_o       ;
wire     [1:0]                               sram_array_in_bit_select_fifo_o     ;
wire     [A_WIDTH-1:0]                       sram_array_in_sram_addr_fifo_o      ;
wire     [A_WIDTH-1:0]                       sram_array_in_block_offset_fifo_o   ;
wire     [6:0]                               sram_array_in_access_num_fifo_o     ;
wire     [5:0]                               sram_array_in_padding_h_fifo_o      ; 
wire     [5:0]                               sram_array_in_padding_c_fifo_o      ;

FIFO_REG_OUT#(
    // .FIFO_WIDTH(2785),
    .FIFO_WIDTH(65+GROUP_NUM*D_WIDTH*BANK_NUM), // by gyp
    .FIFO_DEPTH(2)
    )
u_fifo_reg_out_1(
    .clk(clk),
    .rst_n(rst_n),
    .fifo_i_vld(sram_array_in_vld),
    .fifo_i_rdy(sram_array_in_rdy),
    .fifo_i_data({sram_array_in_rw_flag,
                  sram_array_in_group_id,
                  sram_array_in_group_num,
                  sram_array_in_bank_id,
                  sram_array_in_bank_num,
                  sram_array_in_bit_select,
                  sram_array_in_sram_addr,
                  sram_array_in_block_offset,
                  sram_array_in_padding_h,
                  sram_array_in_padding_c,
                  sram_array_in_last_flag,
                  sram_array_in_data,
                  sram_array_in_access_num}),
    .fifo_o_vld(sram_array_in_vld_fifo_o),
    .fifo_o_rdy(sram_array_in_rdy_fifo_o),
    .fifo_o_data({sram_array_in_rw_flag_fifo_o,
                  sram_array_in_group_id_fifo_o,
                  sram_array_in_group_num_fifo_o,
                  sram_array_in_bank_id_fifo_o,
                  sram_array_in_bank_num_fifo_o,
                  sram_array_in_bit_select_fifo_o,
                  sram_array_in_sram_addr_fifo_o,
                  sram_array_in_block_offset_fifo_o,
                  sram_array_in_padding_h_fifo_o,
                  sram_array_in_padding_c_fifo_o,
                  sram_array_in_last_flag_fifo_o,
                  sram_array_in_data_fifo_o,
                  sram_array_in_access_num_fifo_o})
);

wire dec_rw_flag;
wire dec_last_flag;
PHY_ADDR_INS_DECODER#(.A_WIDTH(A_WIDTH),.D_WIDTH(D_WIDTH),.BANK_NUM(BANK_NUM),.GROUP_NUM(GROUP_NUM))
u_phy_addr_ins_dec(.clk                           (clk                          ),                           
                   .rst_n                         (rst_n                        ),                           

                   .sram_array_in_vld             (sram_array_in_vld_fifo_o            ),                              
                   .sram_array_in_rdy             (sram_array_in_rdy_fifo_o            ),                              
                   .sram_array_in_rw_flag         (sram_array_in_rw_flag_fifo_o        ),                              
                   .sram_array_in_group_id        (sram_array_in_group_id_fifo_o       ),                              
                   .sram_array_in_group_num       (sram_array_in_group_num_fifo_o      ),                              
                   .sram_array_in_bank_id         (sram_array_in_bank_id_fifo_o        ),                              
                   .sram_array_in_bank_num        (sram_array_in_bank_num_fifo_o       ),
                   .sram_array_in_access_num      (sram_array_in_access_num_fifo_o     ),               
                   .sram_array_in_bit_select      (sram_array_in_bit_select_fifo_o     ),                              
                   .sram_array_in_sram_addr       (sram_array_in_sram_addr_fifo_o      ),                              
                   .sram_array_in_block_offset    (sram_array_in_block_offset_fifo_o   ),                              
                   .sram_array_in_last_flag       (sram_array_in_last_flag_fifo_o      ),                              
                   .sram_array_in_data            (sram_array_in_data_fifo_o           ),   
                   .sram_array_in_padding_h       (sram_array_in_padding_h_fifo_o      ),   
                   .sram_array_in_padding_c       (sram_array_in_padding_c_fifo_o      ),				   

                   .dec_vld                       (dec_vld                      ),                        
                   .dec_rdy                       (dec_rdy                      ),                        
                   .dec_group_hit_flag            (dec_group_hit_flag           ),                             
                   .dec_rw_flag                   (dec_rw_flag                  ),                              
                   .dec_group_id                  (dec_group_id                 ),                              
                   .dec_group_num                 (dec_group_num                ),                              
                   .dec_bank_id                   (dec_bank_id                  ),                              
                   .dec_bank_num                  (dec_bank_num                 ),
                   .dec_access_num                (dec_access_num               ),           
                   .dec_bit_select                (dec_bit_select               ),                              
                   .dec_group_addr                (dec_group_addr               ),
                   .dec_padding_h                 (dec_padding_h                ),
                   .dec_padding_c                 (dec_padding_c                ),
                   .dec_last_flag                 (dec_last_flag                ),                              
                   .dec_data                      (dec_data                     ));          

wire            pipe_vld     ;
wire            pipe_rdy     ;
wire  [3:0]     pipe_group_id;
wire            pipe_rw_flag ;
wire            pipe_last_flag;
wire  [5:0]     pipe_padding_c;

VLD_RDY_PIPE_LINE #(.D_WIDTH(12),.PIPE_NUM(6))
u_vld_rdy_pipe_line(.clk         (clk               ),             
                    .rst_n       (rst_n             ),               
                    .in_data_vld (dec_vld           ),                     
                    .in_data_rdy (dec_rdy           ),                     
                    .in_data     ({dec_group_id,dec_padding_c,dec_rw_flag,dec_last_flag}),                 
                    .out_data_vld(pipe_vld           ),                      
                    .out_data_rdy(pipe_rdy           ),                      
                    .out_data    ({pipe_group_id,pipe_padding_c,pipe_rw_flag,pipe_last_flag}));

wire   [GROUP_NUM-1:0]           group_array_in_vld;
wire   [GROUP_NUM-1:0]           group_array_out_rdy;
wire   [GROUP_NUM-1:0]           group_array_true_data_flag;
wire   [GROUP_NUM*BANK_NUM*D_WIDTH-1:0]   group_array_out_data;

assign group_array_in_vld  = {GROUP_NUM{dec_vld & dec_rdy}};
assign group_array_out_rdy = {GROUP_NUM{pipe_vld & pipe_rdy}};

GROUP_ARRAY #(.DEPTH(DEPTH),.A_WIDTH(A_WIDTH),.D_WIDTH(D_WIDTH),.BANK_NUM(BANK_NUM),.GROUP_NUM(GROUP_NUM))
u_group_array(.clk      (clk                 ),
             .rst_n     (rst_n               ),

             .DW        (DW                  ),
                        
             .group_cmd_vld  (group_array_in_vld  ),
             .group_cmd_rdy  (                    ),
             .group_hit_flag (dec_group_hit_flag  ),
             .group_in_data  (dec_data            ),
             .rw_flag        (dec_rw_flag         ),
             .bank_id        (dec_bank_id         ),
             .bank_num       (dec_bank_num        ),
             .access_num     (dec_access_num      ),
             .bit_select     (dec_bit_select      ),
             .padding_h      (dec_padding_h       ),
             .sram_addr      (dec_group_addr      ),
                        
             .group_out_vld  (                     ),
             .group_out_rdy  (group_array_out_rdy  ),
             .group_out_true_data_flag(group_array_true_data_flag),
             .group_out_data (group_array_out_data ));

wire  pipe_vld_fifo_o;
wire  pipe_rdy_fifo_o;
wire  pipe_rw_flag_fifo_o;
wire  pipe_last_flag_fifo_o;
wire [3:0] pipe_group_id_fifo_o;
wire [5:0] pipe_padding_c_fifo_o;
wire [GROUP_NUM*D_WIDTH*BANK_NUM-1:0] group_array_out_data_fifo_o;
wire [GROUP_NUM-1:0] group_array_true_data_flag_fifo_o;
FIFO_REG_OUT#(
    .FIFO_WIDTH(12 + GROUP_NUM*D_WIDTH*BANK_NUM + GROUP_NUM),
    .FIFO_DEPTH(2)
    )
u_fifo_reg_out_2(
    .clk(clk),
    .rst_n(rst_n),
    .fifo_i_vld(pipe_vld),
    .fifo_i_rdy(pipe_rdy),
    .fifo_i_data({pipe_rw_flag,pipe_last_flag,pipe_group_id,pipe_padding_c,group_array_out_data,group_array_true_data_flag}),
    .fifo_o_vld(pipe_vld_fifo_o),
    .fifo_o_rdy(pipe_rdy_fifo_o),
    .fifo_o_data({pipe_rw_flag_fifo_o,pipe_last_flag_fifo_o,pipe_group_id_fifo_o,pipe_padding_c_fifo_o,group_array_out_data_fifo_o,group_array_true_data_flag_fifo_o})
);
SRAM_DATA_REARRANGE #(.D_WIDTH(D_WIDTH),.BANK_NUM(BANK_NUM),.GROUP_NUM(GROUP_NUM))
u_sram_data_rearrange(
                       .clk               (clk                       ),
                       .rst_n             (rst_n                     ),

                       .in_vld            (pipe_vld_fifo_o                  ),
                       .in_rdy            (pipe_rdy_fifo_o                  ),
                       .rw_flag           (pipe_rw_flag_fifo_o              ),
                       .last_flag         (pipe_last_flag_fifo_o            ),
                       .group_id          (pipe_group_id_fifo_o             ),
                       .padding_c         (pipe_padding_c_fifo_o            ),
                       .in_data           (group_array_out_data_fifo_o      ),
                       .in_true_data_flag (group_array_true_data_flag_fifo_o),
                                       
                       .out_vld           (sram_array_out_vld            ),
                       .out_rdy           (sram_array_out_rdy            ),
                       .out_last_flag     (sram_array_out_last_flag      ),
                       .out_data          (sram_array_out_data           ));

//the last data is write in the sram
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        sram_array_write_data_done <= 1'b0;
    else if(ins_dec_rw_data_start == 1'b1)
        sram_array_write_data_done <= 1'b0;
    else if(pipe_vld & pipe_rdy & pipe_rw_flag & pipe_last_flag)
        sram_array_write_data_done <= 1'b1;
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        sram_array_read_data_done <= 1'b0;
    else if(ins_dec_rw_data_start == 1'b1)
        sram_array_read_data_done <= 1'b0;
    else if(sram_array_out_vld & sram_array_out_rdy & sram_array_out_last_flag)
        sram_array_read_data_done <= 1'b1;
end

endmodule

