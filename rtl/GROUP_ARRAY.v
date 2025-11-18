module GROUP_ARRAY#(
parameter  DEPTH    = 3072,
parameter  A_WIDTH  = 12  ,
parameter  D_WIDTH  = 16  ,
parameter  BANK_NUM = 17  ,
parameter  GROUP_NUM= 10   
)
(
                   clk                       ,
                   rst_n                     ,

                   DW                        ,
                  
                   group_cmd_vld             ,
                   group_cmd_rdy             ,
                   group_hit_flag            ,
                   group_in_data             ,
                   rw_flag                   ,
                   bank_id                   ,
                   bank_num                  ,
                   access_num                ,
                   bit_select                ,
                   sram_addr                 ,
                   padding_h                 ,
                  
                   group_out_vld             ,
                   group_out_rdy             ,
                   group_out_true_data_flag  ,
                   group_out_data            );


input                                         clk       ;
input                                         rst_n     ;

input     [1:0]                               DW        ;

input     [GROUP_NUM-1:0]                     group_cmd_vld  ;
output    [GROUP_NUM-1:0]                     group_cmd_rdy  ;
input     [GROUP_NUM-1:0]                     group_hit_flag ;
input                                         rw_flag        ;
input     [4:0]                               bank_id        ;
input     [4:0]                               bank_num       ;
input     [6:0]                               access_num     ;
input     [1:0]                               bit_select     ;
input     [A_WIDTH*GROUP_NUM-1:0]             sram_addr      ;
input     [5:0]                               padding_h      ;
input     [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    group_in_data  ;

output    [GROUP_NUM-1:0]                     group_out_vld ;
input     [GROUP_NUM-1:0]                     group_out_rdy ;
output    [GROUP_NUM-1:0]                     group_out_true_data_flag ;
output    [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    group_out_data;






genvar j;
generate 
    for(j=0;j<GROUP_NUM;j=j+1)
    begin:genblk0
        GROUP_TOP #(.DEPTH(DEPTH),.A_WIDTH (A_WIDTH),.D_WIDTH (D_WIDTH),.BANK_NUM(BANK_NUM))
        u_group(.clk                        (clk                        ),
                .rst_n                      (rst_n                      ),

                .DW                         (DW                         ),
                .group_cmd_vld              (group_cmd_vld[j]           ),
                .group_cmd_rdy              (group_cmd_rdy[j]           ),
                .group_hit_flag             (group_hit_flag[j]          ),
                .rw_flag                    (rw_flag                    ),
                .bank_id                    (bank_id                    ),
                .bank_num                   (bank_num                   ),
                .access_num                 (access_num                 ),
                .bit_select                 (bit_select                 ),
                .sram_addr                  (sram_addr[(j+1)*A_WIDTH-1:j*A_WIDTH]),
                .padding_h                  (padding_h                  ),
                .group_in_data              (group_in_data[(j+1)*D_WIDTH*BANK_NUM-1:j*D_WIDTH*BANK_NUM] ),
                .group_out_vld              (group_out_vld[j]           ),
                .group_out_rdy              (group_out_rdy[j]           ),
                .group_out_true_data_flag   (group_out_true_data_flag[j]),
                .group_out_data             (group_out_data[(j+1)*D_WIDTH*BANK_NUM-1:j*D_WIDTH*BANK_NUM]));
    end
endgenerate
        

endmodule
