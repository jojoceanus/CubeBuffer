module router_Nto1#(
parameter PORT_NUM         =    10,
parameter ROUTER_INS_WIDTH = 64,
parameter DATA_WIDTH       = 2176 
)
(
    input                                         clk             ,
    input                                         rst_n           ,
                    
    input                                         router_ins_en   ,
    input          [ROUTER_INS_WIDTH-1:0]         router_ins_data ,

    input          [PORT_NUM-1:0]                 input_vld       ,
    output  reg    [PORT_NUM-1:0]                 input_rdy       ,
    input          [PORT_NUM*DATA_WIDTH-1:0]      input_data      ,

    output  reg                                   output_vld      ,
    input                                         output_rdy      ,
    output  reg    [DATA_WIDTH-1:0]               output_data     ,

    output                                        router_done      
);

localparam IDLE  = 2'b00;
localparam TRANS = 2'b01;

reg    [1:0]    cur_state;
reg    [1:0]    nxt_state;

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        cur_state <=  IDLE;
    else
        cur_state <=  nxt_state;
end

always@(*)
begin
    case(cur_state)
        IDLE :  nxt_state = router_ins_en ? TRANS : cur_state;
        TRANS:  nxt_state = router_done   ? IDLE  : cur_state;
        default:nxt_state = IDLE;
    endcase
end

reg [ROUTER_INS_WIDTH-1:0] ins_reg;

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        ins_reg <= 'b0;
    else if(router_ins_en)
        ins_reg <= router_ins_data;
end

/***************** ins decode *********************/
wire   [3:0]    src_port_id;
wire   [31:0]   data_num   ;

assign src_port_id = ins_reg[17:14];
assign data_num    = ins_reg[53:22];

