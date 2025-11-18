module data_buffer (
    clk                            ,
    rst_n                          ,

    Ins                            ,
    Ins_vld                        ,
    Ins_rdy                        ,
    							      		
    router2sram_array_in_vld       ,
    router2sram_array_in_rdy       ,
    router2sram_array_in_data      ,
    							      
    ddr2sram_array_in_vld          ,
    ddr2sram_array_in_rdy          ,
    ddr2sram_array_in_data         ,
							        
    sram2ddr_DB_AWADDR             ,
    sram2ddr_DB_AWLEN              ,
    sram2ddr_DB_AWVALID            ,
    sram2ddr_DB_AWREADY            ,
    sram2ddr_DB_ARADDR             ,
    sram2ddr_DB_ARLEN              ,
    sram2ddr_DB_ARVALID            ,
    sram2ddr_DB_ARREADY            ,
    													
    sram_array2ddr_out_vld         ,
    sram_array2ddr_out_rdy         ,
    sram_array2ddr_out_data        ,
    								 
    sram_array2router_out_vld      ,
    sram_array2router_out_rdy      ,
    sram_array2router_out_last_flag,
    sram_array2router_out_data     );

					
parameter  DEPTH    = 3072;
parameter  A_WIDTH  = 12  ;
parameter  D_WIDTH  = 16  ;
parameter  BANK_NUM = 17  ;
parameter  GROUP_NUM= 10   ;

/********************************port signals****************************/
input                                         clk                        ;
input                                         rst_n                      ;
                                       								                  	              
input     [63:0]                              Ins                        ;
input                                         Ins_vld                    ;
output                                        Ins_rdy                    ;
		  
