module AXI_r_arb(
    input clk,
    input rst_n,
    //buff0
    input [31:0] DB_ARADDR_0,
    input [7:0]  DB_ARLEN_0,
    input [3:0]  DB_ARID_0,
    input        DB_ARVALID_0,
    output       DB_ARREADY_0,

    output [127:0] DB_RDATA_0,
    output         DB_RLAST_0,
    output         DB_RVALID_0,
    input          DB_RREADY_0,
    //buff1
    input [31:0] DB_ARADDR_1,
    input [7:0]  DB_ARLEN_1,
    input [3:0]  DB_ARID_1,
    input DB_ARVALID_1,
    output DB_ARREADY_1,

    output [127:0] DB_RDATA_1,
    output DB_RLAST_1,
    output DB_RVALID_1,
    input DB_RREADY_1,
    //buff2
    input [31:0] DB_ARADDR_2,
    input [7:0]  DB_ARLEN_2,
    input [3:0]  DB_ARID_2,
    input DB_ARVALID_2,
    output DB_ARREADY_2,

    output [127:0] DB_RDATA_2,
    output DB_RLAST_2,
    output DB_RVALID_2,
    input DB_RREADY_2,
    //buff3
    input [31:0] DB_ARADDR_3,
    input [7:0]  DB_ARLEN_3,
    input [3:0]  DB_ARID_3,
    input DB_ARVALID_3,
    output DB_ARREADY_3,

    output [127:0] DB_RDATA_3,
    output DB_RLAST_3,
    output DB_RVALID_3,
    input DB_RREADY_3,
    //buff4
    input [31:0] DB_ARADDR_4,
    input [7:0]  DB_ARLEN_4,
    input [3:0]  DB_ARID_4,
    input DB_ARVALID_4,
    output DB_ARREADY_4,

    output [127:0] DB_RDATA_4,
    output DB_RLAST_4,
    output DB_RVALID_4,
    input DB_RREADY_4,
    //buff5
    input [31:0] DB_ARADDR_5,
    input [7:0]  DB_ARLEN_5,
    input [3:0]  DB_ARID_5,
    input DB_ARVALID_5,
    output DB_ARREADY_5,

    output [127:0] DB_RDATA_5,
    output DB_RLAST_5,
    output DB_RVALID_5,
    input DB_RREADY_5,

    input [31:0] DB_ARADDR_6,
    input [7:0]  DB_ARLEN_6,
    input [3:0]  DB_ARID_6,
    input DB_ARVALID_6,
    output DB_ARREADY_6,

    output [127:0] DB_RDATA_6,
    output DB_RLAST_6,
    output DB_RVALID_6,
    input DB_RREADY_6,
    //axi
    output [31:0] DB_ARADDR,
    output [7:0]  DB_ARLEN,
    output [3:0]  DB_ARID,
    output DB_ARVALID,
    input DB_ARREADY,

    input [127:0] DB_RDATA,
    input [3:0] DB_RID,
    input DB_RLAST,
    input DB_RVALID,
    output DB_RREADY
);


wire [31:0] DB_ARADDR_7  ;
wire [7:0]  DB_ARLEN_7   ;
wire [3:0]  DB_ARID_7    ;
wire        DB_ARVALID_7 ;
wire        DB_RREADY_7  ;

wire         DB_ARREADY_7;  
wire [127:0] DB_RDATA_7  ;
wire         DB_RLAST_7  ;
wire         DB_RVALID_7 ; 

assign DB_ARADDR_7  ='b0;
assign DB_ARLEN_7   ='b0;
assign DB_ARID_7    ='b0;
assign DB_ARVALID_7 =1'b0;
assign DB_RREADY_7  =1'b1;

wire [43:0]   AR_Arb_data_01; 
wire [43:0]   AR_Arb_data_23; 
wire [43:0]   AR_Arb_data_45; 
wire [43:0]   AR_Arb_data_67; 
wire [43:0]   AR_Arb_data_0123; 
wire [43:0]   AR_Arb_data_4567; 

wire [132:0]  R_Arb_data_01 ;
wire [132:0]  R_Arb_data_23 ;
wire [132:0]  R_Arb_data_45 ;
wire [132:0]  R_Arb_data_67 ;
wire [132:0]  R_Arb_data_0123 ;
wire [132:0]  R_Arb_data_4567 ;

wire [3:0]    DB_RID_0;
wire [3:0]    DB_RID_1;
wire [3:0]    DB_RID_2;
wire [3:0]    DB_RID_3;
wire [3:0]    DB_RID_4;
wire [3:0]    DB_RID_5;
wire [3:0]    DB_RID_6;
wire [3:0]    DB_RID_7;

