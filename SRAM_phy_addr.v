module SRAM_phy_addr#(
parameter GROUP_NUM = 10,
parameter BANK_NUM  = 17 
)
(
    input               clk                 ,
    input               rst_n               ,

    input       [11:0]  WBlock              ,
    input       [11:0]  HBlock              ,
    input       [11:0]  CBlock              ,

    input       [1:0]   DW                  ,

    input               position_vld        ,
    output              position_rdy        ,

    input  [11:0] pos_w               ,
    input  [11:0] pos_h               ,
    input  [11:0] pos_c               ,

    input                 access_w            ,
    input       [6:0]     access_h            ,
    input       [3:0]     access_c            ,

    input  [5:0]  padding_num_w_in    ,
    input  [5:0]  padding_num_h_in    ,
    input  [5:0]  padding_num_c_in    ,

    input                 last_position_flag  ,

    output wire           phy_addr_vld        ,
    input                 phy_addr_rdy        ,

    output  [5:0]  padding_num_h_out  ,
    output  [5:0]  padding_num_c_out  ,

    output wire  [3:0]   group_id            ,
    output wire  [4:0]   bank_id             ,
    output wire  [3:0]   group_access_num    ,
    output wire  [4:0]   bank_access_num     ,
    output wire  [6:0]   access_num          ,
    output wire  [1:0]   bit_select          ,
    output wire  [11:0]  SRAM_addr           ,
    output wire  [11:0]  block_offset_o      ,
    output wire          last_phy_addr_flag

);

reg  reg1_vld;
reg  reg2_vld;
wire reg1_rdy;
wire reg2_rdy;

wire  [3:0]   comb_group_id            ;
wire  [3:0]   comb_group_access_num    ;
reg   [4:0]   comb_bank_access_num     ;
reg   [4:0]   comb_bank_id             ;
reg   [1:0]   comb_bit_select          ;

reg  [3:0]         reg1_group_id            ;
reg  [3:0]         reg1_group_access_num    ;
reg  [4:0]         reg1_bank_access_num     ;
reg  [4:0]         reg1_bank_id             ;
reg  [1:0]         reg1_bit_select          ;
reg                reg1_last_position_flag  ;
reg signed [11:0]  reg1_pos_c               ;
reg  [6:0]         reg1_access_h            ;

reg  [3:0]   reg2_group_id            ;
reg  [3:0]   reg2_group_access_num    ;
reg  [4:0]   reg2_bank_access_num     ;
reg  [4:0]   reg2_bank_id             ;
reg  [1:0]   reg2_bit_select          ;
reg          reg2_last_position_flag  ;
reg  [6:0]   reg2_access_h            ;

//*********** 1st comb logic************//
reg  [7:0]  comb_read_data_num_in_h;

assign comb_group_id         = pos_c % GROUP_NUM;
assign comb_group_access_num = access_c ;

