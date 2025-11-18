module vld_rdy_2sel1#(
parameter  D_WIDTH      = 16  ,
parameter  BANK_NUM     = 17  ,
parameter  GROUP_NUM    = 10   
)(
            data_source_flag         ,         
            ddr2sram_array_in_vld    ,   
            ddr2sram_array_in_rdy    ,   
            ddr2sram_array_in_data   ,   
            router2sram_array_in_vld ,   
            router2sram_array_in_rdy ,   
            router2sram_array_in_data,   
            sram_array_in_data       ,
            sram_array_in_data_vld   ,
            sram_array_in_data_rdy   );

input                                       data_source_flag         ;  
input                                       ddr2sram_array_in_vld    ;  
output                                      ddr2sram_array_in_rdy    ; 
input   [127:0]                             ddr2sram_array_in_data   ;
input                                       router2sram_array_in_vld ;  
output                                      router2sram_array_in_rdy ; 
input   [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    router2sram_array_in_data; 

output  [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    sram_array_in_data       ;   
output                                      sram_array_in_data_vld   ;        
input                                       sram_array_in_data_rdy   ;     

//vld rdy mux
assign    sram_array_in_data_vld    = ~data_source_flag ? ddr2sram_array_in_vld  : router2sram_array_in_vld ;
assign    ddr2sram_array_in_rdy     = ~data_source_flag ? sram_array_in_data_rdy : 1'b0                      ;
assign    router2sram_array_in_rdy  = ~data_source_flag ? 1'b0                   : sram_array_in_data_rdy    ;

generate if(D_WIDTH*BANK_NUM > 128)
begin : padding0
    assign    sram_array_in_data[D_WIDTH*BANK_NUM-1:0] = ~data_source_flag ? {{(D_WIDTH*BANK_NUM-128){1'b0}},ddr2sram_array_in_data[127:0]} : router2sram_array_in_data[D_WIDTH*BANK_NUM-1:0];
end
else
begin : nopadding
    assign    sram_array_in_data[D_WIDTH*BANK_NUM-1:0] = ~data_source_flag ? ddr2sram_array_in_data[D_WIDTH*BANK_NUM-1:0] : router2sram_array_in_data[D_WIDTH*BANK_NUM-1:0];
end
endgenerate

//assign sram_array_in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1:BANK_NUM*D_WIDTH] = router2sram_array_in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1:BANK_NUM*D_WIDTH];
generate
    if (GROUP_NUM > 1) begin : assign_sram_data
        assign sram_array_in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1 : BANK_NUM*D_WIDTH] = router2sram_array_in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1 : BANK_NUM*D_WIDTH];
    end
endgenerate


endmodule