axi_read_channel_Arb_2to1#(.HIGH_ID(1)) axi_read_channel_Arb_2to1_01(
  .clk          (clk                               ),
  .rst_n        (rst_n                             ),
  .AR_VLD0      (DB_ARVALID_0                      ),
  .AR_RDY0      (DB_ARREADY_0                      ),
  .AR_DATA0     ({DB_ARADDR_0,DB_ARLEN_0,DB_ARID_0}),
  .AR_VLD1      (DB_ARVALID_1                      ),
  .AR_RDY1      (DB_ARREADY_1                      ),
  .AR_DATA1     ({DB_ARADDR_1,DB_ARLEN_1,DB_ARID_1}),
  .R_VLD0       (DB_RVALID_0                       ),
  .R_RDY0       (DB_RREADY_0                       ),
  .R_DATA0      ({DB_RLAST_0,DB_RDATA_0,DB_RID_0[3:0]} ),
  .R_VLD1       (DB_RVALID_1                       ),
  .R_RDY1       (DB_RREADY_1                       ),
  .R_DATA1      ({DB_RLAST_1,DB_RDATA_1,DB_RID_1[3:0]} ),
  .AR_VLD_O     (AR_Arb_vld_01                     ),
  .AR_RDY_O     (AR_Arb_rdy_01                     ),
  .AR_DATA_O    (AR_Arb_data_01                    ),
  .R_VLD_I      (R_Arb_vld_01                      ),
  .R_RDY_I      (R_Arb_rdy_01                      ),
  .R_DATA_I     (R_Arb_data_01                     )
);


axi_read_channel_Arb_2to1 #(.HIGH_ID(3)) axi_read_channel_Arb_2to1_23(
  .clk          (clk                               ),
  .rst_n        (rst_n                             ),
  .AR_VLD0      (DB_ARVALID_2                      ),
  .AR_RDY0      (DB_ARREADY_2                      ),
  .AR_DATA0     ({DB_ARADDR_2,DB_ARLEN_2,DB_ARID_2}),
  .AR_VLD1      (DB_ARVALID_3                      ),
  .AR_RDY1      (DB_ARREADY_3                      ),
  .AR_DATA1     ({DB_ARADDR_3,DB_ARLEN_3,DB_ARID_3}),
  .R_VLD0       (DB_RVALID_2                       ),
  .R_RDY0       (DB_RREADY_2                       ),
  .R_DATA0      ({DB_RLAST_2,DB_RDATA_2,DB_RID_2[3:0]} ),
  .R_VLD1       (DB_RVALID_3                       ),
  .R_RDY1       (DB_RREADY_3                       ),
  .R_DATA1      ({DB_RLAST_3,DB_RDATA_3,DB_RID_3[3:0]} ),
  .AR_VLD_O     (AR_Arb_vld_23                     ),
  .AR_RDY_O     (AR_Arb_rdy_23                     ),
  .AR_DATA_O    (AR_Arb_data_23                    ),
  .R_VLD_I      (R_Arb_vld_23                      ),
  .R_RDY_I      (R_Arb_rdy_23                      ),
  .R_DATA_I     (R_Arb_data_23                     )
);

axi_read_channel_Arb_2to1 #(.HIGH_ID(5))  axi_read_channel_Arb_2to1_45(
  .clk          (clk                               ),
  .rst_n        (rst_n                             ),
  .AR_VLD0      (DB_ARVALID_4                      ),
  .AR_RDY0      (DB_ARREADY_4                      ),
  .AR_DATA0     ({DB_ARADDR_4,DB_ARLEN_4,DB_ARID_4}),
  .AR_VLD1      (DB_ARVALID_5                      ),
  .AR_RDY1      (DB_ARREADY_5                      ),
  .AR_DATA1     ({DB_ARADDR_5,DB_ARLEN_5,DB_ARID_5}),
  .R_VLD0       (DB_RVALID_4                       ),
  .R_RDY0       (DB_RREADY_4                       ),
  .R_DATA0      ({DB_RLAST_4,DB_RDATA_4,DB_RID_4[3:0]} ),
  .R_VLD1       (DB_RVALID_5                       ),
  .R_RDY1       (DB_RREADY_5                       ),
  .R_DATA1      ({DB_RLAST_5,DB_RDATA_5,DB_RID_5[3:0]} ),
  .AR_VLD_O     (AR_Arb_vld_45                     ),
  .AR_RDY_O     (AR_Arb_rdy_45                     ),
  .AR_DATA_O    (AR_Arb_data_45                    ),
  .R_VLD_I      (R_Arb_vld_45                      ),
  .R_RDY_I      (R_Arb_rdy_45                      ),
  .R_DATA_I     (R_Arb_data_45                     )
);

