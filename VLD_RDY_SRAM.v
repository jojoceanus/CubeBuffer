
module VLD_RDY_SRAM(
                     clk       ,
                     rst_n     ,
                    
                     cmd_vld   ,
                     cmd_rdy   ,
                     rw_flag   ,
                     in_addr   ,
                     in_data   ,
                    
                     out_vld  ,
                     out_rdy  ,
                     out_data       
);

parameter  DEPTH   = 3072;
parameter  A_WIDTH = 12  ;
parameter  D_WIDTH = 16  ;

input                      clk       ;
input                      rst_n     ;

input                      cmd_vld;
output                     cmd_rdy;
input                      rw_flag; //0 for read, 1 for write
input     [A_WIDTH-1:0]    in_addr;
input     [D_WIDTH-1:0]    in_data;

output                     out_vld ;
input                      out_rdy ;
output    [D_WIDTH-1:0]    out_data;


reg    [A_WIDTH:0]    w_addr;
reg    [A_WIDTH:0]    r_addr;

reg    [D_WIDTH-1:0]    data_reg_0        ;
reg    [D_WIDTH-1:0]    data_reg_1        ;
reg                     read_idx          ;
reg                     out_idx           ;
reg                     occupy_flag_0     ;
reg                     occupy_flag_1     ;
reg                     data_vld_0        ;
reg                     data_vld_1        ;

wire                    read_for_reg_0    ;
wire                    read_for_reg_1    ;
reg                     read_for_reg_0_dly;
reg                     read_for_reg_1_dly;

wire                    ram_wen;
wire   [A_WIDTH-1:0]    ram_wa;
wire   [D_WIDTH-1:0]    ram_wd;
wire   [A_WIDTH-1:0]    ram_ra;
wire   [D_WIDTH-1:0]    ram_rd;
reg                     cmd_rdy;
wire                    ram_ren;

//dcdebug

wire                    data_out_en;


//ram instance


parameter SRAM_AWIDTH = $clog2(DEPTH+1);

sdram_nohold #(
       .DATA_WIDTH(D_WIDTH  ),
       .DATA_DEPTH(DEPTH    ),
       .ADD_WIDTH (SRAM_AWIDTH        ))
u_sram (.CLK     (clk),
        .WEN     (ram_wen),
        .WA      (ram_wa[SRAM_AWIDTH-1:0] ),
        .WD      (ram_wd ),
        .REN     (ram_ren),
        .RA      (ram_ra[SRAM_AWIDTH-1:0] ),
        .RD      (ram_rd ));


assign ram_wen = cmd_vld & cmd_rdy & rw_flag;
assign ram_wa  = in_addr;
assign ram_wd  = in_data;

assign ram_ren = cmd_vld & cmd_rdy & (~rw_flag);
assign ram_ra  = in_addr;

//output data ctrl
assign data_out_en = out_vld & out_rdy;
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        read_idx <=  1'b0;
    end
    else if(ram_ren)
    begin
        read_idx <=  ~read_idx;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        out_idx <=  1'b0;
    end
    else if(data_out_en)
    begin
        out_idx <=  ~out_idx;
    end
end

assign read_for_reg_0 = ram_ren && ~read_idx;
assign read_for_reg_1 = ram_ren &&  read_idx;

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        read_for_reg_0_dly <=  1'b0;
        read_for_reg_1_dly <=  1'b0;
    end
    else
    begin
        read_for_reg_0_dly <=  read_for_reg_0;
        read_for_reg_1_dly <=  read_for_reg_1;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        occupy_flag_0 <=  1'b0;
    else if(read_for_reg_0)
        occupy_flag_0 <=  1'b1;
    else if(data_out_en && ~out_idx)
        occupy_flag_0 <=  1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        occupy_flag_1 <=  1'b0;
    else if(read_for_reg_1)
        occupy_flag_1 <=  1'b1;
    else if(data_out_en && out_idx)
        occupy_flag_1 <=  1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        data_vld_0 <=  1'b0;
    else if(read_for_reg_0_dly)
        data_vld_0 <=  1'b1;
    else if(data_out_en && ~out_idx)
        data_vld_0 <=  1'b0;
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        data_vld_1 <=  1'b0;
    else if(read_for_reg_1_dly)
        data_vld_1 <=  1'b1;
    else if(data_out_en && out_idx)
        data_vld_1 <=  1'b0;
end

always@(posedge clk)
begin
    if(read_for_reg_0_dly)
        data_reg_0 <=  ram_rd;
end

always@(posedge clk)
begin
    if(read_for_reg_1_dly)
        data_reg_1 <=  ram_rd;
end

assign out_vld  = data_vld_0 | data_vld_1;
assign out_data = out_idx ? data_reg_1 : data_reg_0;


//in_rdy
always@(*)
begin
    if(rw_flag) //write
        cmd_rdy = 1'b1;
    else
        cmd_rdy = (~occupy_flag_1 || ~occupy_flag_0 || out_rdy) ? 1'b1 : 1'b0;
end

endmodule
