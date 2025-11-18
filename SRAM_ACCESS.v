module SRAM_ACCESS#(
parameter GROUP_NUM = 10,
parameter BANK_NUM  = 17
)
(
    input                    clk               ,  
    input                    rst_n             ,  

    input        [11:0]      WBlock            ,        
    input        [11:0]      HBlock            ,
    input        [11:0]      CBlock            ,
    input                    WCell             ,
    input        [ 7:0]      HCell             ,
    input        [ 4:0]      CCell             ,
    input        [ 6:0]      WCellstep         ,
    input        [ 6:0]      HCellstep         ,
    input        [ 6:0]      CCellstep         ,
    input        [ 2:0]      OrderCell         ,
    input        [ 1:0]      DW                ,
    input                    SRAM_wr           ,
    input        [10:0]      WWindow           ,
    input        [10:0]      HWindow           ,
    input        [10:0]      CWindow           ,
    input        [ 6:0]      WWindowstep       ,
    input        [ 6:0]      HWindowstep       ,
    input        [ 6:0]      CWindowstep       ,
    input        [ 2:0]      OrderWindow       ,
    input        [ 9:0]      access_times      ,
    input signed [ 5:0]      WWindowstart      ,
    input signed [ 5:0]      HWindowstart      ,
    input signed [ 5:0]      CWindowstart      ,
    input        [10:0]      WWindowend        ,
    input        [10:0]      HWindowend        ,
    input        [10:0]      CWindowend        ,
    input                    RWdata_start      ,
  
    output wire              phy_addr_vld      ,
    input                    phy_addr_rdy      ,
                             
    output wire [ 3:0]       group_id          ,
    output wire [ 4:0]       bank_id           ,
    output wire [ 3:0]       group_access_num  ,
    output wire [ 4:0]       bank_access_num   ,
    output wire [ 6:0]       access_num        ,
    output wire [ 1:0]       bit_select        ,
    output wire [11:0]       SRAM_addr         ,
    output wire [11:0]       block_offset_o    ,
    output wire [5:0]        padding_num_h     , 
    output wire [5:0]        padding_num_c     ,
    output wire              last_phy_addr_flag);

/*****************wire********************/
wire                  position_vld       ;
wire                  position_rdy       ;
wire  [11:0]  sram_pos_w         ;
wire  [11:0]  sram_pos_h         ;
wire  [11:0]  sram_pos_c         ;                            
wire          [ 9:0]  access_w           ;
wire          [ 9:0]  access_h           ;
wire          [ 9:0]  access_c           ;
wire                  last_position_flag ;
wire          [ 9:0]  padding_num_w_logic2phy      ;
wire          [ 9:0]  padding_num_h_logic2phy      ;
wire          [ 9:0]  padding_num_c_logic2phy      ;

//SRAM Logical Position Calculation                             
SRAM_logic_pos u_SRAM_logic_pos(                                
    .clk                                    (clk               ),          
    .rst_n                                  (rst_n             ),          
    .WBlock                                 (WBlock            ),           
    .HBlock                                 (HBlock            ),          
    .CBlock                                 (CBlock            ),          
    .WCell                                  (WCell             ),          
    .HCell                                  (HCell             ),          
    .CCell                                  (CCell             ),                  
    .WCellstep                              (WCellstep         ),          
    .HCellstep                              (HCellstep         ),             
    .CCellstep                              (CCellstep         ),          
    .OrderCell                              (OrderCell         ),                   
    .SRAM_wr                                (SRAM_wr           ), 
    .WWindow                                (WWindow           ),        
    .HWindow                                (HWindow           ),          
    .CWindow                                (CWindow           ),          
    .WWindowstep                            (WWindowstep       ),          
    .HWindowstep                            (HWindowstep       ),          
    .CWindowstep                            (CWindowstep       ),          
    .OrderWindow                            (OrderWindow       ),          
    .access_times                           (access_times      ),          
    .WWindowstart                           (WWindowstart      ),          
    .HWindowstart                           (HWindowstart      ),          
    .CWindowstart                           (CWindowstart      ),          
    .WWindowend                             (WWindowend        ),          
    .HWindowend                             (HWindowend        ),          
    .CWindowend                             (CWindowend        ),
    .RWdata_start                           (RWdata_start      ),
                                                              
    .position_vld                           (position_vld      ),
    .position_rdy                           (position_rdy      ),
    .cell_pos_inside_block_w                (sram_pos_w        ),
    .cell_pos_inside_block_h                (sram_pos_h        ),
    .cell_pos_inside_block_c                (sram_pos_c        ),
    .data_num_outside_negetive_boundary_w   (padding_num_w_logic2phy     ),
    .data_num_outside_negetive_boundary_h   (padding_num_h_logic2phy     ),
    .data_num_outside_negetive_boundary_c   (padding_num_c_logic2phy     ),
    .access_w                               (access_w          ),
    .access_h                               (access_h          ),
    .access_c                               (access_c          ),                                
    .last_position_flag                     (last_position_flag));

//SRAM physical addr Calculation                                 
SRAM_phy_addr#(.GROUP_NUM (GROUP_NUM),.BANK_NUM(BANK_NUM))     
u_SRAM_phy_addr        (                                        
    .clk               (clk                 ),                    
    .rst_n             (rst_n               ),                    
    .WBlock            (WBlock              ),                    
    .HBlock            (HBlock              ),                    
    .CBlock            (CBlock              ),                    
    .DW                (DW                  ),                    
    .position_vld      (position_vld        ),
    .position_rdy      (position_rdy        ),
    .pos_w             (sram_pos_w          ),
    .pos_h             (sram_pos_h          ),
    .pos_c             (sram_pos_c          ),
    .access_w          (access_w[0]         ),
    .access_h          (access_h[6:0]       ),
    .access_c          (access_c[3:0]       ),
    .padding_num_w_in  (padding_num_w_logic2phy[5:0]    ),
    .padding_num_h_in  (padding_num_h_logic2phy[5:0]    ),
    .padding_num_c_in  (padding_num_c_logic2phy[5:0]    ),
    .last_position_flag(last_position_flag  ),
    .phy_addr_vld      (phy_addr_vld        ),
    .phy_addr_rdy      (phy_addr_rdy        ),
    .group_id          (group_id            ),
    .bank_id           (bank_id             ),
    .group_access_num  (group_access_num    ),
    .bank_access_num   (bank_access_num     ),
    .access_num        (access_num          ),
    .bit_select        (bit_select          ),
    .SRAM_addr         (SRAM_addr           ),
    .block_offset_o    (block_offset_o      ),
    .padding_num_h_out (padding_num_h       ),
    .padding_num_c_out (padding_num_c       ),
    .last_phy_addr_flag(last_phy_addr_flag  ));
        
reg [31:0]   position_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
      position_cnt <= 'd0;
    else if(position_vld && position_rdy)
           position_cnt <= position_cnt + 'd1;
end

reg [31:0]   phy_addr_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
      phy_addr_cnt <= 'd0;
    else if(phy_addr_vld && phy_addr_rdy)
           phy_addr_cnt <= phy_addr_cnt + 'd1;
end



endmodule
