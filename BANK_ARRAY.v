module BANK_ARRAY(
                     clk       ,
                     rst_n     ,

                    
                     cmd_vld   ,
                     cmd_rdy   ,
                     hit_flag   ,
                     rw_flag   ,
                     in_addr   ,
                     in_data   ,
                    
                     out_vld  ,
                     out_rdy  ,
                     true_data_flag  ,
                     out_data       
);

parameter  DEPTH   = 3072;
parameter  A_WIDTH = 12  ;
parameter  D_WIDTH = 16  ;
parameter  BANK_NUM= 17  ;

input                      clk       ;
input                      rst_n     ;


input     [BANK_NUM-1:0]            cmd_vld;
output    [BANK_NUM-1:0]            cmd_rdy;
input     [BANK_NUM-1:0]            hit_flag; //0 for not hit, do not access sram but generate false output to sync with other banks
input                               rw_flag; //0 for read, 1 for write
input     [BANK_NUM*A_WIDTH-1:0]    in_addr;
input     [BANK_NUM*D_WIDTH-1:0]    in_data;

output    [BANK_NUM-1:0]            out_vld ;
input     [BANK_NUM-1:0]            out_rdy ;
output    [BANK_NUM-1:0]            true_data_flag ;
output    [BANK_NUM*D_WIDTH-1:0]    out_data;

genvar j;
generate 
    for(j=0;j<BANK_NUM;j=j+1)
    begin:genblk0
        SRAM_BANK #(
               .D_WIDTH(D_WIDTH  ),
               .DEPTH  (DEPTH    ),
               .A_WIDTH(A_WIDTH  ))
        u_sram_bank (
                        .clk       (clk      ),
                        .rst_n     (rst_n    ),

        
                        .cmd_vld   (cmd_vld[j]  ),
                        .cmd_rdy   (cmd_rdy[j]  ),
                        .hit_flag  (hit_flag[j] ),
                        .rw_flag   (rw_flag     ),
                        .in_addr   (in_addr[A_WIDTH*(j+1)-1:A_WIDTH*j]),
                        .in_data   (in_data[D_WIDTH*(j+1)-1:D_WIDTH*j]),
        
                        .out_vld   (out_vld[j]  ),
                        .out_rdy   (out_rdy[j]  ),
                        .true_data_flag (true_data_flag[j]),
                        .out_data  (out_data[D_WIDTH*(j+1)-1:D_WIDTH*j]));
    end
endgenerate

endmodule
