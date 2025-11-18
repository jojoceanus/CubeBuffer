`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/20 17:44:08
// Design Name: KYC
// Module Name: physic_addr
// Project Name: DDR_ADDR_GEN
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:1.1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ddr_phy_addr(
    //system signal
    input          clk            ,
    input           rst_n          ,
        
    //Interfaces to decoder unit
    input[26:0]    featuremap_addr,
    input[12:0]    Maxheight      ,
    input[12:0]    TW             ,
    input[ 1:0]    DW             ,
    input          ddr_wr         ,
    input          gen_addr_start ,
    output reg     gen_addr_done  ,
        
    //Interfaces to physical address calculation unit
    input[12:0]    w_position     , 
    input[12:0]    h_position     , 
    input[12:0]    c_position     ,  
    input[ 7:0]    length         ,
    input          last_position_flag  ,
    input          logic_vld      ,
    output         logic_rdy      ,
    
    //Interfaces to memory Arbiter unit
    //AXI bus write address channel
    output[31:0]   DB_AWADDR      ,
    output[ 7:0]   DB_AWLEN       ,
    output reg     DB_AWVALID     ,
    input          DB_AWREADY     ,
                                      
    //AXI bus read address channel
    output[31:0]   DB_ARADDR      ,
    output[ 7:0]   DB_ARLEN       ,
    output reg     DB_ARVALID     ,
    input          DB_ARREADY          
);

/**********reg1a**************/
reg [31:0]       ddr_addr1a    ;
reg [12:0]       TW1a         ;
reg [12:0]       Maxheight1a  ;
reg [12:0]       w_temp1a     ;
reg [12:0]       c_temp1a     ;
reg [ 7:0]       length1a     ;
reg              last_pos_flag_1a       ;
/**********reg1**************/
reg [31:0]       ddr_addr1    ;
reg [12:0]       TW1          ;
reg [12:0]       Maxheight1   ;
reg [11:0]       w_height_mul1;
reg [12:0]       w_medi_mul1  ;
reg [12:0]       w_medi_mulx1 ;
reg [13:0]       w_low_mul1   ;
reg [12:0]       c_temp1      ;
reg [ 7:0]       length1      ;
reg              last_pos_flag_1        ;

/**********reg2a**************/
wire[31:0]       wtemp_Maxhei        ;
wire[15:0]       Maxhei_addr_sum     ;

reg [31:0]       ddr_addr2a          ;
reg [12:0]       c_temp2a            ;
reg [11:0]       height_mul2a        ;
reg [12:0]       medi_mul2a          ;
reg [12:0]       medi_mulx2a         ;
reg [13:0]       low_mul2a           ;
reg [15:0]       Maxhei_addr_low2a   ;
reg [15:0]       Maxhei_addr_height2a; 
reg              Maxhei_addr_low_ci2a;

reg [ 7:0]       length2a      ;
reg              last_pos_flag_2a        ;

/**********reg2**************/
//wire[31:0]       wtemp_Maxhei ;

reg [31:0]       ddr_addr2    ;
reg [12:0]       c_temp2      ;
reg [11:0]       height_mul1  ;
reg [12:0]       medi_mul1    ;
reg [12:0]       medi_mulx1   ;
reg [13:0]       low_mul1     ;
reg [ 7:0]       length2      ;
reg              last_pos_flag_2        ;
/**********reg3a**************/
wire [31:0]      TW_Maxhei    ;
reg  [31:0]      TW_Maxhei3a  ;
reg  [31:0]      ddr_addr3a   ;
reg  [ 7:0]      length3a     ;
reg              last_pos_flag_3a       ;

/**********reg3b**************/
reg  [15:0]      TW_addr_low3b  ;
reg              TW_addr_low_ci3b  ;
reg  [15:0]      TW_addr_height3b;
reg  [ 7:0]      length3b     ;
reg              last_pos_flag_3b       ;
wire [15:0]      TW_addr_sum  ;
/**********reg3**************/
reg [31:0]       r_phy_addr   ;
reg [ 7:0]       r_length     ;
//reg              gen_addr_done;
/**********vld-rdy***********/
reg              reg1a_vld;
wire             reg1a_rdy;
reg              reg1_vld ;
wire             reg1_rdy ;
reg              reg2_vld ;
wire             reg2_rdy ;
reg              reg2a_vld ;
wire             reg2a_rdy ;
reg              reg3a_vld;
wire             reg3a_rdy; 
reg              reg3b_vld;
wire             reg3b_rdy; 
reg              phy_addr_vld ;
wire             phy_addr_rdy ;

wire[ 1:0]       shift_dw     ;
reg [13:0]       h_pos        ;

assign shift_dw   = (DW== 2'b10) ? 2'b00  : (DW== 2'b01) ? 2'b01  : 2'b10  ;

always @ (*)
begin
    case(shift_dw)
        2'b00  : h_pos  = {h_position,1'b0} ;
        2'b01  : h_pos  = {1'd0,h_position}      ;
        2'b10  : h_pos  = {2'd0,h_position[12:1]};
        default: h_pos  = 14'd0;
    endcase
end

/********First stage pipeline************/
//pipeline register output
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        ddr_addr1a <= 'd0;
    else if(logic_vld  && logic_rdy)        
            ddr_addr1a <= {5'd0,featuremap_addr} + {18'd0,h_pos};
        else
            ddr_addr1a <= ddr_addr1a;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        TW1a <= 'd0;
    else if(logic_vld  && logic_rdy)        
            TW1a <= TW;
        else
            TW1a <= TW1a;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        Maxheight1a <= 'd0;
    else if(logic_vld  && logic_rdy)        
            Maxheight1a <= Maxheight;
        else
            Maxheight1a <= Maxheight1a;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        w_temp1a <= 'd0;
    else if(logic_vld  && logic_rdy)        
            w_temp1a <= w_position;
        else
            w_temp1a <= w_temp1a;
end


always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        c_temp1a <= 'd0;
    else if(logic_vld  && logic_rdy)        
            c_temp1a <= c_position;
        else
            c_temp1a <= c_temp1a;
end

//r1 burst length output
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        length1a <= 'd0;
    else if(logic_vld && logic_rdy)
            length1a <= length;
        else
             length1a <= length1a;
end

//Receive last_pos_flag_ signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_pos_flag_1a <= 1'd0;
    else if(logic_vld  && logic_rdy)        
             last_pos_flag_1a <= last_position_flag;
         else
             last_pos_flag_1a <= last_pos_flag_1a;
end

//Data output valid signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        reg1a_vld <= 1'b0;
    else if(logic_vld)
        reg1a_vld <= 1'b1;
     else if(reg1a_rdy)
          reg1a_vld <= 1'b0;
          else
          reg1a_vld <= reg1a_vld;
end

//Valid signal ready to receive the previous level of data
assign logic_rdy = reg1a_vld ? reg1a_rdy : 1'b1;

/********Second-stage stage pipeline************/
//pipeline register output
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        ddr_addr1 <= 'd0;
    else if(reg1a_vld  && reg1a_rdy)        
            ddr_addr1 <= ddr_addr1a;
        else
            ddr_addr1 <= ddr_addr1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        TW1 <= 'd0;
    else if(reg1a_vld  && reg1a_rdy)        
            TW1 <= TW1a;
        else
            TW1 <= TW1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        Maxheight1 <= 'd0;
    else if(reg1a_vld  && reg1a_rdy)        
            Maxheight1 <= Maxheight1a;
        else
            Maxheight1 <= Maxheight1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        w_height_mul1 <= 'd0;
    else if(reg1a_vld  && reg1a_rdy)        
            w_height_mul1 <= Maxheight1a[12:7] * w_temp1a[12:7];
        else
            w_height_mul1 <= w_height_mul1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        w_medi_mul1 <= 'd0;
    else if(reg1a_vld  && reg1a_rdy)        
            w_medi_mul1 <= Maxheight1a[12:7] * w_temp1a[6:0];
        else
            w_medi_mul1 <= w_medi_mul1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        w_medi_mulx1 <= 'd0;
    else if(reg1a_vld  && reg1a_rdy)        
            w_medi_mulx1 <= Maxheight1a[6:0] * w_temp1a[12:7];
        else
            w_medi_mulx1 <= w_medi_mulx1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        w_low_mul1 <= 'd0;
    else if(reg1a_vld  && reg1a_rdy)        
            w_low_mul1 <= Maxheight1a[6:0] * w_temp1a[6:0];
        else
            w_low_mul1 <= w_low_mul1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        c_temp1 <= 'd0;
    else if(reg1a_vld  && reg1a_rdy)        
            c_temp1 <= c_temp1a;
        else
            c_temp1 <= c_temp1;
end

//r1 burst length output
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        length1 <= 'd0;
    else if(reg1a_vld  && reg1a_rdy)
            length1 <= length1a;
        else
             length1 <= length1;
end

//Receive last_pos_flag_ signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_pos_flag_1 <= 1'd0;
    else if(reg1a_vld  && reg1a_rdy)        
             last_pos_flag_1 <= last_pos_flag_1a;
         else
             last_pos_flag_1 <= last_pos_flag_1;
end

//Data output valid signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        reg1_vld <= 1'b0;
    else if(reg1a_vld)
        reg1_vld <= 1'b1;
     else if(reg1_rdy)
          reg1_vld <= 1'b0;
          else
          reg1_vld <= reg1_vld;
end

//Valid signal ready to receive the previous level of data
assign reg1a_rdy = reg1_vld ? reg1_rdy : 1'b1;

/********Tertiary-stage stage pipeline************/
assign wtemp_Maxhei = {6'd0,w_height_mul1,w_low_mul1} + {12'd0,w_medi_mul1,7'd0} + {12'd0,w_medi_mulx1,7'd0};

//pipeline register output
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        {Maxhei_addr_low_ci2a,Maxhei_addr_low2a} <= 'd0;
    else if(reg1_vld  && reg1_rdy)        
            {Maxhei_addr_low_ci2a,Maxhei_addr_low2a} <= ddr_addr1[15:0] + wtemp_Maxhei[15:0];
        else
            {Maxhei_addr_low_ci2a,Maxhei_addr_low2a} <= {Maxhei_addr_low_ci2a,Maxhei_addr_low2a};
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        Maxhei_addr_height2a <= 'd0;
    else if(reg1_vld  && reg1_rdy)        
            Maxhei_addr_height2a <= ddr_addr1[31:16] + wtemp_Maxhei[31:16];
        else
            Maxhei_addr_height2a <= Maxhei_addr_height2a;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        c_temp2a <= 'd0;
    else if(reg1_vld  && reg1_rdy)        
            c_temp2a <= c_temp1;
        else
            c_temp2a <= c_temp2a;
end
//Splitting of Multiplication (TW * Maxheight)
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        height_mul2a <= 'd0;
    else if(reg1_vld  && reg1_rdy)        
            height_mul2a <= TW1[12:7] * Maxheight1[12:7];
        else
            height_mul2a <= height_mul2a;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        medi_mul2a <= 'd0;
    else if(reg1_vld  && reg1_rdy)        
            medi_mul2a <= TW1[12:7] * Maxheight1[6:0];
        else
            medi_mul2a <= medi_mul2a;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        medi_mulx2a <= 'd0;
    else if(reg1_vld  && reg1_rdy)        
            medi_mulx2a <= TW1[6:0] * Maxheight1[12:7];
        else
            medi_mulx2a <= medi_mulx2a;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        low_mul2a <= 'd0;
    else if(reg1_vld  && reg1_rdy)        
            low_mul2a <= TW1[6:0] * Maxheight1[6:0];
        else
            low_mul2a <= low_mul2a;
end
//r2 burst length output
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        length2a <= 'd0;
    else if(reg1_vld  && reg1_rdy)
            length2a <= length1;
        else
             length2a <= length2a;
end

//Receive last_pos_flag_ signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_pos_flag_2a <= 1'd0;
    else if(reg1_vld  && reg1_rdy)        
             last_pos_flag_2a <= last_pos_flag_1;
         else
             last_pos_flag_2a <= last_pos_flag_2a;
end

//Data output valid signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        reg2a_vld <= 1'b0;
    else if(reg1_vld)
        reg2a_vld <= 1'b1;
     else if(reg2a_rdy)
          reg2a_vld <= 1'b0;
          else
          reg2a_vld <= reg2a_vld;
end

//Valid signal ready to receive the previous level of data
assign reg1_rdy = reg2a_vld ? reg2a_rdy : 1'b1;

/********fourth-stage stage pipeline************/
//pipeline register output

assign Maxhei_addr_sum = {15'd0,Maxhei_addr_low_ci2a} + Maxhei_addr_height2a;

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        ddr_addr2 <= 'd0;
    else if(reg2a_vld  && reg2a_rdy)        
            ddr_addr2 <= {Maxhei_addr_sum,Maxhei_addr_low2a};
        else
            ddr_addr2 <= ddr_addr2;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        c_temp2 <= 'd0;
    else if(reg2a_vld  && reg2a_rdy)        
            c_temp2 <= c_temp2a;
        else
            c_temp2 <= c_temp2;
end
//Splitting of Multiplication (TW * Maxheight)
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        height_mul1 <= 'd0;
    else if(reg2a_vld  && reg2a_rdy)        
            height_mul1 <= height_mul2a;
        else
            height_mul1 <= height_mul1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        medi_mul1 <= 'd0;
    else if(reg2a_vld  && reg2a_rdy)        
            medi_mul1 <= medi_mul2a;
        else
            medi_mul1 <= medi_mul1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        medi_mulx1 <= 'd0;
    else if(reg2a_vld  && reg2a_rdy)        
            medi_mulx1 <= medi_mulx2a;
        else
            medi_mulx1 <= medi_mulx1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        low_mul1 <= 'd0;
    else if(reg2a_vld  && reg2a_rdy)        
            low_mul1 <= low_mul2a;
        else
            low_mul1 <= low_mul1;
end
//r2 burst length output
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        length2 <= 'd0;
    else if(reg2a_vld  && reg2a_rdy)
            length2 <= length2a;
        else
             length2 <= length2;
end

//Receive last_pos_flag_ signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_pos_flag_2 <= 1'd0;
    else if(reg2a_vld  && reg2a_rdy)        
             last_pos_flag_2 <= last_pos_flag_2a;
         else
             last_pos_flag_2 <= last_pos_flag_2;
end

//Data output valid signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        reg2_vld <= 1'b0;
    else if(reg2a_vld)
        reg2_vld <= 1'b1;
     else if(reg2_rdy)
          reg2_vld <= 1'b0;
          else
          reg2_vld <= reg2_vld;
end

//Valid signal ready to receive the previous level of data
assign reg2a_rdy = reg2_vld ? reg2_rdy : 1'b1;


/********fifth-stage pipeline************/
//pipeline register output

assign TW_Maxhei = {6'd0,height_mul1,low_mul1} + {12'd0,medi_mul1,7'd0} + {12'd0,medi_mulx1,7'd0};


always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        TW_Maxhei3a <= 'd0;
    else if(reg2_vld  && reg2_rdy)        
            TW_Maxhei3a <= c_temp2 * TW_Maxhei;
        else
            TW_Maxhei3a <= TW_Maxhei3a;
end


always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        ddr_addr3a <= 'd0;
    else if(reg2_vld  && reg2_rdy)        
            ddr_addr3a <= ddr_addr2;
        else
            ddr_addr3a <= ddr_addr3a;
end


always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        length3a <= 'd0;
    else if(reg2_vld  && reg2_rdy)
            length3a <= length2;
        else
             length3a <= length3a;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_pos_flag_3a <= 1'd0;
    else if(reg2_vld  && reg2_rdy)        
             last_pos_flag_3a <= last_pos_flag_2;
         else
             last_pos_flag_3a <= last_pos_flag_3a;
end

//Data output valid signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        reg3a_vld <= 1'b0;
    else if(reg2_vld)
        reg3a_vld <= 1'b1;
     else if(reg3a_rdy)
          reg3a_vld <= 1'b0;
          else
          reg3a_vld <= reg3a_vld;
end

//Valid signal ready to receive the previous level of data
assign reg2_rdy = reg3a_vld ? reg3a_rdy : 1'b1;

/********sixth-stage pipeline************/
//pipeline register output

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        {TW_addr_low_ci3b,TW_addr_low3b} <= 'd0;
    else if(reg3a_vld  && reg3a_rdy)        
            {TW_addr_low_ci3b,TW_addr_low3b} <= ddr_addr3a[15:0] + TW_Maxhei3a[15:0];
        else
            {TW_addr_low_ci3b,TW_addr_low3b} <= {TW_addr_low_ci3b,TW_addr_low3b};
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        TW_addr_height3b <= 'd0;
    else if(reg3a_vld  && reg3a_rdy)        
            TW_addr_height3b <= ddr_addr3a[31:16] + TW_Maxhei3a[31:16];
        else
            TW_addr_height3b <= TW_addr_height3b;
end

//r2 burst length output
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        length3b <= 'd0;
    else if(reg3a_vld  && reg3a_rdy)
            length3b <= length3a;
        else
             length3b <= length3b;
end

//Receive last_pos_flag_ signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        last_pos_flag_3b <= 1'd0;
    else if(reg3a_vld  && reg3a_rdy)        
        last_pos_flag_3b <= last_pos_flag_3a;
end

//Data output valid signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        reg3b_vld <= 1'b0;
    else if(reg3a_vld)
        reg3b_vld <= 1'b1;
     else if(reg3b_rdy)
          reg3b_vld <= 1'b0;
end

//Valid signal ready to receive the previous level of data
assign reg3a_rdy = reg3b_vld ? reg3b_rdy : 1'b1;


/********seventh-stage pipeline************/
//pipeline register output

assign TW_addr_sum = {15'd0,TW_addr_low_ci3b} + TW_addr_height3b;

reg last_pos_flag_out;
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        r_phy_addr        <= 'd0;
        r_length          <= 'd0;
        last_pos_flag_out <= 1'd0;
    end
    else if(reg3b_vld  && reg3b_rdy)        
    begin
        r_phy_addr        <= {TW_addr_sum,TW_addr_low3b};
        r_length          <= length3b;
        last_pos_flag_out <= last_pos_flag_3b;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        gen_addr_done <= 1'b0;
    else if(gen_addr_start)
        gen_addr_done <= 1'b0;
    else if(phy_addr_vld & phy_addr_rdy & last_pos_flag_out)
        gen_addr_done <= 1'b1;
end


//AXI bus write length channel

assign  DB_AWLEN = (ddr_wr)  ? r_length : 'd0;

//AXI bus read length channel

assign  DB_ARLEN = (!ddr_wr) ? r_length : 'd0;

//Data output valid signal
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        phy_addr_vld <= 1'b0;
    else if(reg3b_vld)
        phy_addr_vld <= 1'b1;
    else if(phy_addr_rdy)
        phy_addr_vld <= 1'b0;
    else
        phy_addr_vld <= phy_addr_vld;
end

//Valid signal ready to receive the previous level of data
assign reg3b_rdy = phy_addr_vld ? phy_addr_rdy : 1'b1;


//AXI bus write address valid channel
always @ (*)
begin
    if(ddr_wr)
        DB_AWVALID = phy_addr_vld;
    else
        DB_AWVALID = 1'b0;
end

assign phy_addr_rdy = (ddr_wr) ? DB_AWREADY : DB_ARREADY;

//AXI bus read address valid channel
always @ (*)
begin
    if(!ddr_wr)
        DB_ARVALID = phy_addr_vld;
    else
        DB_ARVALID = 1'b0;
end

//AXI bus write ddr addr channel

assign  DB_AWADDR = (ddr_wr)  ? r_phy_addr : 'd0;

//AXI bus read ddr addr channel

assign  DB_ARADDR = (!ddr_wr) ? r_phy_addr : 'd0;

endmodule