always@(*)
begin
    if(DW == 2'b00)
    begin
        case(pos_h[1:0])    //pos_h%4
            2'b00:   comb_read_data_num_in_h = access_h + 7'd0;
            2'b01:   comb_read_data_num_in_h = access_h + 7'd1;
            2'b10:   comb_read_data_num_in_h = access_h + 7'd2;
            default: comb_read_data_num_in_h = access_h + 7'd3; //2'b11
        endcase
    end
    else if(DW == 2'b01)
    begin
        case(pos_h[0])  //pos_h%2
            1'b0:    comb_read_data_num_in_h = access_h + 7'd0;
            default: comb_read_data_num_in_h = access_h + 7'd1;
        endcase
    end
    else //DW==5'd16
    begin
        comb_read_data_num_in_h = access_h;
    end
end

always@(*)
begin
    if((access_w == 1'b0) || (padding_num_w_in != 6'd0))
        comb_bank_access_num = 5'd0;
    else if(access_h == 1'b0)
        comb_bank_access_num = 5'd0;
    else if(DW == 2'b00)
        comb_bank_access_num = (comb_read_data_num_in_h + 8'd3)/4;
    else if(DW == 2'b01)
        comb_bank_access_num = (comb_read_data_num_in_h + 8'd1)/2;
    else //DW==5'd16
        comb_bank_access_num =  comb_read_data_num_in_h[4:0]     ;
end

always@(*)
begin
    if(DW == 2'b00)
    begin
        comb_bank_id         = {2'd0,pos_h[11:2]} % BANK_NUM;
        comb_bit_select      = pos_h[1:0]; 
    end
    else if(DW == 2'b01)
    begin
        comb_bank_id         = {1'd0,pos_h[11:1]} % BANK_NUM;
        comb_bit_select      = {1'b0,pos_h[0]}; 
    end
    else //DW==5'd16
    begin
        comb_bank_id         =  pos_h % BANK_NUM;
        comb_bit_select      =  2'd0; 
    end
end

reg  [11:0] sram_addr_offset_one_column ;
reg  [11:0] sram_addr_offset_pos_h      ;
wire [11:0] sram_addr_offset_one_channle;
wire [11:0] sram_addr_offset_pos_w      ;
reg  [11:0] reg1_sram_addr_offset_one_column ;
reg  [11:0] reg1_sram_addr_offset_pos_h      ;
wire [11:0] reg1_sram_addr_offset_pos_c      ;
reg  [11:0] reg1_sram_addr_offset_one_channle;
reg  [11:0] reg1_sram_addr_offset_pos_w      ;
reg  [11:0] reg2_sram_addr_offset_one_column ;
reg  [11:0] reg2_sram_addr_offset_pos_h      ;
reg  [11:0] reg2_sram_addr_offset_one_channle;
reg  [11:0] reg2_sram_addr_offset_pos_w      ;
reg  [11:0] reg2_sram_addr_offset_pos_c      ;
reg  [ 5:0] reg1_padding_num_w_in;
reg  [ 5:0] reg1_padding_num_h_in;
reg  [ 5:0] reg1_padding_num_c_in;
reg  [ 5:0] reg2_padding_num_w_in;
reg  [ 5:0] reg2_padding_num_h_in;
reg  [ 5:0] reg2_padding_num_c_in;

always@(*)
begin
    if(DW == 2'b00)
    begin
        sram_addr_offset_one_column =(HBlock + (BANK_NUM*4)-1) / (BANK_NUM*4);
        sram_addr_offset_pos_h      = pos_h / (BANK_NUM*4);
    end
    else if(DW == 2'b01)
    begin
        sram_addr_offset_one_column =(HBlock + (BANK_NUM*2)-1) / (BANK_NUM*2);
        sram_addr_offset_pos_h      = pos_h / (BANK_NUM*2);
    end
    else
    begin
        sram_addr_offset_one_column =(HBlock + BANK_NUM-1) / BANK_NUM;
        sram_addr_offset_pos_h      = pos_h / BANK_NUM ;
    end
end

assign sram_addr_offset_one_channle = WBlock * sram_addr_offset_one_column;
assign sram_addr_offset_pos_w       = pos_w * sram_addr_offset_one_column;

//*********** 1st reg logic************//
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        reg1_vld <= 1'b0;
    else if(position_vld)
        reg1_vld <= 1'b1;
    else if(reg1_rdy)
        reg1_vld <= 1'b0;
end

assign position_rdy = reg1_vld ? reg1_rdy : 1'b1;

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        reg1_group_id                    <= 'b0;
        reg1_group_access_num            <= 'b0;
        reg1_bank_id                     <= 'b0;
        reg1_bank_access_num             <= 'b0;
        reg1_bit_select                  <= 'b0;
        reg1_sram_addr_offset_one_column <= 'b0;
        reg1_sram_addr_offset_one_channle<= 'b0;
        reg1_sram_addr_offset_pos_w      <= 'b0;
        reg1_sram_addr_offset_pos_h      <= 'b0;
        reg1_pos_c                       <= 'b0;
        reg1_last_position_flag          <= 'b0;
        reg1_access_h                    <= 'b0;
        reg1_padding_num_w_in            <= 'b0;
        reg1_padding_num_h_in            <= 'b0;
        reg1_padding_num_c_in            <= 'b0;
    end
    else if(position_vld & position_rdy)
    begin
        reg1_group_id                    <= comb_group_id               ;
        reg1_group_access_num            <= comb_group_access_num       ;
        reg1_bank_id                     <= comb_bank_id                ;
        reg1_bank_access_num             <= comb_bank_access_num        ;
        reg1_bit_select                  <= comb_bit_select             ;
        reg1_sram_addr_offset_one_column <= sram_addr_offset_one_column ;
        reg1_sram_addr_offset_one_channle<= sram_addr_offset_one_channle;
        reg1_sram_addr_offset_pos_w      <= sram_addr_offset_pos_w      ;
        reg1_sram_addr_offset_pos_h      <= sram_addr_offset_pos_h      ;
        reg1_pos_c                       <= pos_c                       ;
        reg1_last_position_flag          <= last_position_flag          ;
        reg1_access_h                    <= access_h                    ;
        reg1_padding_num_w_in            <= padding_num_w_in            ;
        reg1_padding_num_h_in            <= padding_num_h_in            ;
        reg1_padding_num_c_in            <= padding_num_c_in            ;
    end
end

//*********** 2st comb logic************//
assign reg1_sram_addr_offset_pos_c       = (reg1_pos_c/GROUP_NUM) * reg1_sram_addr_offset_one_channle;

//*********** 2st reg logic************//
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        reg2_vld <= 1'b0;
    else if(reg1_vld)
        reg2_vld <= 1'b1;
    else if(reg2_rdy)
        reg2_vld <= 1'b0;
end

assign reg1_rdy = reg2_vld ? reg2_rdy : 1'b1;

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        reg2_group_id                    <= 'b0;
        reg2_group_access_num            <= 'b0;
        reg2_bank_id                     <= 'b0;
        reg2_bank_access_num             <= 'b0;
        reg2_bit_select                  <= 'b0;
        reg2_sram_addr_offset_one_column <= 'b0;
        reg2_sram_addr_offset_one_channle<= 'b0;
        reg2_sram_addr_offset_pos_w      <= 'b0;
        reg2_sram_addr_offset_pos_h      <= 'b0;
        reg2_sram_addr_offset_pos_c      <= 'b0;
        reg2_last_position_flag          <= 'b0;
        reg2_access_h                    <= 'b0;
        reg2_padding_num_w_in            <= 'b0;
        reg2_padding_num_h_in            <= 'b0;
        reg2_padding_num_c_in            <= 'b0;
    end
    else if(reg1_vld & reg1_rdy)
    begin
        reg2_group_id                    <= reg1_group_id                    ;
        reg2_group_access_num            <= reg1_group_access_num            ;
        reg2_bank_id                     <= reg1_bank_id                     ;
        reg2_bank_access_num             <= reg1_bank_access_num             ;
        reg2_bit_select                  <= reg1_bit_select                  ;
        reg2_sram_addr_offset_one_column <= reg1_sram_addr_offset_one_column ;
        reg2_sram_addr_offset_one_channle<= reg1_sram_addr_offset_one_channle;
        reg2_sram_addr_offset_pos_w      <= reg1_sram_addr_offset_pos_w      ;
        reg2_sram_addr_offset_pos_h      <= reg1_sram_addr_offset_pos_h      ;
        reg2_sram_addr_offset_pos_c      <= reg1_sram_addr_offset_pos_c      ;
        reg2_last_position_flag          <= reg1_last_position_flag          ;
        reg2_access_h                    <= reg1_access_h                    ;
        reg2_padding_num_w_in            <= reg1_padding_num_w_in            ;
        reg2_padding_num_h_in            <= reg1_padding_num_h_in            ;
        reg2_padding_num_c_in            <= reg1_padding_num_c_in            ;
    end
end

//output
assign phy_addr_vld       = reg2_vld    ;
assign reg2_rdy           = phy_addr_rdy;

assign group_id           = reg2_group_id          ;
assign bank_id            = reg2_bank_id           ;
assign group_access_num   = reg2_group_access_num  ;
assign bank_access_num    = reg2_bank_access_num   ;
assign access_num         = reg2_access_h          ;
assign bit_select         = reg2_bit_select        ;
assign SRAM_addr          = reg2_sram_addr_offset_pos_c + reg2_sram_addr_offset_pos_w + reg2_sram_addr_offset_pos_h; 
assign last_phy_addr_flag = reg2_last_position_flag;
assign block_offset_o     = reg2_sram_addr_offset_one_channle    ;

assign padding_num_h_out = reg2_padding_num_h_in;
assign padding_num_c_out = reg2_padding_num_c_in;

reg [31:0]   phy_addr_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
      phy_addr_cnt <= 'd0;
    else if(last_phy_addr_flag)
           phy_addr_cnt <= 0;
    else if(phy_addr_vld && phy_addr_rdy)
           phy_addr_cnt <= phy_addr_cnt + 'd1;
end


endmodule
