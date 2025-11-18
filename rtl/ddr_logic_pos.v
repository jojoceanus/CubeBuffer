`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/20 17:19:08
// Design Name: 
// Module Name: logic_pos
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ddr_logic_pos(
    //system signal
    input               clk           ,
    input               rst_n         ,
        
    //Interfaces to decoder unit
    input[12:0]         W0            ,   //The WBlock coordinate of the upper-left point of the 3D data to be written/read out in the whole feature map.
    input[12:0]         H0            ,   //The HBlock coordinate
    input[12:0]         C0            ,   //The CBlock coordinate
    input[11:0]         WBlock             ,   //Data cache unit configuration WBlock size
    input[11:0]         HBlock             ,   //Data cache unit configuration HBlock size
    input[11:0]         CBlock             ,   //Data cache unit configuration CBlock size
    input[ 1:0]         DW            ,   //Data Bit Wide
    input[ 7:0]         burst_length  ,   //burst length
    input               gen_addr_start,   //DDR starts generating the start signal
        
    //Interfaces to physical address calculation unit
    output reg [12:0]   w_position    ,   //w-dimensional logical spatial location
    output reg [12:0]   h_position    ,   //h-dimensional logical spatial location
    output reg [12:0]   c_position    ,   //c-dimensional logical spatial location
    output reg [ 7:0]   length        ,   //burst length
    output reg          logic_vld     ,   
    output              last_position_flag ,   //ddr logic position calculation end signal
    
    input               logic_rdy        
    );

/****************reg****************/    
wire        w_last_pos_out_en   ;         //w-dimensional pulse signals
wire        h_last_pos_out_en   ;         //h-dimensional pulse signals
wire        c_last_pos_out_en   ;         //h-dimensional pulse signals
reg [19:0]  unaccessed_bits_num_in_h          ;     
reg [ 7:0]  data_num_in_128bit        ;         //128/DW
reg [15:0]  unaccessed_128bit_unit_num       ;         //(HBlock + H0 - h_position) / (128/DW)
wire[15:0]  data_num_in_one_burst;         //Number of data transferred in one burst

wire[15:0]  unaccessed_data_num_in_h      ;         //h dimensional residuals 

//dc debug

wire        logic_pos_out_en          ;

/************assign****************/
assign   logic_pos_out_en   = logic_vld & logic_rdy;  
 
//logic_vld    
always @ (posedge clk or negedge rst_n)    
begin
    if(!rst_n)
        logic_vld <= 1'b0;
    else if(gen_addr_start)  
        logic_vld <= 1'b1;
    else if(last_position_flag)
        logic_vld <= 1'b0;
    else
        logic_vld <= logic_vld;
end        

//h-dimension data left
assign unaccessed_data_num_in_h = HBlock + H0 - h_position;

//h-dimension data left in bits
always @(*)
begin
    case(DW)
        2'b00  :   unaccessed_bits_num_in_h = {unaccessed_data_num_in_h,2'b00  };  //HBlock + H0 - h_position * 4
        2'b01  :   unaccessed_bits_num_in_h = {unaccessed_data_num_in_h,3'b000 };  //HBlock + H0 - h_position * 8
        2'b10  :   unaccessed_bits_num_in_h = {unaccessed_data_num_in_h,4'b0000};  //HBlock + H0 - h_position * 16
        default:   unaccessed_bits_num_in_h =  unaccessed_data_num_in_h         ;
    endcase
end

//Conversion of multiplication calculations to shift calculations
always @(*)
begin
    case(DW)
        2'b00   : data_num_in_128bit = 8'd32;  //128/DW
        2'b01   : data_num_in_128bit = 8'd16;
        default : data_num_in_128bit = 8'd8 ;
    endcase
end
//Calculate the lens (HBlock + H0 - h_position) / (128/DW)
always @(*)
begin
    case(data_num_in_128bit)
        8'd8   : unaccessed_128bit_unit_num = (unaccessed_data_num_in_h +  16'd7) / 8;
        8'd16  : unaccessed_128bit_unit_num = (unaccessed_data_num_in_h + 16'd15) / 16;
        default: unaccessed_128bit_unit_num = (unaccessed_data_num_in_h + 16'd31) / 32;
    endcase
end

//Number of data transferred in one burst (128/DW * fact burst length)
assign data_num_in_one_burst = data_num_in_128bit * (burst_length + 8'd1);

//Burst length generation
always @ (*)
begin    
    if(unaccessed_data_num_in_h < data_num_in_one_burst)
        length = unaccessed_128bit_unit_num - 16'd1;
    else
        length = burst_length;
end    
    
//HBlock-dimension counter    
always @ (posedge clk or negedge rst_n)    
begin
    if(!rst_n)
    begin
        h_position <= 'd0;
        w_position <= 'd0;
        c_position <= 'd0;
    end
    else if (gen_addr_start)
    begin
        h_position <= H0;
        w_position <= W0;
        c_position <= C0;
    end
    else if(logic_pos_out_en)             
    begin
        h_position <=                h_last_pos_out_en ? H0 : (h_position + data_num_in_one_burst);
        w_position <= h_last_pos_out_en ? (w_last_pos_out_en ? W0 : (w_position +                13'd1)) : w_position;
        c_position <= w_last_pos_out_en ? (c_last_pos_out_en ? C0 : (c_position +                13'd1)) : c_position;
    end
end

assign h_last_pos_out_en  =  logic_pos_out_en && (unaccessed_data_num_in_h <= data_num_in_one_burst) ;
assign w_last_pos_out_en  = h_last_pos_out_en && (w_position == (W0 + WBlock - 1)) ;
assign c_last_pos_out_en  = w_last_pos_out_en && (c_position == (C0 + CBlock - 1)) ;

assign last_position_flag = c_last_pos_out_en;
    
endmodule

