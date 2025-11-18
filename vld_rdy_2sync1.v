module vld_rdy_2sync1(
            sram_array_in_rw_flag     ,         
            phy_addr2sram_array_in_vld,   
            phy_addr2sram_array_in_rdy,       
            sram_array_in_data_vld    ,
            sram_array_in_data_rdy    ,			
			sram_array_in_vld         ,
			sram_array_in_rdy         );
			
input                 sram_array_in_rw_flag     ; 
input                 phy_addr2sram_array_in_vld; 
output                phy_addr2sram_array_in_rdy; 
input                 sram_array_in_data_vld    ; 
output                sram_array_in_data_rdy    ; 
 
output                sram_array_in_vld         ;   
input                 sram_array_in_rdy         ;

							
//vld rdy sync
assign    sram_array_in_vld         = sram_array_in_rw_flag ? phy_addr2sram_array_in_vld & sram_array_in_data_vld     : phy_addr2sram_array_in_vld;
assign    sram_array_in_data_rdy    = sram_array_in_rw_flag ? sram_array_in_rdy          & phy_addr2sram_array_in_vld : 1'b0;
assign    phy_addr2sram_array_in_rdy= sram_array_in_rw_flag ? sram_array_in_rdy          & sram_array_in_data_vld     : sram_array_in_rdy;
	
endmodule
