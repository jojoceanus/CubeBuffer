module AXI_w_arb(
    input         clk,
    input         rst_n,
    input [31:0]  DB_AWADDR_a,
    input [7:0]   DB_AWLEN_a,
    input [3:0]   DB_AWID_a,
    input         DB_AWVALID_a,
    output        DB_AWREADY_a,

    input [127:0] DB_WDATA_a,
    input         DB_WVALID_a,
    output        DB_WREADY_a,
    
    input [31:0]  DB_AWADDR_b,
    input [7:0]   DB_AWLEN_b,
    input [3:0]   DB_AWID_b,
    input         DB_AWVALID_b,
    output        DB_AWREADY_b,

    input [127:0] DB_WDATA_b,
    input         DB_WVALID_b,
    output        DB_WREADY_b,

    //axi
    output [31:0]  DB_AWADDR,
    output [7:0]   DB_AWLEN,
    output         DB_AWVALID,
    input          DB_AWREADY,

    output [127:0] DB_WDATA,
    output         DB_WLAST,
    output         DB_WVALID,
    input          DB_WREADY
);

// Parameters
parameter  ID_bit = 0;
//ports
wire [39:0] data_outAXI;
assign DB_AWADDR = data_outAXI [39:8];
assign DB_AWLEN = data_outAXI[7:0];
wire [128:0] data_AXI;
assign DB_WLAST = data_AXI[128:128];
assign DB_WDATA = data_AXI[127:0];

W_Arb # (
    .ID_bit(ID_bit)
  )
W_Arb_inst (
    .clk(clk),
    .rst_n(rst_n),
    .vld0(DB_AWVALID_a),
    .rdy0(DB_AWREADY_a),
    .data0({DB_AWADDR_a,DB_AWLEN_a,DB_AWID_a}),
    .vld1(DB_AWVALID_b),
    .rdy1(DB_AWREADY_b),
    .data1({DB_AWADDR_b,DB_AWLEN_b,DB_AWID_b}),
    .vld_data0(DB_WVALID_a),
    .rdy_data0(DB_WREADY_a),
    .data0_data(DB_WDATA_a),
    .vld_data1(DB_WVALID_b),
    .rdy_data1(DB_WREADY_b),
    .data1_data(DB_WDATA_b),
    .vld_out(DB_AWVALID),
    .rdy_out(DB_AWREADY),
    .data_out(data_outAXI),
    .vld_wdata(DB_WVALID),
    .rdy_wdata(DB_WREADY),
    .rd_data(data_AXI)
  );


endmodule //db_w_abr
