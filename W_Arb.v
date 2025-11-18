module W_Arb#(
    parameter  ID_bit = 0
)(
    input clk,
    input rst_n,
   
    input vld0,
    output rdy0,
    input [43:0] data0,
    input vld1,
    output rdy1,
    input [43:0] data1,

    input vld_data0,
    output rdy_data0,
    input [127:0] data0_data,
    input vld_data1,
    output rdy_data1,
    input [127:0] data1_data,

    output vld_out,
    input rdy_out,
    output [39:0] data_out,

    output vld_wdata,
    input  rdy_wdata,
    output [128:0]rd_data
);
    // Parameters
    localparam  FIFO_WIDTH_1 = 44;
    localparam  FIFO_DEPTH_1 = 2;

    localparam  FIFO_WIDTH_2 = 12;
    localparam  FIFO_DEPTH_2 = 8;

    localparam  FIFO_WIDTH_34 = 128;
    localparam  FIFO_DEPTH_34 = 4;

    //localparam  ID_bit = 0;
    //ports
    //wire vld0,rdy0,vld1,rdy1;
    //wire [43:0] data0,data1;
    wire vld_arb,rdy_arb;
    wire [43:0] data_arb;
    wire vld_fifo,rdy_fifo;
    wire [43:0] data_fifo;
    //wire vld_out,rdy_out;
    //wire [39:0] data_out;
    wire vld_id,rdy_id;
    wire [11:0] data_id;
    wire vld,rdy;
    wire [11:0] id;

    wire vld_data00,rdy_data00;
    wire [127:0] data_data00;
    wire vld_data11,rdy_data11;
    wire [127:0] data_data11;

    
    vld_rdy_arb_2to1_byturn #(.DATA_WIDTH(44)) 
    TtoOneMUX_inst (
      .clk(clk),
      .rst_n(rst_n),
      .vld_0(vld0),
      .vld_1(vld1),
      .data_0(data0),
      .data_1(data1),
      .selected_rdy(rdy_arb),
      .selected_data(data_arb),
      .selected_vld(vld_arb),
      .rdy_0(rdy0),
      .rdy_1(rdy1)
    );
    
    vld_rdy_fifo # (
      .FIFO_WIDTH(FIFO_WIDTH_1),
      .FIFO_DEPTH(FIFO_DEPTH_1)
    )
    vld_rdy_fifo_1_inst (
      .clk(clk),
      .rst_n(rst_n),
      .fifo_i_data(data_arb),
      .fifo_i_vld(vld_arb),
      .fifo_i_rdy(rdy_arb),
      .fifo_o_data(data_fifo),
      .fifo_o_vld(vld_fifo),
      .fifo_o_rdy(rdy_fifo)
    );
    
assign data_out = data_fifo[43:4];
assign data_id  = data_fifo[11:0];

    vld_rdy_sync_1to2  VLD_RDY_1to2_inst (
      .vld_in(vld_fifo),
      .rdy_in(rdy_fifo),
      .vld_out_0(vld_out),
      .rdy_out_0(rdy_out),
      .vld_out_1(vld_id),
      .rdy_out_1(rdy_id)
    );
    
    assign rdy = vld_wdata & rdy_wdata & rd_data[128:128];
    vld_rdy_fifo # (
        .FIFO_WIDTH(FIFO_WIDTH_2),
        .FIFO_DEPTH(FIFO_DEPTH_2)
      )
      vld_rdy_fifo_2_inst (
        .clk(clk),
        .rst_n(rst_n),
        .fifo_i_data(data_id),
        .fifo_i_vld(vld_id),
        .fifo_i_rdy(rdy_id),
        .fifo_o_data(id),
        .fifo_o_vld(vld),
        .fifo_o_rdy(rdy)
      );
   
      vld_rdy_fifo # (
        .FIFO_WIDTH(FIFO_WIDTH_34),
        .FIFO_DEPTH(FIFO_DEPTH_34)
      )
      vld_rdy_fifo_3_inst (
        .clk(clk),
        .rst_n(rst_n),
        .fifo_i_data(data0_data),
        .fifo_i_vld(vld_data0),
        .fifo_i_rdy(rdy_data0),
        .fifo_o_data(data_data00),
        .fifo_o_vld(vld_data00),
        .fifo_o_rdy(rdy_data00)
      );
 
      vld_rdy_fifo # (
        .FIFO_WIDTH(FIFO_WIDTH_34),
        .FIFO_DEPTH(FIFO_DEPTH_34)
      )
      vld_rdy_fifo_4_inst (
        .clk(clk),
        .rst_n(rst_n),
        .fifo_i_data(data1_data),
        .fifo_i_vld(vld_data1),
        .fifo_i_rdy(rdy_data1),
        .fifo_o_data(data_data11),
        .fifo_o_vld(vld_data11),
        .fifo_o_rdy(rdy_data11)
      );
    
      W_data_Two2One # (
      .ID_bit(ID_bit)
    )
    TtoOneMUXdata_inst (
      .clk(clk),
      .rst_n(rst_n),
      .vld_0(vld_data00),
      .vld_1(vld_data11),
      .data_out0(data_data00),
      .data_out1(data_data11),
      .select_input(id),
      .selected_rdy(rdy_wdata),
      .selected_data(rd_data),
      .selected_vld(vld_wdata),
      .rdy_0(rdy_data00),
      .rdy_1(rdy_data11),
      .vld_fifo(vld)
    );
endmodule
