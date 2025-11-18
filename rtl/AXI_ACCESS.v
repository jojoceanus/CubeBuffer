`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/20 16:56:45
// Design Name: KYC
// Module Name: ddr_addr_gen
// Project Name: DDR_ADDR_GEN
// Target Devices: 
// Tool Versions: 
// Description: The DDR address generation unit generates the current read/write address of the DDR 
//              by means of the control signal sent from the decoder unit.
//              Since the data reading and writing directly with the DDR uses burst reading and writing,
//              it is sufficient to generate only one burst address for each burst reading and writing.
// Dependencies: 
// 
// Revision: 1.1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI_ACCESS(
        //system signal
        input          clk            ,
        input           rst_n          ,
        
        //Interfaces to decoder unit
        input[26:0]       featuremap_addr,
        input[12:0]    W0             ,
        input[12:0]    H0             ,
         input[12:0]    C0             ,
        input[12:0]    Stride         ,
        input[11:0]    WBlock         ,
        input[11:0]    HBlock         ,
        input[11:0]    CBlock         ,
        input[12:0]    TW             ,
        input[ 1:0]    DW             ,
        input[ 7:0]    burst_length   ,
        input          ddr_wr         ,
        input          gen_addr_start ,
        output         gen_addr_done  ,
            
        //Interfaces to memory Arbiter unit
        //AXI bus write address channel
        output[31:0]   DB_AWADDR      ,
        output[ 7:0]   DB_AWLEN       ,
        output         DB_AWVALID     ,
        input          DB_AWREADY     ,
            
        //AXI bus read address channel
        output[31:0]   DB_ARADDR      ,
        output[ 7:0]   DB_ARLEN       ,
        output         DB_ARVALID     ,
        input          DB_ARREADY    
);

/*****************wire********************/
wire             logic_vld    ;
wire             logic_rdy    ;
wire[12:0]       w_position   ;
wire[12:0]       h_position   ;
wire[12:0]       c_position   ;
wire[ 7:0]       length       ;
wire             last_position_flag;

//Logical Position Calculation 
ddr_logic_pos u_ddr_logic_pos(
    .clk                     (clk           ),
    .rst_n                   (rst_n         ),
                                                     
    .W0                      (W0            ),
    .H0                      (H0            ),
    .C0                      (C0            ),
    .WBlock                  (WBlock        ),
    .HBlock                  (HBlock        ),
    .CBlock                  (CBlock        ),
    .DW                      (DW            ),
    .burst_length            (burst_length  ),
    .gen_addr_start          (gen_addr_start),
                                             
    .w_position              (w_position    ),
    .h_position              (h_position    ),
    .c_position              (c_position    ),
    .length                  (length        ),
    .last_position_flag      (last_position_flag ),
    .logic_vld               (logic_vld     ),
    .logic_rdy               (logic_rdy     ));    

//physical addr Calculation     
ddr_phy_addr  u_ddr_phy_addr(
    .clk                    (clk                 ),   
    .rst_n                  (rst_n               ),   
                                                  
    .featuremap_addr        (featuremap_addr     ),   
    .Maxheight              (Stride              ),   
    .TW                     (TW                  ), 
    .DW                     (DW                  ),   
    .ddr_wr                 (ddr_wr              ),
    .gen_addr_start         (gen_addr_start      ),
    .gen_addr_done          (gen_addr_done       ),             
                                                         
    .w_position             (w_position          ),   
    .h_position             (h_position          ),   
    .c_position             (c_position          ),   
    .length                 (length              ),
    .last_position_flag     (last_position_flag  ),            
    .logic_vld              (logic_vld           ),   
    .logic_rdy              (logic_rdy           ),
                                                         
    .DB_AWADDR              (DB_AWADDR           ),   
    .DB_AWLEN               (DB_AWLEN            ),   
    .DB_AWVALID             (DB_AWVALID          ),   
    .DB_AWREADY             (DB_AWREADY          ),   
                             
    .DB_ARADDR              (DB_ARADDR           ),   
    .DB_ARLEN               (DB_ARLEN            ),   
    .DB_ARVALID             (DB_ARVALID          ),   
    .DB_ARREADY             (DB_ARREADY          ));    
        
    
endmodule
