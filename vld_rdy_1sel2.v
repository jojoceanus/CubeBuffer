module vld_rdy_1sel2#(
parameter  D_WIDTH      = 16  ,
parameter  BANK_NUM     = 17  ,
parameter  GROUP_NUM    = 10   
)(
        data_destination_flag          ,
        sram_array_out_vld             ,      
        sram_array_out_rdy             ,
        sram_array_out_data            ,
        sram_array_out_last_flag       ,
        sram_array2router_out_vld      ,
        sram_array2router_out_rdy      ,
        sram_array2router_out_data     ,
        sram_array2router_out_last_flag,                                    
        sram_array2ddr_out_vld         ,
        sram_array2ddr_out_rdy         ,
        sram_array2ddr_out_data        );

input                                       data_destination_flag          ;
input                                       sram_array_out_vld             ;  
output                                      sram_array_out_rdy             ; 
input   [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    sram_array_out_data            ;
input                                       sram_array_out_last_flag       ;
 
output                                      sram_array2router_out_vld      ;
input                                       sram_array2router_out_rdy      ;  
output  [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    sram_array2router_out_data     ; 
output                                      sram_array2router_out_last_flag;

output                                      sram_array2ddr_out_vld         ; 
input                                       sram_array2ddr_out_rdy         ; 
output  [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    sram_array2ddr_out_data        ; 
                           
//vld rdy mux
assign    sram_array2router_out_vld       = data_destination_flag ? sram_array_out_vld : 1'b0;
assign    sram_array2ddr_out_vld          = data_destination_flag ? 1'b0 : sram_array_out_vld;
assign    sram_array_out_rdy              = data_destination_flag ? sram_array2router_out_rdy : sram_array2ddr_out_rdy;

assign    sram_array2ddr_out_data         = sram_array_out_data;
assign    sram_array2router_out_data      = sram_array_out_data;

assign    sram_array2router_out_last_flag = sram_array_out_last_flag;

endmodule

