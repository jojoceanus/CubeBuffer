module axi_read_channel_Arb_2to1(
    input          clk      ,
    input          rst_n    ,
    input          AR_VLD0  ,
    output         AR_RDY0  ,
    input [43:0]   AR_DATA0 ,
    input          AR_VLD1  ,
    output         AR_RDY1  ,
    input [43:0]   AR_DATA1 ,
    output         R_VLD0   ,
    input          R_RDY0   ,
    output [132:0] R_DATA0  ,
    output         R_VLD1   ,
    input          R_RDY1   ,
    output [132:0] R_DATA1  ,
    output         AR_VLD_O ,
    input          AR_RDY_O ,
    output [43:0]  AR_DATA_O,
    input          R_VLD_I  ,
    output         R_RDY_I  ,
    input [132:0]  R_DATA_I
);

    // Parameters
    parameter   HIGH_ID = 1; 
  
    localparam  ADDR_WIDTH   = 44;
    localparam  FIFO_DEPTH_1 = 2;

    localparam  FIFO_WIDTH_2 = 4;
    localparam  FIFO_DEPTH_2 = 16;

    localparam  DATA_WIDTH    = 133;
    localparam  FIFO_DEPTH_34 = 4;

    wire [43:0] arb_data;

    wire vld,rdy;
    wire vld_data00,rdy_data00;
    wire [132:0] data00_data;
    wire vld_data11,rdy_data11;
    wire [132:0] data11_data;
//**************AR channle**********************//
    vld_rdy_arb_2to1_byturn #(.DATA_WIDTH(ADDR_WIDTH))
    arb_2to1 (
      .clk            (clk       ),
      .rst_n          (rst_n     ),
      .vld_0          (AR_VLD0   ),
      .rdy_0          (AR_RDY0   ),
      .data_0         (AR_DATA0  ),
      .vld_1          (AR_VLD1   ),
      .rdy_1          (AR_RDY1   ),
      .data_1         (AR_DATA1  ),
      .selected_vld   (arb_vld   ),
      .selected_rdy   (arb_rdy   ),
      .selected_data  (arb_data  ));

    wire [43:0] arb_fifo_out_data;
    vld_rdy_fifo # (
      .FIFO_WIDTH(ADDR_WIDTH ),
      .FIFO_DEPTH(FIFO_DEPTH_1)
    )
    arb_fifo (
      .clk              (clk          ),
      .rst_n            (rst_n        ),
      .fifo_i_vld       (arb_vld      ),
      .fifo_i_rdy       (arb_rdy      ),
      .fifo_i_data      (arb_data     ),
      .fifo_o_data      (arb_fifo_out_data    ),
      .fifo_o_vld       (arb_fifo_out_vld     ),
      .fifo_o_rdy       (arb_fifo_out_rdy     )
    );

    vld_rdy_sync_1to2  VLD_RDY_1to2_inst (
      .vld_in       (arb_fifo_out_vld      ),
      .rdy_in       (arb_fifo_out_rdy      ),
      .vld_out_0      (AR_VLD_O              ),
      .rdy_out_0      (AR_RDY_O              ),
      .vld_out_1      (ARID_fifo_in_vld      ),
      .rdy_out_1      (ARID_fifo_in_rdy      )
    );

    assign AR_DATA_O           = arb_fifo_out_data;

    wire [3:0] ARID_fifo_out_data;

    vld_rdy_fifo # (
        .FIFO_WIDTH(FIFO_WIDTH_2),
        .FIFO_DEPTH(FIFO_DEPTH_2)
      )
    ARID_FIFO (
        .clk        (clk),
        .rst_n      (rst_n),
        .fifo_i_vld (ARID_fifo_in_vld       ),
        .fifo_i_rdy (ARID_fifo_in_rdy       ),
        .fifo_i_data(arb_fifo_out_data[3:0] ),
        .fifo_o_vld (ARID_fifo_out_vld      ),
        .fifo_o_rdy (ARID_fifo_out_rdy      ),
        .fifo_o_data(ARID_fifo_out_data     ));

    assign ARID_fifo_out_rdy = R_VLD_I & R_RDY_I & R_DATA_I[132];

//**************R channle**********************//
assign sel_flag = (R_DATA_I[3:0] < HIGH_ID) ? 1'b0 : 1'b1;

vld_rdy_sel_1to2 u_vld_rdy_sel_1to2 (
.sel_flag   (sel_flag),
.vld_in     (R_VLD_I ),
.rdy_in     (R_RDY_I ),
.vld_out_0  (fifo_in_R_VLD_0 ),
.rdy_out_0  (fifo_in_R_RDY_0 ),
.vld_out_1  (fifo_in_R_VLD_1 ),
.rdy_out_1  (fifo_in_R_RDY_1 ));

vld_rdy_fifo # (
  .FIFO_WIDTH(DATA_WIDTH   ),
  .FIFO_DEPTH(FIFO_DEPTH_34)
)
vld_rdy_fifo_3_inst (
  .clk                  (clk         ),
  .rst_n                (rst_n       ),
  .fifo_i_vld           (fifo_in_R_VLD_0  ),
  .fifo_i_rdy           (fifo_in_R_RDY_0  ),
  .fifo_i_data          (R_DATA_I         ),
  .fifo_o_data          (R_DATA0     ),
  .fifo_o_vld           (R_VLD0      ),
  .fifo_o_rdy           (R_RDY0      )
);
vld_rdy_fifo # (
  .FIFO_WIDTH(DATA_WIDTH   ),
  .FIFO_DEPTH(FIFO_DEPTH_34)
)
vld_rdy_fifo_4_inst (
  .clk                  (clk             ),
  .rst_n                (rst_n           ),
  .fifo_i_vld           (fifo_in_R_VLD_1 ),
  .fifo_i_rdy           (fifo_in_R_RDY_1 ),
  .fifo_i_data          (R_DATA_I        ),
  .fifo_o_data          (R_DATA1         ),
  .fifo_o_vld           (R_VLD1          ),
  .fifo_o_rdy           (R_RDY1          )
);
    
endmodule