input                                         router2sram_array_in_vld   ;
output                                        router2sram_array_in_rdy   ;
input     [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    router2sram_array_in_data  ;
		  
input                                         ddr2sram_array_in_vld      ;
output                                        ddr2sram_array_in_rdy      ;
input     [127:0]                             ddr2sram_array_in_data     ;
		  
output    [31:0]                              sram2ddr_DB_AWADDR         ;
output    [ 7:0]                              sram2ddr_DB_AWLEN          ;
output                                        sram2ddr_DB_AWVALID        ;
input                                         sram2ddr_DB_AWREADY        ; 							                    	     
output    [31:0]                              sram2ddr_DB_ARADDR         ;
output    [ 7:0]                              sram2ddr_DB_ARLEN          ;
output                                        sram2ddr_DB_ARVALID        ;
input                                         sram2ddr_DB_ARREADY        ;
		    		    
//sram array output to ddr
output                                        sram_array2ddr_out_vld          ;
input                                         sram_array2ddr_out_rdy          ;
output    [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    sram_array2ddr_out_data         ;
//sram array output to router
output                                        sram_array2router_out_vld       ;
input                                         sram_array2router_out_rdy       ;
output                                        sram_array2router_out_last_flag ;
output    [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    sram_array2router_out_data      ;

/*******************************wire**************************************/
wire          [11:0]      WBlock                    ;
wire          [11:0]      HBlock                    ;
wire          [11:0]      CBlock                    ;
wire                      WCell                     ;
wire          [ 7:0]      HCell                     ;
wire          [ 4:0]      CCell                     ;
wire          [ 6:0]      WCellstep                 ;
wire          [ 6:0]      HCellstep                 ;
wire          [ 6:0]      CCellstep                 ;
wire          [ 2:0]      OrderCell                 ;
wire          [ 1:0]      work_mode                 ;
wire          [ 1:0]      DW                        ;
wire		          SRAM_wr                   ;
wire          [10:0]      WWindow                   ;
wire          [10:0]      HWindow                   ;
wire          [10:0]      CWindow                   ;
wire          [ 6:0]      WWindowstep               ;
wire          [ 6:0]      HWindowstep               ;
wire          [ 6:0]      CWindowstep               ;
wire          [ 2:0]      OrderWindow               ;
wire          [ 9:0]      access_times              ;
wire    signed[ 5:0]      WWindowstart              ;
wire    signed[ 5:0]      HWindowstart              ;
wire    signed[ 5:0]      CWindowstart              ;
wire          [10:0]      WWindowend                ;
wire          [10:0]      HWindowend                ;
wire          [10:0]      CWindowend                ;
wire                      RWdata_start              ;
wire                      sram_array_read_data_done ;
wire                      sram_array_write_data_done;
wire          [12:0]      Stride                    ;
wire          [12:0]      W0                        ;
wire          [12:0]      H0                        ;
wire          [12:0]      C0                        ;
wire          [12:0]      total_line_num            ;
wire                      DDR_wr                    ;
wire          [26:0]      feature_map_initial_addr  ;
wire          [ 7:0]      Lens                      ;
wire                      gen_addr_start            ;        
wire                      gen_addr_done             ;

wire                      phy_addr2sram_array_in_vld;
wire                      phy_addr2sram_array_in_rdy;



wire                                      sram_array_in_last_flag      ;
wire    [3:0]                             sram_array_in_group_id       ;
wire    [3:0]                             sram_array_in_group_num      ;
wire    [4:0]                             sram_array_in_bank_id        ;
wire    [4:0]                             sram_array_in_bank_num       ;
wire    [6:0]                             sram_array_in_access_num     ;
wire    [1:0]                             sram_array_in_bit_select     ;
wire    [A_WIDTH-1:0]                     sram_array_in_sram_addr      ;
wire    [A_WIDTH-1:0]                     sram_array_in_block_offset   ;
wire    [5:0]                             sram_array_in_padding_h      ;
wire    [5:0]	                          sram_array_in_padding_c      ;
wire    [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]  sram_array_in_data           ;

wire                                      sram_array_in_vld            ;
wire                                      sram_array_in_rdy            ;

wire                                      sram_array_in_data_vld       ; 
wire                                      sram_array_in_data_rdy       ; 
 
wire                                      sram_array_out_vld           ;       
wire                                      sram_array_out_rdy           ; 
wire    [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]  sram_array_out_data          ;      
wire                                      sram_array_out_last_flag     ;

wire                                  sram_array2router_out_to_pipe_vld;      
wire                                  sram_array2router_out_to_pipe_rdy;      
wire [GROUP_NUM*D_WIDTH*BANK_NUM-1:0] sram_array2router_out_to_pipe_data;     
wire                                  sram_array2router_out_to_pipe_last_flag;
wire                                  sram_array2ddr_out_to_pipe_vld;         
wire                                  sram_array2ddr_out_to_pipe_rdy;         
wire [GROUP_NUM*D_WIDTH*BANK_NUM-1:0] sram_array2ddr_out_to_pipe_data;        


//decoder module
decoder		          u_decoder(
    .clk                       (clk                       ),
    .rst_n                     (rst_n                     ),			 	  
    .ins2fifo                  (Ins                       ),
    .ins2fifo_vld              (Ins_vld                   ), 
    .ins2fifo_rdy              (Ins_rdy                   ),         
    .WBlock                    (WBlock                    ),
    .HBlock                    (HBlock                    ),	
    .CBlock                    (CBlock                    ),
    .WCell                     (WCell                     ),
    .HCell                     (HCell                     ),	
    .CCell                     (CCell                     ),
    .WCellstep                 (WCellstep                 ),
    .HCellstep                 (HCellstep                 ), 	
    .CCellstep                 (CCellstep                 ),
    .OrderCell                 (OrderCell                 ), 
    .work_mode                 (work_mode                 ),	
    .DW                        (DW                        ),
    .SRAM_wr                   (SRAM_wr                   ),    	
    .WWindow                   (WWindow                   ),        
    .HWindow                   (HWindow                   ),
    .CWindow                   (CWindow                   ),
    .WWindowstep               (WWindowstep               ), 
    .HWindowstep               (HWindowstep               ),
    .CWindowstep               (CWindowstep               ),
    .OrderWindow               (OrderWindow               ),
    .access_times              (access_times              ),
    .WWindowstart              (WWindowstart              ),
    .HWindowstart              (HWindowstart              ),
    .CWindowstart              (CWindowstart              ),
    .WWindowend                (WWindowend                ),
    .HWindowend                (HWindowend                ),
    .CWindowend                (CWindowend                ),
    .RWdata_start              (RWdata_start              ),
    .sram_array_read_data_done (sram_array_read_data_done ),
    .sram_array_write_data_done(sram_array_write_data_done),                                
    .Stride                    (Stride                    ),
    .W0                        (W0                        ),
    .H0                        (H0                        ),
    .C0                        (C0                        ),
    .total_line_num            (total_line_num            ),
    .DDR_wr                    (DDR_wr                    ),
    .feature_map_initial_addr  (feature_map_initial_addr  ),
    .Lens                      (Lens                      ),
    .gen_addr_start            (gen_addr_start            ),                               
    .gen_addr_done             (gen_addr_done             ));
											             
//DDR address generation module                          
AXI_ACCESS  	 u_AXI_ACCESS(                         
    .clk                       (clk                       ),
    .rst_n                     (rst_n                     ),
    .featuremap_addr           (feature_map_initial_addr  ),
    .W0                        (W0                        ),
    .H0                        (H0                        ),
    .C0                        (C0                        ),
    .Stride                    (Stride                    ),
    .WBlock                    (WBlock                    ),
    .HBlock                    (HBlock                    ),
    .CBlock                    (CBlock                    ),
    .TW                        (total_line_num            ),
    .DW                        (DW                        ),
    .burst_length              (Lens                      ),
    .ddr_wr                    (DDR_wr                    ),
    .gen_addr_start            (gen_addr_start            ),
    .gen_addr_done             (gen_addr_done             ),
    										              
    .DB_AWADDR                 (sram2ddr_DB_AWADDR        ),
    .DB_AWLEN                  (sram2ddr_DB_AWLEN         ),
    .DB_AWVALID                (sram2ddr_DB_AWVALID       ),
    .DB_AWREADY                (sram2ddr_DB_AWREADY       ),
    											          
    .DB_ARADDR                 (sram2ddr_DB_ARADDR        ),
    .DB_ARLEN                  (sram2ddr_DB_ARLEN         ),
    .DB_ARVALID                (sram2ddr_DB_ARVALID       ),
    .DB_ARREADY                (sram2ddr_DB_ARREADY       ));
	
SRAM_ACCESS#(.GROUP_NUM (GROUP_NUM),.BANK_NUM(BANK_NUM))
u_SRAM_ACCESS            (
    .clk                 (clk                          ),
    .rst_n               (rst_n                        ),						        
    .WBlock              (WBlock                       ),
    .HBlock              (HBlock                       ),
    .CBlock              (CBlock                       ),
    .WCell               (WCell                        ),
    .HCell               (HCell                        ),
    .CCell               (CCell                        ),
    .WCellstep           (WCellstep                    ),
    .HCellstep           (HCellstep                    ),
    .CCellstep           (CCellstep                    ),
    .OrderCell           (OrderCell                    ),
    .DW                  (DW                           ),
    .SRAM_wr             (SRAM_wr                      ),
    .WWindow             (WWindow                      ),					   
    .HWindow             (HWindow                      ),
    .CWindow             (CWindow                      ),
    .WWindowstep         (WWindowstep                  ),
    .HWindowstep         (HWindowstep                  ),
    .CWindowstep         (CWindowstep                  ),
    .OrderWindow         (OrderWindow                  ),   
    .access_times        (access_times                 ),   
    .WWindowstart        (WWindowstart                 ),     
    .HWindowstart        (HWindowstart                 ),     
    .CWindowstart        (CWindowstart                 ),     
    .WWindowend          (WWindowend                   ),     
    .HWindowend          (HWindowend                   ),     
    .CWindowend          (CWindowend                   ),     
    .RWdata_start        (RWdata_start                 ),     
    .phy_addr_vld        (phy_addr2sram_array_in_vld   ),     
    .phy_addr_rdy        (phy_addr2sram_array_in_rdy   ),
    .group_id            (sram_array_in_group_id       ),
    .bank_id             (sram_array_in_bank_id        ),
    .group_access_num    (sram_array_in_group_num      ),
    .bank_access_num     (sram_array_in_bank_num       ),
    .access_num          (sram_array_in_access_num     ),
    .bit_select          (sram_array_in_bit_select     ),
    .SRAM_addr           (sram_array_in_sram_addr      ),
    .block_offset_o      (sram_array_in_block_offset   ),
    .padding_num_h       (sram_array_in_padding_h      ),
    .padding_num_c       (sram_array_in_padding_c      ),
    .last_phy_addr_flag  (sram_array_in_last_flag      ));


vld_rdy_2sel1#(.D_WIDTH(D_WIDTH),.BANK_NUM(BANK_NUM),.GROUP_NUM(GROUP_NUM))
u_vld_rdy_2sel1               (
    .data_source_flag         (work_mode[0]             ),         
    .ddr2sram_array_in_vld    (ddr2sram_array_in_vld    ),   
    .ddr2sram_array_in_rdy    (ddr2sram_array_in_rdy    ),   
    .ddr2sram_array_in_data   (ddr2sram_array_in_data   ),   
    .router2sram_array_in_vld (router2sram_array_in_vld ),   
    .router2sram_array_in_rdy (router2sram_array_in_rdy ),   
    .router2sram_array_in_data(router2sram_array_in_data),   
    .sram_array_in_data       (sram_array_in_data       ),
    .sram_array_in_data_vld   (sram_array_in_data_vld   ),
    .sram_array_in_data_rdy   (sram_array_in_data_rdy   ));

vld_rdy_2sync1  u_vld_rdy_2sync1(
    .sram_array_in_rw_flag      (SRAM_wr                   ),         
    .phy_addr2sram_array_in_vld (phy_addr2sram_array_in_vld),   
    .phy_addr2sram_array_in_rdy (phy_addr2sram_array_in_rdy),       
    .sram_array_in_data_vld     (sram_array_in_data_vld    ),
    .sram_array_in_data_rdy     (sram_array_in_data_rdy    ),			
    .sram_array_in_vld          (sram_array_in_vld         ),
    .sram_array_in_rdy          (sram_array_in_rdy         ));       
	
SRAM_ARRAY #(.DEPTH(DEPTH),.A_WIDTH(A_WIDTH),.D_WIDTH(D_WIDTH),.BANK_NUM(BANK_NUM),.GROUP_NUM(GROUP_NUM)) 
u_SRAM_ARRAY      (
    .clk                          (clk                          ),
    .rst_n                        (rst_n                        ),
    .DW                           (DW                           ),
    .ins_dec_rw_data_start        (RWdata_start                 ), 	
    .sram_array_in_vld            (sram_array_in_vld            ),                                                  
    .sram_array_in_rdy            (sram_array_in_rdy            ),
    .sram_array_in_rw_flag        (SRAM_wr                      ), 
    .sram_array_in_group_id       (sram_array_in_group_id       ),
    .sram_array_in_group_num      (sram_array_in_group_num      ),
    .sram_array_in_bank_id        (sram_array_in_bank_id        ),
    .sram_array_in_bank_num       (sram_array_in_bank_num       ),
    .sram_array_in_access_num     (sram_array_in_access_num     ),
    .sram_array_in_bit_select     (sram_array_in_bit_select     ),
    .sram_array_in_sram_addr      (sram_array_in_sram_addr      ),
    .sram_array_in_block_offset   (sram_array_in_block_offset   ),
    .sram_array_in_padding_h      (sram_array_in_padding_h      ),
    .sram_array_in_padding_c      (sram_array_in_padding_c      ),
    .sram_array_in_last_flag      (sram_array_in_last_flag      ),
    .sram_array_in_data           (sram_array_in_data           ),
    .sram_array_out_vld           (sram_array_out_vld           ),
    .sram_array_out_rdy           (sram_array_out_rdy           ),
    .sram_array_out_data          (sram_array_out_data          ),
    .sram_array_write_data_done   (sram_array_write_data_done   ),
    .sram_array_read_data_done    (sram_array_read_data_done    ),
    .sram_array_out_last_flag     (sram_array_out_last_flag     ));

vld_rdy_1sel2#(.D_WIDTH(D_WIDTH),.BANK_NUM(BANK_NUM),.GROUP_NUM(GROUP_NUM))
u_vld_rdy_1sel2                     (
    .data_destination_flag          (work_mode[0]                   ),
    .sram_array_out_vld             (sram_array_out_vld             ),      
    .sram_array_out_rdy             (sram_array_out_rdy             ),
    .sram_array_out_data            (sram_array_out_data            ),	
    .sram_array_out_last_flag       (sram_array_out_last_flag       ),	
    .sram_array2router_out_vld      (sram_array2router_out_to_pipe_vld      ),
    .sram_array2router_out_rdy      (sram_array2router_out_to_pipe_rdy      ),
    .sram_array2router_out_data     (sram_array2router_out_to_pipe_data     ),
    .sram_array2router_out_last_flag(sram_array2router_out_to_pipe_last_flag),									
    .sram_array2ddr_out_vld         (sram_array2ddr_out_to_pipe_vld         ),
    .sram_array2ddr_out_rdy         (sram_array2ddr_out_to_pipe_rdy         ),
    .sram_array2ddr_out_data        (sram_array2ddr_out_to_pipe_data        ));

VLD_RDY_PIPE#(.DATA_WIDTH(GROUP_NUM*D_WIDTH*BANK_NUM + 1))
u0_VLD_RDY_PIPE(
    .clk                                            (clk),
    .rst_n                                          (rst_n),
    .in_data_vld                                    (sram_array2router_out_to_pipe_vld                                           ),
    .in_data_rdy                                    (sram_array2router_out_to_pipe_rdy                                           ),
    .in_data                                        ({sram_array2router_out_to_pipe_data,sram_array2router_out_to_pipe_last_flag}),           
    .out_data_vld                                   (sram_array2router_out_vld                                                   ),
    .out_data_rdy                                   (sram_array2router_out_rdy                                                   ),    
    .out_data                                       ({sram_array2router_out_data,sram_array2router_out_last_flag}                ));

VLD_RDY_PIPE#(.DATA_WIDTH(GROUP_NUM*D_WIDTH*BANK_NUM))
u1_VLD_RDY_PIPE(
    .clk                                            (clk),
    .rst_n                                          (rst_n),
    .in_data_vld                                    (sram_array2ddr_out_to_pipe_vld ),
    .in_data_rdy                                    (sram_array2ddr_out_to_pipe_rdy ),
    .in_data                                        (sram_array2ddr_out_to_pipe_data),           
    .out_data_vld                                   (sram_array2ddr_out_vld                 ),
    .out_data_rdy                                   (sram_array2ddr_out_rdy                 ),    
    .out_data                                       (sram_array2ddr_out_data                ));
    

/*reg [31:0]   ddr2sram_in_data_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
      ddr2sram_in_data_cnt <= 'd0;
    else if(ddr2sram_array_in_vld && ddr2sram_array_in_rdy)
           ddr2sram_in_data_cnt <= ddr2sram_in_data_cnt + 'd1;
end

reg [31:0]   sram_in_data_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
      sram_in_data_cnt <= 'd0;
    else if(sram_array_in_data_vld && sram_array_in_data_rdy)
           sram_in_data_cnt <= sram_in_data_cnt + 'd1;
end

reg [31:0]   phy_addr2sram_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
      phy_addr2sram_cnt <= 'd0;
    else if(phy_addr2sram_array_in_vld && phy_addr2sram_array_in_rdy)
           phy_addr2sram_cnt <= phy_addr2sram_cnt + 'd1;
end

reg [31:0]   sram_in_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
       sram_in_cnt <= 'd0;
    else if(sram_array_in_vld && sram_array_in_rdy)
           sram_in_cnt <= sram_in_cnt + 'd1;
end

reg [31:0]   sram2ddr_addr_cnt;
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
      sram2ddr_addr_cnt <= 'd0;
    else if(sram2ddr_DB_ARVALID && sram2ddr_DB_ARREADY)
           sram2ddr_addr_cnt <= sram2ddr_addr_cnt + 'd1;
end
*/
reg [31:0]   sram2routing_out_data_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
      sram2routing_out_data_cnt <= 'd0;
    else if(sram_array2router_out_last_flag)
       sram2routing_out_data_cnt <= 'd0;
    else if(sram_array2router_out_vld && sram_array2router_out_rdy)
           sram2routing_out_data_cnt <= sram2routing_out_data_cnt + 'd1;
end


endmodule
