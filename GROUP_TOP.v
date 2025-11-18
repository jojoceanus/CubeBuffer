module GROUP_TOP(
                 clk            ,
                 rst_n          ,

                 DW             ,
                    
                 group_cmd_vld  ,
                 group_cmd_rdy  ,
                 group_hit_flag ,
                 rw_flag        ,
                 bank_id        ,
                 bank_num       ,
                 access_num     ,
                 bit_select     ,
                 sram_addr      ,
                 padding_h      ,
                 group_in_data  ,

                 group_out_vld  ,
                 group_out_rdy  ,
                 group_out_true_data_flag  ,
                 group_out_data );

parameter  DEPTH   = 3072;
parameter  A_WIDTH = 12  ;
parameter  D_WIDTH = 16  ;
parameter  BANK_NUM= 17  ;

input                      clk       ;
input                      rst_n     ;

input     [1:0]            DW        ;

input                               group_cmd_vld  ;
output                              group_cmd_rdy  ;
input                               group_hit_flag ;
input                               rw_flag        ;
input     [4:0]                     bank_id        ;
input     [4:0]                     bank_num       ;
input     [6:0]                     access_num     ;
input     [1:0]                     bit_select     ;
input     [A_WIDTH-1:0]             sram_addr      ;
input     [5:0]                     padding_h      ;
input     [D_WIDTH*BANK_NUM-1:0]    group_in_data  ;

output                              group_out_vld  ;
input                               group_out_rdy  ;
output                              group_out_true_data_flag ;
output    [D_WIDTH*BANK_NUM-1:0]    group_out_data ;

wire    [4:0]                     bank_id           ;
wire    [4:0]                     bank_num          ;
wire    [6:0]                     access_num        ;
wire    [1:0]                     bit_select        ;
wire    [A_WIDTH-1:0]             sram_addr         ;
wire    [D_WIDTH*BANK_NUM-1:0]    group_in_data     ;
wire    [BANK_NUM-1:0]            dec_bank_hit_flag ; //0 for not hit, do not access sram but generate false output to sync with other banks
wire    [BANK_NUM*A_WIDTH-1:0]    dec_addr          ;
wire    [BANK_NUM*D_WIDTH-1:0]    dec_data          ;
wire    [4:0]                     dec_bank_id       ;
wire    [4:0]                     dec_bank_num      ;
wire    [6:0]                     dec_access_num    ;
wire    [5:0]                     dec_padding_h     ;
wire    [1:0]                     dec_bit_select    ;

//dc_debug

wire                              dec_vld;                                          
wire                              dec_rdy;
wire                              dec_rw_flag;
wire                              pipe_vld;
wire                              pipe_rdy;


GROUP_INS_DECODER#(.A_WIDTH(A_WIDTH),.D_WIDTH(D_WIDTH),.BANK_NUM(BANK_NUM))
u_group_ins_dec(.clk           (clk          ),                           
                .rst_n         (rst_n        ),                           
                           
							   
                .group_cmd_vld  (group_cmd_vld  ),                              
                .group_cmd_rdy  (group_cmd_rdy  ),                              
                .group_hit_flag (group_hit_flag ),                              
                .rw_flag        (rw_flag        ),                              
                .bank_id        (bank_id        ),                              
                .bank_num       (bank_num       ), 
                .access_num     (access_num     ),				
                .bit_select     (bit_select     ),                           
                .sram_addr      (sram_addr      ),  
                .padding_h      (padding_h      ),                                                         
                .group_in_data  (group_in_data  ),                              
							   
                .dec_vld       (dec_vld      ),                        
                .dec_rdy       (dec_rdy      ),                        
                .dec_hit_flag  (dec_bank_hit_flag ),                             
                .dec_addr      (dec_addr     ),                         
                .dec_data      (dec_data     ),                         
                .dec_bit_select(dec_bit_select   ),                              
                .dec_rw_flag   (dec_rw_flag  ), //0 for read,1 for write
                .dec_bank_id   (dec_bank_id  ),                                  
                .dec_bank_num  (dec_bank_num ),
                .dec_padding_h (dec_padding_h),
                .dec_access_num(dec_access_num));


wire  [4:0]     pipe_bank_id;
wire  [4:0]     pipe_bank_num;
wire  [1:0]     pipe_bit_select;
wire  [6:0]     pipe_access_num;
wire  [5:0]     pipe_padding_h;

VLD_RDY_PIPE_LINE #(.D_WIDTH(25),.PIPE_NUM(4))
u_vld_rdy_pipe_line(.clk         (clk               ),             
                    .rst_n       (rst_n             ),               
                    .in_data_vld (dec_vld           ),                     
                    .in_data_rdy (dec_rdy           ),                     
                    .in_data     ({dec_bank_id,dec_bank_num,dec_access_num,dec_padding_h,dec_bit_select}),                 
                    .out_data_vld(pipe_vld           ),                      
                    .out_data_rdy(pipe_rdy           ),                      
                    .out_data    ({pipe_bank_id,pipe_bank_num,pipe_access_num,pipe_padding_h,pipe_bit_select}));

wire   [BANK_NUM-1:0]           bank_array_in_vld;
wire   [BANK_NUM-1:0]           bank_array_out_rdy;
wire   [BANK_NUM-1:0]           bank_array_true_data_flag;
wire   [BANK_NUM*D_WIDTH-1:0]   bank_array_out_data;

assign bank_array_in_vld  = {BANK_NUM{dec_vld & dec_rdy}};
assign bank_array_out_rdy = {BANK_NUM{pipe_vld & pipe_rdy}};

BANK_ARRAY #(.DEPTH(DEPTH),.A_WIDTH(A_WIDTH),.D_WIDTH(D_WIDTH),.BANK_NUM(BANK_NUM))
u_bank_array(.clk      (clk                 ),
             .rst_n    (rst_n               ),

                        
             .cmd_vld  (bank_array_in_vld   ),
             .cmd_rdy  (                    ),
             .hit_flag (dec_bank_hit_flag        ),
             .rw_flag  (dec_rw_flag         ),
             .in_addr  (dec_addr            ),
             .in_data  (dec_data            ),
                        
             .out_vld  (                    ),
             .out_rdy  (bank_array_out_rdy  ),
             .true_data_flag(bank_array_true_data_flag),
             .out_data (bank_array_out_data ));


GROUP_DATA_REARRANGE #(.D_WIDTH(D_WIDTH),.BANK_NUM(BANK_NUM))
u_group_data_rearrange(
                       .clk               (clk                      ),
                       .rst_n             (rst_n                    ),

                       .DW                (DW                       ),
                                           
                       .in_vld            (pipe_vld                 ),
                       .in_rdy            (pipe_rdy                 ),
                       .bank_id           (pipe_bank_id             ),
                       .access_num        (pipe_access_num          ),
                       .bit_select        (pipe_bit_select          ),
                       .in_data           (bank_array_out_data      ),
                       .padding_h         (pipe_padding_h           ),
                       .in_true_data_flag (bank_array_true_data_flag),
                                       
                       .out_vld           (group_out_vld            ),
                       .out_rdy           (group_out_rdy            ),
                       .out_true_data_flag(group_out_true_data_flag ),
                       .out_data          (group_out_data           ));



endmodule