axi_read_channel_Arb_2to1 #(.HIGH_ID(7))  axi_read_channel_Arb_2to1_67(
  .clk          (clk                               ),
  .rst_n        (rst_n                             ),
  .AR_VLD0      (DB_ARVALID_6                      ),
  .AR_RDY0      (DB_ARREADY_6                      ),
  .AR_DATA0     ({DB_ARADDR_6,DB_ARLEN_6,DB_ARID_6}),
  .AR_VLD1      (DB_ARVALID_7                      ),
  .AR_RDY1      (DB_ARREADY_7                      ),
  .AR_DATA1     ({DB_ARADDR_7,DB_ARLEN_7,DB_ARID_7}),
  .R_VLD0       (DB_RVALID_6                       ),
  .R_RDY0       (DB_RREADY_6                       ),
  .R_DATA0      ({DB_RLAST_6,DB_RDATA_6,DB_RID_6[3:0]} ),
  .R_VLD1       (DB_RVALID_7                       ),
  .R_RDY1       (DB_RREADY_7                       ),
  .R_DATA1      ({DB_RLAST_7,DB_RDATA_7,DB_RID_7[3:0]} ),
  .AR_VLD_O     (AR_Arb_vld_67                     ),
  .AR_RDY_O     (AR_Arb_rdy_67                     ),
  .AR_DATA_O    (AR_Arb_data_67                    ),
  .R_VLD_I      (R_Arb_vld_67                      ),
  .R_RDY_I      (R_Arb_rdy_67                      ),
  .R_DATA_I     (R_Arb_data_67                     )
);

axi_read_channel_Arb_2to1 #(.HIGH_ID(2)) axi_read_channel_Arb_2to1_0123(
  .clk          (clk                               ),
  .rst_n        (rst_n                             ),
  .AR_VLD0      (AR_Arb_vld_01                     ),
  .AR_RDY0      (AR_Arb_rdy_01                     ),
  .AR_DATA0     (AR_Arb_data_01                    ),
  .AR_VLD1      (AR_Arb_vld_23                     ),
  .AR_RDY1      (AR_Arb_rdy_23                     ),
  .AR_DATA1     (AR_Arb_data_23                    ),
  .R_VLD0       (R_Arb_vld_01                      ),
  .R_RDY0       (R_Arb_rdy_01                      ),
  .R_DATA0      (R_Arb_data_01                     ),
  .R_VLD1       (R_Arb_vld_23                      ),
  .R_RDY1       (R_Arb_rdy_23                      ),
  .R_DATA1      (R_Arb_data_23                     ),
  .AR_VLD_O     (AR_Arb_vld_0123                   ),
  .AR_RDY_O     (AR_Arb_rdy_0123                   ),
  .AR_DATA_O    (AR_Arb_data_0123                  ),
  .R_VLD_I      (R_Arb_vld_0123                    ),
  .R_RDY_I      (R_Arb_rdy_0123                    ),
  .R_DATA_I     (R_Arb_data_0123                   )
);

axi_read_channel_Arb_2to1 #(.HIGH_ID(6)) axi_read_channel_Arb_2to1_4567(
  .clk          (clk                               ),
  .rst_n        (rst_n                             ),
  .AR_VLD0      (AR_Arb_vld_45                     ),
  .AR_RDY0      (AR_Arb_rdy_45                     ),
  .AR_DATA0     (AR_Arb_data_45                    ),
  .AR_VLD1      (AR_Arb_vld_67                     ),
  .AR_RDY1      (AR_Arb_rdy_67                     ),
  .AR_DATA1     (AR_Arb_data_67                    ),
  .R_VLD0       (R_Arb_vld_45                      ),
  .R_RDY0       (R_Arb_rdy_45                      ),
  .R_DATA0      (R_Arb_data_45                     ),
  .R_VLD1       (R_Arb_vld_67                      ),
  .R_RDY1       (R_Arb_rdy_67                      ),
  .R_DATA1      (R_Arb_data_67                     ),
  .AR_VLD_O     (AR_Arb_vld_4567                   ),
  .AR_RDY_O     (AR_Arb_rdy_4567                   ),
  .AR_DATA_O    (AR_Arb_data_4567                  ),
  .R_VLD_I      (R_Arb_vld_4567                    ),
  .R_RDY_I      (R_Arb_rdy_4567                    ),
  .R_DATA_I     (R_Arb_data_4567                   )
);

axi_read_channel_Arb_2to1  #(.HIGH_ID(4)) axi_read_channel_Arb_2to1_01234567(
  .clk          (clk                               ),
  .rst_n        (rst_n                             ),
  .AR_VLD0      (AR_Arb_vld_0123                     ),
  .AR_RDY0      (AR_Arb_rdy_0123                     ),
  .AR_DATA0     (AR_Arb_data_0123                    ),
  .AR_VLD1      (AR_Arb_vld_4567                     ),
  .AR_RDY1      (AR_Arb_rdy_4567                     ),
  .AR_DATA1     (AR_Arb_data_4567                    ),
  .R_VLD0       (R_Arb_vld_0123                      ),
  .R_RDY0       (R_Arb_rdy_0123                      ),
  .R_DATA0      (R_Arb_data_0123                     ),
  .R_VLD1       (R_Arb_vld_4567                      ),
  .R_RDY1       (R_Arb_rdy_4567                      ),
  .R_DATA1      (R_Arb_data_4567                     ),
  .AR_VLD_O     (DB_ARVALID                          ),
  .AR_RDY_O     (DB_ARREADY                          ),
  .AR_DATA_O    ({DB_ARADDR,DB_ARLEN,DB_ARID}        ),
  .R_VLD_I      (DB_RVALID                           ),
  .R_RDY_I      (DB_RREADY                           ),
  .R_DATA_I     ({DB_RLAST,DB_RDATA,DB_RID}          )
);


endmodule
