module pos_ctrl#(
    parameter  POS_WIDTH = 12,
    parameter  STP_WIDTH =  7 
)
(
    input                              clk               ,                                   
    input                              rst_n             ,                                   
    input                              start             ,                                   
                                                                                           
    input                              access_en          , // one access over                 
    input             [          2:0]  access_order       , // access order                    
                                                                                           
    input             [POS_WIDTH-1:0]  w_last_legal_pos   , // last legal pos                     
    input             [POS_WIDTH-1:0]  h_last_legal_pos   , // last legal pos                     
    input             [POS_WIDTH-1:0]  c_last_legal_pos   , // last legal pos                     
                                                                                           
    input   signed    [POS_WIDTH-1:0]  w_init_pos         , // initial pos                     
    input   signed    [POS_WIDTH-1:0]  h_init_pos         , // initial pos                     
    input   signed    [POS_WIDTH-1:0]  c_init_pos         , // initial pos                     
                                                                                                      
    input             [STP_WIDTH-1:0]  w_step             , // move step between two access         
    input             [STP_WIDTH-1:0]  h_step             , // move step between two access         
    input             [STP_WIDTH-1:0]  c_step             , // move step between two access         
    
    output reg signed [POS_WIDTH-1:0]  w_pos              , // access position                   
    output reg signed [POS_WIDTH-1:0]  h_pos              , // access position              
    output reg signed [POS_WIDTH-1:0]  c_pos              , // access position                 
    output wire                          last_pos_flag        // cur is the last position  last_pos_flag
);

    localparam     ORDER_WHC   = 3'd0;
    localparam     ORDER_HWC   = 3'd1;
    localparam     ORDER_CWH   = 3'd2;
    localparam     ORDER_WCH   = 3'd3;
    localparam     ORDER_HCW   = 3'd6;
    localparam     ORDER_CHW   = 3'd7;

wire                         w_last    ; // last flag
wire                         h_last    ; // last flag
wire                         c_last    ; // last flag
wire signed [POS_WIDTH-1:0]  nxt_w_pos ; // next access position
wire signed [POS_WIDTH-1:0]  nxt_h_pos ; // next access position
wire signed [POS_WIDTH-1:0]  nxt_c_pos ; // next access position

reg                          update_pos_w_en; //Update Enable Signal
reg                          update_pos_h_en; //Update Enable Signal
reg                          update_pos_c_en; //Update Enable Signal

assign w_last = ($signed(w_pos + {{(POS_WIDTH-STP_WIDTH){1'b0}},w_step}) > $signed({1'b0,w_last_legal_pos})) ? 1'b1 : 1'b0;
assign h_last = ($signed(h_pos + {{(POS_WIDTH-STP_WIDTH){1'b0}},h_step}) > $signed({1'b0,h_last_legal_pos})) ? 1'b1 : 1'b0;
assign c_last = ($signed(c_pos + {{(POS_WIDTH-STP_WIDTH){1'b0}},c_step}) > $signed({1'b0,c_last_legal_pos})) ? 1'b1 : 1'b0;

assign last_pos_flag = w_last & h_last & c_last;

assign nxt_w_pos = w_last ? {w_init_pos[POS_WIDTH-1],w_init_pos} : (w_pos + w_step); 
assign nxt_h_pos = h_last ? {h_init_pos[POS_WIDTH-1],h_init_pos} : (h_pos + h_step); 
assign nxt_c_pos = c_last ? {c_init_pos[POS_WIDTH-1],c_init_pos} : (c_pos + c_step); 

always@(*)
begin
    case(access_order)
    ORDER_WHC: 
    begin
        update_pos_w_en = 1'b1;
        update_pos_h_en = w_last;
        update_pos_c_en = w_last & h_last;
    end
    ORDER_HWC:
    begin
        update_pos_h_en = 1'b1;
        update_pos_w_en = h_last;
        update_pos_c_en = w_last & h_last;        
    end
    ORDER_CWH:
    begin
        update_pos_c_en = 1'b1;
        update_pos_w_en = c_last;
        update_pos_h_en = c_last & w_last;
    end
    ORDER_WCH:
    begin
        update_pos_w_en = 1'b1;
        update_pos_c_en = w_last;
        update_pos_h_en = w_last & c_last;
    end
    ORDER_HCW:
    begin
        update_pos_h_en = 1'b1;
        update_pos_c_en = h_last;
        update_pos_w_en = h_last & c_last;
    end
    //ORDER_CHW:
    default:
    begin
        update_pos_c_en = 1'b1;
        update_pos_h_en = c_last;
        update_pos_w_en = c_last & h_last;
    end
    endcase
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        w_pos <= 12'b0;
        h_pos <= 12'b0;
        c_pos <= 12'b0;
    end
    else if(start)
    begin
        w_pos <= w_init_pos;
        h_pos <= h_init_pos;
        c_pos <= c_init_pos;
    end
    else if(access_en)
    begin
        w_pos <= update_pos_w_en ? nxt_w_pos : w_pos;
        h_pos <= update_pos_h_en ? nxt_h_pos : h_pos;
        c_pos <= update_pos_c_en ? nxt_c_pos : c_pos;
    end
end

endmodule