/***************** data counter *********************/
reg    [31:0]   data_cnt   ;
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        data_cnt <= 32'd0;
    else if(output_vld & output_rdy)
        data_cnt <= (data_cnt == data_num - 32'd1) ? 32'd0 : data_cnt + 32'd1;
end

reg [3:0] done_cnt;
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        done_cnt <=  4'd0;
    else if(router_done)
        done_cnt <= done_cnt + 4'd1;
end

assign router_done = (output_vld & output_rdy) && (data_cnt == data_num - 32'd1);

/***************** data pass channel *********************/
reg                         output_vld_sel ;
reg  [9:0]                  input_rdy_sel  ;

always@(*)
begin
    if(cur_state == TRANS)
    begin
        output_vld  = output_vld_sel; 
        input_rdy   = input_rdy_sel ;  
    end
    else 
    begin
        output_vld  = 1'b0  ; 
        input_rdy   = 10'b0 ;  
    end
end

always@(*)
begin
    case(src_port_id)
    4'd0   : 
    begin
        output_vld_sel  = input_vld[0];
        input_rdy_sel   = {9'b0,output_rdy} ;
    end
    4'd1   : 
    begin
        output_vld_sel  = input_vld[1];
        input_rdy_sel   = {8'b0,output_rdy,1'b0} ;
    end
    4'd2   : 
    begin
        output_vld_sel  = input_vld[2];
        input_rdy_sel   = {7'b0,output_rdy,2'b0} ;
    end
    4'd3   : 
    begin
        output_vld_sel  = input_vld[3];
        input_rdy_sel   = {6'b0,output_rdy,3'b0} ;
    end
    4'd4   : 
    begin
        output_vld_sel  = input_vld[4];
        input_rdy_sel   = {5'b0,output_rdy,4'b0} ;
    end
    4'd5   : 
    begin
        output_vld_sel  = input_vld[5];
        input_rdy_sel   = {4'b0,output_rdy,5'b0} ;
    end
    4'd6   : 
    begin
        output_vld_sel  = input_vld[6];
        input_rdy_sel   = {3'b0,output_rdy,6'b0} ;
    end
    4'd7   : 
    begin
        output_vld_sel  = input_vld[7];
        input_rdy_sel   = {2'b0,output_rdy,7'b0} ;
    end
    4'd8   : 
    begin
        output_vld_sel  = input_vld[8];
        input_rdy_sel   = {1'b0,output_rdy,8'b0} ;
    end
    4'd9   : 
    begin
        output_vld_sel  = input_vld[9];
        input_rdy_sel   = {output_rdy,9'b0} ;
    end
    default: 
    begin
        output_vld_sel  = 1'b0;
        input_rdy_sel   = 10'b0;
    end
    endcase
end

wire [DATA_WIDTH-1:0]  input_data_port0;
wire [DATA_WIDTH-1:0]  input_data_port1;
wire [DATA_WIDTH-1:0]  input_data_port2;
wire [DATA_WIDTH-1:0]  input_data_port3;
wire [DATA_WIDTH-1:0]  input_data_port4;
wire [DATA_WIDTH-1:0]  input_data_port5;
wire [DATA_WIDTH-1:0]  input_data_port6;
wire [DATA_WIDTH-1:0]  input_data_port7;
wire [DATA_WIDTH-1:0]  input_data_port8;
wire [DATA_WIDTH-1:0]  input_data_port9;

assign input_data_port0 = input_data[DATA_WIDTH* 1-1:DATA_WIDTH*0] ;
assign input_data_port1 = input_data[DATA_WIDTH* 2-1:DATA_WIDTH*1] ;
assign input_data_port2 = input_data[DATA_WIDTH* 3-1:DATA_WIDTH*2] ;
assign input_data_port3 = input_data[DATA_WIDTH* 4-1:DATA_WIDTH*3] ;
assign input_data_port4 = input_data[DATA_WIDTH* 5-1:DATA_WIDTH*4] ;
assign input_data_port5 = input_data[DATA_WIDTH* 6-1:DATA_WIDTH*5] ;
assign input_data_port6 = input_data[DATA_WIDTH* 7-1:DATA_WIDTH*6] ;
assign input_data_port7 = input_data[DATA_WIDTH* 8-1:DATA_WIDTH*7] ;
assign input_data_port8 = input_data[DATA_WIDTH* 9-1:DATA_WIDTH*8] ;
assign input_data_port9 = input_data[DATA_WIDTH*10-1:DATA_WIDTH*9] ;


//fix for big fan out
reg    [3:0]    src_port_id_00;
reg    [3:0]    src_port_id_01;
reg    [3:0]    src_port_id_02;
reg    [3:0]    src_port_id_03;
reg    [3:0]    src_port_id_04;
reg    [3:0]    src_port_id_05;
reg    [3:0]    src_port_id_06;
reg    [3:0]    src_port_id_07;
reg    [3:0]    src_port_id_08;
reg    [3:0]    src_port_id_09;
reg    [3:0]    src_port_id_10;
reg    [3:0]    src_port_id_11;
reg    [3:0]    src_port_id_12;
reg    [3:0]    src_port_id_13;
reg    [3:0]    src_port_id_14;
reg    [3:0]    src_port_id_15;
reg    [3:0]    src_port_id_16;
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        src_port_id_00 <= 4'd0;
        src_port_id_01 <= 4'd0;
        src_port_id_02 <= 4'd0;
        src_port_id_03 <= 4'd0;
        src_port_id_04 <= 4'd0;
        src_port_id_05 <= 4'd0;
        src_port_id_06 <= 4'd0;
        src_port_id_07 <= 4'd0;
        src_port_id_08 <= 4'd0;
        src_port_id_09 <= 4'd0;
        src_port_id_10 <= 4'd0;
        src_port_id_11 <= 4'd0;
        src_port_id_12 <= 4'd0;
        src_port_id_13 <= 4'd0;
        src_port_id_14 <= 4'd0;
        src_port_id_15 <= 4'd0;
        src_port_id_16 <= 4'd0;
    end
    else if(router_ins_en)
    begin
        src_port_id_00 <= router_ins_data[17:14];
        src_port_id_01 <= router_ins_data[17:14];
        src_port_id_02 <= router_ins_data[17:14];
        src_port_id_03 <= router_ins_data[17:14];
        src_port_id_04 <= router_ins_data[17:14];
        src_port_id_05 <= router_ins_data[17:14];
        src_port_id_06 <= router_ins_data[17:14];
        src_port_id_07 <= router_ins_data[17:14];
        src_port_id_08 <= router_ins_data[17:14];
        src_port_id_09 <= router_ins_data[17:14];
        src_port_id_10 <= router_ins_data[17:14];
        src_port_id_11 <= router_ins_data[17:14];
        src_port_id_12 <= router_ins_data[17:14];
        src_port_id_13 <= router_ins_data[17:14];
        src_port_id_14 <= router_ins_data[17:14];
        src_port_id_15 <= router_ins_data[17:14];
        src_port_id_16 <= router_ins_data[17:14];
    end
end

wire  [4*17-1:0] src_port_id_para;
assign src_port_id_para = {src_port_id_00,
                           src_port_id_01,
                           src_port_id_02,
                           src_port_id_03,
                           src_port_id_04,
                           src_port_id_05,
                           src_port_id_06,
                           src_port_id_07,
                           src_port_id_08,
                           src_port_id_09,
                           src_port_id_10,
                           src_port_id_11,
                           src_port_id_12,
                           src_port_id_13,
                           src_port_id_14,
                           src_port_id_15,
                           src_port_id_16};

genvar j;
generate 
    for(j=0;j<DATA_WIDTH/128;j=j+1)
    begin:genblk0
        always@(*)
        begin
            case(src_port_id_para[4*(j+1)-1:4*j])
            4'd0   :   output_data[128*(j+1)-1:128*j] = input_data_port0[128*(j+1)-1:128*j];
            4'd1   :   output_data[128*(j+1)-1:128*j] = input_data_port1[128*(j+1)-1:128*j];
            4'd2   :   output_data[128*(j+1)-1:128*j] = input_data_port2[128*(j+1)-1:128*j];
            4'd3   :   output_data[128*(j+1)-1:128*j] = input_data_port3[128*(j+1)-1:128*j];
            4'd4   :   output_data[128*(j+1)-1:128*j] = input_data_port4[128*(j+1)-1:128*j];
            4'd5   :   output_data[128*(j+1)-1:128*j] = input_data_port5[128*(j+1)-1:128*j];
            4'd6   :   output_data[128*(j+1)-1:128*j] = input_data_port6[128*(j+1)-1:128*j];
            4'd7   :   output_data[128*(j+1)-1:128*j] = input_data_port7[128*(j+1)-1:128*j];
            4'd8   :   output_data[128*(j+1)-1:128*j] = input_data_port8[128*(j+1)-1:128*j];
            default:   output_data[128*(j+1)-1:128*j] = input_data_port9[128*(j+1)-1:128*j];
            endcase
        end
    end
endgenerate



endmodule


