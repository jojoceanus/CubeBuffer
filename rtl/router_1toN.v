module router_1toN#(
parameter PORT_NUM      =    10,
parameter ROUTER_INS_WIDTH = 64,
parameter DATA_WIDTH       = 2176 
)
(
    input                                         clk             ,
    input                                         rst_n           ,
                    
    input                                         router_ins_en   ,
    input          [ROUTER_INS_WIDTH-1:0]         router_ins_data ,

    input                                         input_vld       ,
    output  reg                                   input_rdy       ,
    input          [DATA_WIDTH-1:0]               input_data      ,

    output  reg    [PORT_NUM-1:0]              output_vld      ,
    input          [PORT_NUM-1:0]              output_rdy      ,
    output  wire   [PORT_NUM*DATA_WIDTH-1:0]   output_data     ,

    output                                     router_done      
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
wire   [3:0]    des_port_id;
wire   [31:0]   data_num   ;

assign des_port_id = ins_reg[21:18];
assign data_num    = ins_reg[53:22];

/***************** data counter *********************/
reg    [31:0]   data_cnt   ;
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        data_cnt <= 32'd0;
    else if((input_vld & input_rdy) && (data_cnt == data_num - 32'd1))
        data_cnt <= 32'd0;
    else if(input_vld & input_rdy)
        data_cnt <= data_cnt + 32'd1;
end

reg [3:0] done_cnt;
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        done_cnt <=  4'd0;
    else if(router_done)
        done_cnt <= done_cnt + 4'd1;
end

assign router_done = (input_vld & input_rdy) && (data_cnt == data_num - 32'd1);

/***************** data pass channel *********************/
always@(*)
begin
    if(cur_state == TRANS)
    begin
        case(des_port_id)
        4'd0   : 
        begin
            input_rdy   = output_rdy[0];
            output_vld  =  {9'b0,input_vld} ;
        end
        4'd1   : 
        begin
            input_rdy   = output_rdy[1];
            output_vld  =  {8'b0,input_vld,1'b0} ;
        end
        4'd2   : 
        begin
            input_rdy   = output_rdy[2];
            output_vld  =  {7'b0,input_vld,2'b0} ;
        end
        4'd3   : 
        begin
            input_rdy   = output_rdy[3];
            output_vld  =  {6'b0,input_vld,3'b0} ;
        end
        4'd4   : 
        begin
            input_rdy   = output_rdy[4];
            output_vld  =  {5'b0,input_vld,4'b0} ;
        end
        4'd5   : 
        begin
            input_rdy   = output_rdy[5];
            output_vld  =  {4'b0,input_vld,5'b0} ;
        end
        4'd6   : 
        begin
            input_rdy   = output_rdy[6];
            output_vld  =  {3'b0,input_vld,6'b0} ;
        end
        4'd7   : 
        begin
            input_rdy   = output_rdy[7];
            output_vld  =  {2'b0,input_vld,7'b0} ;
        end
        4'd8   : 
        begin
            input_rdy   = output_rdy[8];
            output_vld  =  {1'b0,input_vld,8'b0} ;
        end
        4'd9   : 
        begin
            input_rdy   = output_rdy[9];
            output_vld  = {input_vld,9'b0} ;
        end
        default: 
        begin
            input_rdy   = 1'b0;
            output_vld  = 10'b0;
        end
        endcase
    end
    else 
    begin
        input_rdy   = 1'b0;
        output_vld  = 10'b0;
    end
end

genvar j;
generate 
    for(j=0;j<PORT_NUM;j=j+1)
    begin:genblk0
        assign output_data[(j+1)*DATA_WIDTH-1:j*DATA_WIDTH] = input_data;
    end
endgenerate

endmodule
