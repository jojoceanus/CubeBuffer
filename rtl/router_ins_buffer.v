module router_ins_buffer #(
parameter ROUTER_INS_WIDTH = 64,
parameter ROUTER_NUM       = 5 
)
(
    input                               clk             ,
    input                               rst_n           ,
                    
    input                               router_ins_vld  ,
    output wire                         router_ins_rdy  ,
    input       [ROUTER_INS_WIDTH-1:0]  router_ins_data ,

    input       [ROUTER_NUM-1:0]        router_done     ,       
    
    output reg  [ROUTER_NUM-1:0]        router_ins_en   ,
    output reg  [ROUTER_INS_WIDTH-1:0]  router_ins_out     
);

/***************** ins buffer ctrl *********************/
localparam     IDLE   = 2'b00 ;    
localparam     SEARCH = 2'b01 ;    

reg    [4:0]    ins_write_ptr ;
reg    [3:0]    ins_search_ptr;
reg    [1:0]    cur_state;
reg    [1:0]    nxt_state;

reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer00;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer01;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer02;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer03;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer04;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer05;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer06;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer07;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer08;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer09;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer10;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer11;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer12;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer13;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer14;
reg    [ROUTER_INS_WIDTH-1:0]   ins_buffer15;

wire            ins_buffer_empty;
wire            ins_buffer_full ;
wire            ins_input_en    ;
wire            ins_issue_en    ;
wire            search_last_ins ;
wire            any_router_done ;
wire            ture_ins_flag   ;
wire   [31:0]   data_num   ;

assign data_num         = router_ins_data[53:22];
assign ture_ins_flag    = (data_num != 32'd0) ? 1'b1 : 1'b0;

assign ins_buffer_empty = (ins_write_ptr == 5'd0 ) ? 1'b1 : 1'b0; 
assign ins_buffer_full  = (ins_write_ptr == 5'd16) ? 1'b1 : 1'b0; 
assign router_ins_rdy   =  ins_buffer_full         ? 1'b0 : 1'b1;
assign ins_input_en     =  router_ins_vld & router_ins_rdy & ture_ins_flag;
assign search_last_ins  = ~ins_buffer_empty && (ins_search_ptr == ins_write_ptr-1);
assign any_router_done  = |router_done; 
assign ins_issue_en     = |router_ins_en; 

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
    IDLE:
    begin
        if(ins_input_en || (any_router_done && (~ins_buffer_empty)))
            nxt_state = SEARCH;
        else
            nxt_state = IDLE;
    end
    SEARCH:
    begin
        if(any_router_done && (~ins_buffer_empty))
            nxt_state = SEARCH;
        else if((ins_search_ptr == ins_write_ptr-1) && ~ins_input_en)
            nxt_state = IDLE;
        else 
            nxt_state = SEARCH;
    end
    default:
            nxt_state = IDLE;
    endcase
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        ins_search_ptr <=  5'd0;
    //if any router done, search again form the first ins
    else if(any_router_done)
        ins_search_ptr <=  5'd0;
    //search the last ins, not get new ins 
    else if((cur_state == SEARCH) && (ins_search_ptr == ins_write_ptr-1) && ~ins_input_en)
        ins_search_ptr <=  5'd0;  
    //search the last ins, issue the ins, get new ins 
    else if((cur_state == SEARCH) && (ins_search_ptr == ins_write_ptr-1) && ins_input_en && ins_issue_en)
        ins_search_ptr <=  ins_search_ptr;  
    //search the last ins, not issue the ins, get new ins 
    else if((cur_state == SEARCH) && (ins_search_ptr == ins_write_ptr-1) && ins_input_en && ~ins_issue_en)
        ins_search_ptr <=  ins_search_ptr + 5'd1;  
    //search the forward ins, issue the ins 
    else if((cur_state == SEARCH) && (ins_search_ptr < ins_write_ptr-1) &&  ins_issue_en)
        ins_search_ptr <=  ins_search_ptr;  
    //search the forward ins, not issue the ins 
    else if((cur_state == SEARCH) && (ins_search_ptr < ins_write_ptr-1) && ~ins_issue_en)
        ins_search_ptr <=  ins_search_ptr + 5'd1;  
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        ins_write_ptr <=  5'd0;
    else if(ins_input_en && ~ins_issue_en) 
        ins_write_ptr <=  ins_write_ptr + 5'd1;
    else if(ins_issue_en && ~ins_input_en) 
        ins_write_ptr <=  ins_write_ptr - 5'd1;
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        ins_buffer00 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer01 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer02 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer03 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer04 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer05 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer06 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer07 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer08 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer09 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer10 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer11 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer12 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer13 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer14 <=  {ROUTER_INS_WIDTH{1'd0}};
        ins_buffer15 <=  {ROUTER_INS_WIDTH{1'd0}};
    end
    else
    begin
        case({ins_input_en,ins_issue_en})
            2'b01:
            begin
                ins_buffer00 <=  (ins_search_ptr == 5'd0 ) ? ins_buffer01 : ins_buffer00;
                ins_buffer01 <=  (ins_search_ptr <= 5'd1 ) ? ins_buffer02 : ins_buffer01;
                ins_buffer02 <=  (ins_search_ptr <= 5'd2 ) ? ins_buffer03 : ins_buffer02;
                ins_buffer03 <=  (ins_search_ptr <= 5'd3 ) ? ins_buffer04 : ins_buffer03;
                ins_buffer04 <=  (ins_search_ptr <= 5'd4 ) ? ins_buffer05 : ins_buffer04;
                ins_buffer05 <=  (ins_search_ptr <= 5'd5 ) ? ins_buffer06 : ins_buffer05;
                ins_buffer06 <=  (ins_search_ptr <= 5'd6 ) ? ins_buffer07 : ins_buffer06;
                ins_buffer07 <=  (ins_search_ptr <= 5'd7 ) ? ins_buffer08 : ins_buffer07;
                ins_buffer08 <=  (ins_search_ptr <= 5'd8 ) ? ins_buffer09 : ins_buffer08;
                ins_buffer09 <=  (ins_search_ptr <= 5'd9 ) ? ins_buffer10 : ins_buffer09;
                ins_buffer10 <=  (ins_search_ptr <= 5'd10) ? ins_buffer11 : ins_buffer10;
                ins_buffer11 <=  (ins_search_ptr <= 5'd11) ? ins_buffer12 : ins_buffer11;
                ins_buffer12 <=  (ins_search_ptr <= 5'd12) ? ins_buffer13 : ins_buffer12;
                ins_buffer13 <=  (ins_search_ptr <= 5'd13) ? ins_buffer14 : ins_buffer13;
                ins_buffer14 <=  (ins_search_ptr <= 5'd14) ? ins_buffer15 : ins_buffer14;
                ins_buffer15 <=  ins_buffer15;
            end
            2'b10:
            begin
                ins_buffer00 <=  (ins_write_ptr == 5'd0 ) ? router_ins_data : ins_buffer00;
                ins_buffer01 <=  (ins_write_ptr == 5'd1 ) ? router_ins_data : ins_buffer01;
                ins_buffer02 <=  (ins_write_ptr == 5'd2 ) ? router_ins_data : ins_buffer02;
                ins_buffer03 <=  (ins_write_ptr == 5'd3 ) ? router_ins_data : ins_buffer03;
                ins_buffer04 <=  (ins_write_ptr == 5'd4 ) ? router_ins_data : ins_buffer04;
                ins_buffer05 <=  (ins_write_ptr == 5'd5 ) ? router_ins_data : ins_buffer05;
                ins_buffer06 <=  (ins_write_ptr == 5'd6 ) ? router_ins_data : ins_buffer06;
                ins_buffer07 <=  (ins_write_ptr == 5'd7 ) ? router_ins_data : ins_buffer07;
                ins_buffer08 <=  (ins_write_ptr == 5'd8 ) ? router_ins_data : ins_buffer08;
                ins_buffer09 <=  (ins_write_ptr == 5'd9 ) ? router_ins_data : ins_buffer09;
                ins_buffer10 <=  (ins_write_ptr == 5'd10) ? router_ins_data : ins_buffer10;
                ins_buffer11 <=  (ins_write_ptr == 5'd11) ? router_ins_data : ins_buffer11;
                ins_buffer12 <=  (ins_write_ptr == 5'd12) ? router_ins_data : ins_buffer12;
                ins_buffer13 <=  (ins_write_ptr == 5'd13) ? router_ins_data : ins_buffer13;
                ins_buffer14 <=  (ins_write_ptr == 5'd14) ? router_ins_data : ins_buffer14;
                ins_buffer15 <=  (ins_write_ptr == 5'd15) ? router_ins_data : ins_buffer15;
            end
            2'b11:
            begin
                ins_buffer00 <=  ((ins_write_ptr-5'd1) == 5'd0 ) ? router_ins_data : ((ins_search_ptr == 5'd0 ) ? ins_buffer01 : ins_buffer00);
                ins_buffer01 <=  ((ins_write_ptr-5'd1) == 5'd1 ) ? router_ins_data : ((ins_search_ptr <= 5'd1 ) ? ins_buffer02 : ins_buffer01);
                ins_buffer02 <=  ((ins_write_ptr-5'd1) == 5'd2 ) ? router_ins_data : ((ins_search_ptr <= 5'd2 ) ? ins_buffer03 : ins_buffer02);
                ins_buffer03 <=  ((ins_write_ptr-5'd1) == 5'd3 ) ? router_ins_data : ((ins_search_ptr <= 5'd3 ) ? ins_buffer04 : ins_buffer03);
                ins_buffer04 <=  ((ins_write_ptr-5'd1) == 5'd4 ) ? router_ins_data : ((ins_search_ptr <= 5'd4 ) ? ins_buffer05 : ins_buffer04);
                ins_buffer05 <=  ((ins_write_ptr-5'd1) == 5'd5 ) ? router_ins_data : ((ins_search_ptr <= 5'd5 ) ? ins_buffer06 : ins_buffer05);
                ins_buffer06 <=  ((ins_write_ptr-5'd1) == 5'd6 ) ? router_ins_data : ((ins_search_ptr <= 5'd6 ) ? ins_buffer07 : ins_buffer06);
                ins_buffer07 <=  ((ins_write_ptr-5'd1) == 5'd7 ) ? router_ins_data : ((ins_search_ptr <= 5'd7 ) ? ins_buffer08 : ins_buffer07);
                ins_buffer08 <=  ((ins_write_ptr-5'd1) == 5'd8 ) ? router_ins_data : ((ins_search_ptr <= 5'd8 ) ? ins_buffer09 : ins_buffer08);
                ins_buffer09 <=  ((ins_write_ptr-5'd1) == 5'd9 ) ? router_ins_data : ((ins_search_ptr <= 5'd9 ) ? ins_buffer10 : ins_buffer09);
                ins_buffer10 <=  ((ins_write_ptr-5'd1) == 5'd10) ? router_ins_data : ((ins_search_ptr <= 5'd10) ? ins_buffer11 : ins_buffer10);
                ins_buffer11 <=  ((ins_write_ptr-5'd1) == 5'd11) ? router_ins_data : ((ins_search_ptr <= 5'd11) ? ins_buffer12 : ins_buffer11);
                ins_buffer12 <=  ((ins_write_ptr-5'd1) == 5'd12) ? router_ins_data : ((ins_search_ptr <= 5'd12) ? ins_buffer13 : ins_buffer12);
                ins_buffer13 <=  ((ins_write_ptr-5'd1) == 5'd13) ? router_ins_data : ((ins_search_ptr <= 5'd13) ? ins_buffer14 : ins_buffer13);
                ins_buffer14 <=  ((ins_write_ptr-5'd1) == 5'd14) ? router_ins_data : ((ins_search_ptr <= 5'd14) ? ins_buffer15 : ins_buffer14);
                ins_buffer15 <=  ((ins_write_ptr-5'd1) == 5'd15) ? router_ins_data : ins_buffer15;
            end
            default:
            begin
                ins_buffer00 <=  ins_buffer00;
                ins_buffer01 <=  ins_buffer01;
                ins_buffer02 <=  ins_buffer02;
                ins_buffer03 <=  ins_buffer03;
                ins_buffer04 <=  ins_buffer04;
                ins_buffer05 <=  ins_buffer05;
                ins_buffer06 <=  ins_buffer06;
                ins_buffer07 <=  ins_buffer07;
                ins_buffer08 <=  ins_buffer08;
                ins_buffer09 <=  ins_buffer09;
                ins_buffer10 <=  ins_buffer10;
                ins_buffer11 <=  ins_buffer11;
                ins_buffer12 <=  ins_buffer12;
                ins_buffer13 <=  ins_buffer13;
                ins_buffer14 <=  ins_buffer14;
                ins_buffer15 <=  ins_buffer15;
            end
        endcase
    end
end

always@(*)
begin
    case(ins_search_ptr)
        4'h0:     router_ins_out = ins_buffer00;
        4'h1:     router_ins_out = ins_buffer01;
        4'h2:     router_ins_out = ins_buffer02;
        4'h3:     router_ins_out = ins_buffer03;
        4'h4:     router_ins_out = ins_buffer04;
        4'h5:     router_ins_out = ins_buffer05;
        4'h6:     router_ins_out = ins_buffer06;
        4'h7:     router_ins_out = ins_buffer07;
        4'h8:     router_ins_out = ins_buffer08;
        4'h9:     router_ins_out = ins_buffer09;
        4'ha:     router_ins_out = ins_buffer10;
        4'hb:     router_ins_out = ins_buffer11;
        4'hc:     router_ins_out = ins_buffer12;
        4'hd:     router_ins_out = ins_buffer13;
        4'he:     router_ins_out = ins_buffer14;
        default:  router_ins_out = ins_buffer15;
    endcase
end

/***************** port with 0/1/2 router state *********************/
//The busy signal of the router
reg router0_oport_cur_busy;
reg router1_oport_cur_busy;
reg router2_oport_cur_busy;

reg router0_oport_pre_busy;
reg router1_oport_pre_busy;
reg router2_oport_pre_busy;

//The busy signal of the pe_indata buffer2router0
reg buf00_oport2router0_cur_busy   ;
reg buf01_oport2router0_cur_busy   ;
reg buf04_oport2router0_pe_cur_busy;
reg buf05_oport2router0_pe_cur_busy;
reg buf08_oport2router0_cur_busy   ;
reg buf09_oport2router0_cur_busy   ;

//The busy signal of the pe_weight buffer2router1
reg buf02_oport2router1_cur_busy;
reg buf03_oport2router1_cur_busy;

//The busy signal of the fe_indata buffer2router2
reg buf04_oport2router2_fe_cur_busy;
reg buf05_oport2router2_fe_cur_busy;
reg buf06_oport2router2_cur_busy   ;
reg buf07_oport2router2_cur_busy   ;

//The busy signal of the pe_indata buffer2router0
reg buf00_oport2router0_pre_busy   ;
reg buf01_oport2router0_pre_busy   ;
reg buf04_oport2router0_pe_pre_busy;
reg buf05_oport2router0_pe_pre_busy;
reg buf08_oport2router0_pre_busy   ;
reg buf09_oport2router0_pre_busy   ;

//The busy signal of the pe_weight buffer2router1
reg buf02_oport2router1_pre_busy;
reg buf03_oport2router1_pre_busy;

//The busy signal of the fe_indata buffer2router2
reg buf04_oport2router2_fe_pre_busy;
reg buf05_oport2router2_fe_pre_busy;
reg buf06_oport2router2_pre_busy   ;
reg buf07_oport2router2_pre_busy   ;

/***************** port with 3/4 router state *********************/
reg router3_iport_cur_busy;
reg router4_iport_cur_busy;
reg router3_iport_pre_busy;
reg router4_iport_pre_busy;

//The busy signal of the pe_outdata router32buffer
reg router3_oport2buf04_cur_busy;
reg router3_oport2buf05_cur_busy;
reg router3_oport2buf06_cur_busy;
reg router3_oport2buf07_cur_busy;

//The busy signal of the fe_outdata router42buffer
reg router4_oport2buf00_cur_busy;
reg router4_oport2buf01_cur_busy;
reg router4_oport2buf08_cur_busy;
reg router4_oport2buf09_cur_busy;

//The busy signal of the pe_outdata router32buffer
reg router3_oport2buf04_pre_busy;
reg router3_oport2buf05_pre_busy;
reg router3_oport2buf06_pre_busy;
reg router3_oport2buf07_pre_busy;

//The busy signal of the fe_outdata router42buffer
reg router4_oport2buf00_pre_busy;
reg router4_oport2buf01_pre_busy;
reg router4_oport2buf08_pre_busy;
reg router4_oport2buf09_pre_busy;



wire       buf00_cur_busy;
wire       buf01_cur_busy;
wire       buf02_cur_busy;
wire       buf03_cur_busy;
wire       buf04_cur_busy;
wire       buf05_cur_busy;
wire       buf06_cur_busy;
wire       buf07_cur_busy;
wire       buf08_cur_busy;
wire       buf09_cur_busy;

wire       buf00_pre_busy;
wire       buf01_pre_busy;
wire       buf02_pre_busy;
wire       buf03_pre_busy;
wire       buf04_pre_busy;
wire       buf05_pre_busy;
wire       buf06_pre_busy;
wire       buf07_pre_busy;
wire       buf08_pre_busy;
wire       buf09_pre_busy;

wire       buf00_busy;
wire       buf01_busy;
wire       buf02_busy;
wire       buf03_busy;
wire       buf04_busy;
wire       buf05_busy;
wire       buf06_busy;
wire       buf07_busy;
wire       buf08_busy;
wire       buf09_busy;

wire       pe_input_busy ;
wire       pe_weight_busy;
wire       fe_input_busy ;
wire       pe_output_busy;
wire       fe_output_busy;
/***************** ins decode *********************/
wire   [3:0]    src_port_id;
wire   [3:0]    des_port_id;

assign src_port_id = router_ins_out[17:14];
assign des_port_id = router_ins_out[21:18];

/***************** busy state for router 0/1/2 *********************/
//buffer-> PE_input
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        buf00_oport2router0_cur_busy    <= 1'b0;
        buf01_oport2router0_cur_busy    <= 1'b0;
        buf04_oport2router0_pe_cur_busy <= 1'b0;
        buf05_oport2router0_pe_cur_busy <= 1'b0;
        buf08_oport2router0_cur_busy    <= 1'b0;
        buf09_oport2router0_cur_busy    <= 1'b0;
        router0_oport_cur_busy          <= 1'b0;
    end
    else if(ins_issue_en && (des_port_id == 4'd10))  //PE_input：10
    begin
        buf00_oport2router0_cur_busy    <= (src_port_id == 4'd0) ? 1'b1 : buf00_oport2router0_cur_busy   ;
        buf01_oport2router0_cur_busy    <= (src_port_id == 4'd1) ? 1'b1 : buf01_oport2router0_cur_busy   ;
        buf04_oport2router0_pe_cur_busy <= (src_port_id == 4'd4) ? 1'b1 : buf04_oport2router0_pe_cur_busy;
        buf05_oport2router0_pe_cur_busy <= (src_port_id == 4'd5) ? 1'b1 : buf05_oport2router0_pe_cur_busy;
        buf08_oport2router0_cur_busy    <= (src_port_id == 4'd8) ? 1'b1 : buf08_oport2router0_cur_busy   ;
        buf09_oport2router0_cur_busy    <= (src_port_id == 4'd9) ? 1'b1 : buf09_oport2router0_cur_busy   ;
        router0_oport_cur_busy          <= 1'b1;
         
    end
    else if(router_done[0])
    begin
        buf00_oport2router0_cur_busy    <= 1'b0;
        buf01_oport2router0_cur_busy    <= 1'b0;
        buf04_oport2router0_pe_cur_busy <= 1'b0;
        buf05_oport2router0_pe_cur_busy <= 1'b0;
        buf08_oport2router0_cur_busy    <= 1'b0;
        buf09_oport2router0_cur_busy    <= 1'b0;
        router0_oport_cur_busy          <= 1'b0;
    end
end

//buffer -> PE_weight 
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        buf02_oport2router1_cur_busy <= 1'b0;    
        buf03_oport2router1_cur_busy <= 1'b0;
        router1_oport_cur_busy       <= 1'b0;
    end
    else if(ins_issue_en && (des_port_id == 4'd11))  ////PE_weight：11
    begin
        buf02_oport2router1_cur_busy <= (src_port_id == 4'd2) ? 1'b1 : buf02_oport2router1_cur_busy;
        buf03_oport2router1_cur_busy <= (src_port_id == 4'd3) ? 1'b1 : buf03_oport2router1_cur_busy;
        router1_oport_cur_busy       <= 1'b1      ;
    end
    else if(router_done[1])
    begin
        buf02_oport2router1_cur_busy <= 1'b0;
        buf03_oport2router1_cur_busy <= 1'b0;
        router1_oport_cur_busy       <= 1'b0;
    end
end
//buffer -> FE_input
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        buf04_oport2router2_fe_cur_busy <= 1'b0;
        buf05_oport2router2_fe_cur_busy <= 1'b0;
        buf06_oport2router2_cur_busy    <= 1'b0;
        buf07_oport2router2_cur_busy    <= 1'b0;
        router2_oport_cur_busy          <= 1'b0;
    end
    else if(ins_issue_en && (des_port_id == 4'd12))  //FE:12
    begin
        buf04_oport2router2_fe_cur_busy  <= (src_port_id == 4'd4) ? 1'b1 : buf04_oport2router2_fe_cur_busy ;
        buf05_oport2router2_fe_cur_busy  <= (src_port_id == 4'd5) ? 1'b1 : buf05_oport2router2_fe_cur_busy ;
        buf06_oport2router2_cur_busy     <= (src_port_id == 4'd6) ? 1'b1 : buf06_oport2router2_cur_busy    ;
        buf07_oport2router2_cur_busy     <= (src_port_id == 4'd7) ? 1'b1 : buf07_oport2router2_cur_busy    ;
        router2_oport_cur_busy           <= 1'b1;
    end
    else if(router_done[2])
    begin
        buf04_oport2router2_fe_cur_busy <= 1'b0;
        buf05_oport2router2_fe_cur_busy <= 1'b0;
        buf06_oport2router2_cur_busy    <= 1'b0;
        buf07_oport2router2_cur_busy    <= 1'b0;
        router2_oport_cur_busy          <= 1'b0;
    end
end


/***************** future busy state for router 0/1/2 *********************/

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        buf00_oport2router0_pre_busy    <= 1'b0;
        buf01_oport2router0_pre_busy    <= 1'b0;
        buf04_oport2router0_pe_pre_busy <= 1'b0;
        buf05_oport2router0_pe_pre_busy <= 1'b0;
        buf08_oport2router0_pre_busy    <= 1'b0;
        buf09_oport2router0_pre_busy    <= 1'b0;
        router0_oport_pre_busy          <= 1'b0;
    end
    else if(any_router_done)
    begin
        buf00_oport2router0_pre_busy    <= 1'b0;
        buf01_oport2router0_pre_busy    <= 1'b0;
        buf04_oport2router0_pe_pre_busy <= 1'b0;
        buf05_oport2router0_pe_pre_busy <= 1'b0;
        buf08_oport2router0_pre_busy    <= 1'b0;
        buf09_oport2router0_pre_busy    <= 1'b0;
        router0_oport_pre_busy          <= 1'b0;
    end
    else if((ins_search_ptr == ins_write_ptr-1) && ~ins_input_en)
    begin
        buf00_oport2router0_pre_busy    <= 1'b0;
        buf01_oport2router0_pre_busy    <= 1'b0;
        buf04_oport2router0_pe_pre_busy <= 1'b0;
        buf05_oport2router0_pe_pre_busy <= 1'b0;
        buf08_oport2router0_pre_busy    <= 1'b0;
        buf09_oport2router0_pre_busy    <= 1'b0;
        router0_oport_pre_busy          <= 1'b0;
    end
    else if((cur_state == SEARCH) && (des_port_id == 4'd10))
    begin
        buf00_oport2router0_pre_busy    <= (src_port_id == 4'd0) ? 1'b1 : buf00_oport2router0_pre_busy   ;
        buf01_oport2router0_pre_busy    <= (src_port_id == 4'd1) ? 1'b1 : buf01_oport2router0_pre_busy   ;
        buf04_oport2router0_pe_pre_busy <= (src_port_id == 4'd4) ? 1'b1 : buf04_oport2router0_pe_pre_busy;
        buf05_oport2router0_pe_pre_busy <= (src_port_id == 4'd5) ? 1'b1 : buf05_oport2router0_pe_pre_busy;
        buf08_oport2router0_pre_busy    <= (src_port_id == 4'd8) ? 1'b1 : buf08_oport2router0_pre_busy   ;
        buf09_oport2router0_pre_busy    <= (src_port_id == 4'd9) ? 1'b1 : buf09_oport2router0_pre_busy   ;
        router0_oport_pre_busy          <= 1'b1;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        buf02_oport2router1_pre_busy <= 1'b0;
        buf03_oport2router1_pre_busy <= 1'b0;
        router1_oport_pre_busy       <= 1'b0;
    end
    else if(any_router_done)
    begin
        buf02_oport2router1_pre_busy <= 1'b0;
        buf03_oport2router1_pre_busy <= 1'b0;
        router1_oport_pre_busy       <= 1'b0;
    end
    else if((ins_search_ptr == ins_write_ptr-1) && ~ins_input_en)
    begin
        buf02_oport2router1_pre_busy <= 1'b0;
        buf03_oport2router1_pre_busy <= 1'b0;
        router1_oport_pre_busy       <= 1'b0;
    end
    else if((cur_state == SEARCH) && (des_port_id == 4'd11))
    begin
        buf02_oport2router1_pre_busy <= (src_port_id == 4'd2) ? 1'b1 : buf02_oport2router1_pre_busy;
        buf03_oport2router1_pre_busy <= (src_port_id == 4'd3) ? 1'b1 : buf03_oport2router1_pre_busy;
        router1_oport_pre_busy       <= 1'b1;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        buf04_oport2router2_fe_pre_busy  <= 1'b0;
        buf05_oport2router2_fe_pre_busy  <= 1'b0;
        buf06_oport2router2_pre_busy     <= 1'b0;
        buf07_oport2router2_pre_busy     <= 1'b0;
        router2_oport_pre_busy           <= 1'b0;
    end
    else if(any_router_done)
    begin
        buf04_oport2router2_fe_pre_busy  <= 1'b0;
        buf05_oport2router2_fe_pre_busy  <= 1'b0;
        buf06_oport2router2_pre_busy     <= 1'b0;
        buf07_oport2router2_pre_busy     <= 1'b0;
        router2_oport_pre_busy           <= 1'b0;
    end
    else if((ins_search_ptr == ins_write_ptr-1) && ~ins_input_en)
    begin
        buf04_oport2router2_fe_pre_busy  <= 1'b0;
        buf05_oport2router2_fe_pre_busy  <= 1'b0;
        buf06_oport2router2_pre_busy     <= 1'b0;
        buf07_oport2router2_pre_busy     <= 1'b0;
        router2_oport_pre_busy           <= 1'b0;
    end
    else if((cur_state == SEARCH) && (des_port_id == 4'd12))
    begin
        buf04_oport2router2_fe_pre_busy  <= (src_port_id == 4'd4) ? 1'b1 : buf04_oport2router2_fe_pre_busy ;
        buf05_oport2router2_fe_pre_busy  <= (src_port_id == 4'd5) ? 1'b1 : buf05_oport2router2_fe_pre_busy ;
        buf06_oport2router2_pre_busy     <= (src_port_id == 4'd6) ? 1'b1 : buf06_oport2router2_pre_busy    ;
        buf07_oport2router2_pre_busy     <= (src_port_id == 4'd7) ? 1'b1 : buf07_oport2router2_pre_busy    ;
        router2_oport_pre_busy           <= 1'b1;
    end
end


/***************** busy state for router 3/4 *********************/
////PE_output -> buffer
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        router3_oport2buf04_cur_busy <= 1'b0;
        router3_oport2buf05_cur_busy <= 1'b0;
        router3_oport2buf06_cur_busy <= 1'b0;
        router3_oport2buf07_cur_busy <= 1'b0;
        router3_iport_cur_busy       <= 1'b0;
    end
    else if(ins_issue_en && (src_port_id == 4'd10))
    begin
        router3_oport2buf04_cur_busy <= (des_port_id == 4'd4) ? 1'b1 : router3_oport2buf04_cur_busy;
        router3_oport2buf05_cur_busy <= (des_port_id == 4'd5) ? 1'b1 : router3_oport2buf05_cur_busy;
        router3_oport2buf06_cur_busy <= (des_port_id == 4'd6) ? 1'b1 : router3_oport2buf06_cur_busy;
        router3_oport2buf07_cur_busy <= (des_port_id == 4'd7) ? 1'b1 : router3_oport2buf07_cur_busy;
        router3_iport_cur_busy       <= 1'b1;
    end
    else if(router_done[3])
    begin
        router3_oport2buf04_cur_busy <= 1'b0;
        router3_oport2buf05_cur_busy <= 1'b0;
        router3_oport2buf06_cur_busy <= 1'b0;
        router3_oport2buf07_cur_busy <= 1'b0;
        router3_iport_cur_busy       <= 1'b0;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        router4_oport2buf00_cur_busy <= 1'b0;
        router4_oport2buf01_cur_busy <= 1'b0;
        router4_oport2buf08_cur_busy <= 1'b0;
        router4_oport2buf09_cur_busy <= 1'b0;
        router4_iport_cur_busy       <= 1'b0;
    end
    else if(ins_issue_en && (src_port_id == 4'd12))
    begin
        router4_oport2buf00_cur_busy <= (des_port_id == 4'd0) ? 1'b1 : router4_oport2buf00_cur_busy;
        router4_oport2buf01_cur_busy <= (des_port_id == 4'd1) ? 1'b1 : router4_oport2buf01_cur_busy;
        router4_oport2buf08_cur_busy <= (des_port_id == 4'd8) ? 1'b1 : router4_oport2buf08_cur_busy;
        router4_oport2buf09_cur_busy <= (des_port_id == 4'd9) ? 1'b1 : router4_oport2buf09_cur_busy;
        router4_iport_cur_busy       <= 1'b1;
    end
    else if(router_done[4])
    begin
        router4_oport2buf00_cur_busy <= 1'b0;
        router4_oport2buf01_cur_busy <= 1'b0;
        router4_oport2buf08_cur_busy <= 1'b0;
        router4_oport2buf09_cur_busy <= 1'b0;
        router4_iport_cur_busy       <= 1'b0;
    end
end

/***************** future busy state for router 3/5 *********************/
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        router3_oport2buf04_pre_busy <= 1'b0;
        router3_oport2buf05_pre_busy <= 1'b0;
        router3_oport2buf06_pre_busy <= 1'b0;
        router3_oport2buf07_pre_busy <= 1'b0;
        router3_iport_pre_busy       <= 1'b0;
    end
    else if(any_router_done)
    begin
        router3_oport2buf04_pre_busy <= 1'b0;
        router3_oport2buf05_pre_busy <= 1'b0;
        router3_oport2buf06_pre_busy <= 1'b0;
        router3_oport2buf07_pre_busy <= 1'b0;
        router3_iport_pre_busy       <= 1'b0;
    end
    else if((ins_search_ptr == ins_write_ptr-1) && ~ins_input_en)
    begin
        router3_oport2buf04_pre_busy <= 1'b0;
        router3_oport2buf05_pre_busy <= 1'b0;
        router3_oport2buf06_pre_busy <= 1'b0;
        router3_oport2buf07_pre_busy <= 1'b0;
        router3_iport_pre_busy       <= 1'b0;
    end
    else if((cur_state == SEARCH) && (src_port_id == 4'd10))
    begin
        router3_oport2buf04_pre_busy <= (des_port_id == 4'd4) ? 1'b1 : router3_oport2buf04_pre_busy;
        router3_oport2buf05_pre_busy <= (des_port_id == 4'd5) ? 1'b1 : router3_oport2buf05_pre_busy;
        router3_oport2buf06_pre_busy <= (des_port_id == 4'd6) ? 1'b1 : router3_oport2buf06_pre_busy;
        router3_oport2buf07_pre_busy <= (des_port_id == 4'd7) ? 1'b1 : router3_oport2buf07_pre_busy;
        router3_iport_pre_busy       <= 1'b1;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        router4_oport2buf00_pre_busy <= 1'b0;
        router4_oport2buf01_pre_busy <= 1'b0;
        router4_oport2buf08_pre_busy <= 1'b0;
        router4_oport2buf09_pre_busy <= 1'b0;
        router4_iport_pre_busy       <= 1'b0;
    end
    else if(any_router_done)
    begin
        router4_oport2buf00_pre_busy <= 1'b0;
        router4_oport2buf01_pre_busy <= 1'b0;
        router4_oport2buf08_pre_busy <= 1'b0;
        router4_oport2buf09_pre_busy <= 1'b0;
        router4_iport_pre_busy       <= 1'b0;
    end
    else if((ins_search_ptr == ins_write_ptr-1) && ~ins_input_en)
    begin
        router4_oport2buf00_pre_busy <= 1'b0;
        router4_oport2buf01_pre_busy <= 1'b0;
        router4_oport2buf08_pre_busy <= 1'b0;
        router4_oport2buf09_pre_busy <= 1'b0;
        router4_iport_pre_busy       <= 1'b0;
    end
    else if((cur_state == SEARCH) && (src_port_id == 4'd12))
    begin
        router4_oport2buf00_pre_busy <= (des_port_id == 4'd0) ? 1'b1 : router4_oport2buf00_pre_busy;
        router4_oport2buf01_pre_busy <= (des_port_id == 4'd1) ? 1'b1 : router4_oport2buf01_pre_busy;
        router4_oport2buf08_pre_busy <= (des_port_id == 4'd8) ? 1'b1 : router4_oport2buf08_pre_busy;
        router4_oport2buf09_pre_busy <= (des_port_id == 4'd9) ? 1'b1 : router4_oport2buf09_pre_busy;
        router4_iport_pre_busy       <= 1'b1;
    end
end

assign buf00_cur_busy = buf00_oport2router0_cur_busy || router4_oport2buf00_cur_busy; 
assign buf01_cur_busy = buf01_oport2router0_cur_busy || router4_oport2buf01_cur_busy;
assign buf02_cur_busy = buf02_oport2router1_cur_busy; 
assign buf03_cur_busy = buf03_oport2router1_cur_busy; 
assign buf04_cur_busy = buf04_oport2router0_pe_cur_busy || buf04_oport2router2_fe_cur_busy || router3_oport2buf04_cur_busy; 
assign buf05_cur_busy = buf05_oport2router0_pe_cur_busy || buf05_oport2router2_fe_cur_busy || router3_oport2buf05_cur_busy;
assign buf06_cur_busy = buf06_oport2router2_cur_busy || router3_oport2buf06_cur_busy;
assign buf07_cur_busy = buf07_oport2router2_cur_busy || router3_oport2buf07_cur_busy; 
assign buf08_cur_busy = buf08_oport2router0_cur_busy || router4_oport2buf08_cur_busy;
assign buf09_cur_busy = buf09_oport2router0_cur_busy || router4_oport2buf09_cur_busy; 

assign buf00_pre_busy = buf00_oport2router0_pre_busy || router4_oport2buf00_pre_busy; 
assign buf01_pre_busy = buf01_oport2router0_pre_busy || router4_oport2buf01_pre_busy;
assign buf02_pre_busy = buf02_oport2router1_pre_busy; 
assign buf03_pre_busy = buf03_oport2router1_pre_busy; 
assign buf04_pre_busy = buf04_oport2router0_pe_pre_busy || buf04_oport2router2_fe_pre_busy || router3_oport2buf04_pre_busy; 
assign buf05_pre_busy = buf05_oport2router0_pe_pre_busy || buf05_oport2router2_fe_pre_busy || router3_oport2buf05_pre_busy;
assign buf06_pre_busy = buf06_oport2router2_pre_busy || router3_oport2buf06_pre_busy;
assign buf07_pre_busy = buf07_oport2router2_pre_busy || router3_oport2buf07_pre_busy; 
assign buf08_pre_busy = buf08_oport2router0_pre_busy || router4_oport2buf08_pre_busy;
assign buf09_pre_busy = buf09_oport2router0_pre_busy || router4_oport2buf09_pre_busy; 

assign buf00_busy = buf00_cur_busy || buf00_pre_busy ;
assign buf01_busy = buf01_cur_busy || buf01_pre_busy ;
assign buf02_busy = buf02_cur_busy || buf02_pre_busy ;
assign buf03_busy = buf03_cur_busy || buf03_pre_busy ;
assign buf04_busy = buf04_cur_busy || buf04_pre_busy ;
assign buf05_busy = buf05_cur_busy || buf05_pre_busy ;
assign buf06_busy = buf06_cur_busy || buf06_pre_busy ;
assign buf07_busy = buf07_cur_busy || buf07_pre_busy ;
assign buf08_busy = buf08_cur_busy || buf08_pre_busy ;
assign buf09_busy = buf09_cur_busy || buf09_pre_busy ; 

assign pe_input_busy  = router0_oport_cur_busy || router0_oport_pre_busy;
assign pe_weight_busy = router1_oport_cur_busy || router1_oport_pre_busy;
assign fe_input_busy  = router2_oport_cur_busy || router2_oport_pre_busy;
assign pe_output_busy = router3_iport_cur_busy || router3_iport_pre_busy;
assign fe_output_busy = router4_iport_cur_busy || router4_iport_pre_busy;

always@(*)
begin
    if((cur_state == SEARCH) && (des_port_id == 4'd10) && (~pe_input_busy))
        case(src_port_id)
        4'd0:    router_ins_en[0] = ~buf00_busy ;
        4'd1:    router_ins_en[0] = ~buf01_busy ;
        4'd4:    router_ins_en[0] = ~buf04_busy ;
        4'd5:    router_ins_en[0] = ~buf05_busy ;
        4'd8:    router_ins_en[0] = ~buf08_busy ;
        4'd9:    router_ins_en[0] = ~buf09_busy ;
        default: router_ins_en[0] = 1'b0        ;
        endcase
    else
        router_ins_en[0] = 1'b0;
end

always@(*)
begin
    if((cur_state == SEARCH) && (des_port_id == 4'd11) && (~pe_weight_busy))
    begin
        case(src_port_id)
        4'd2:    router_ins_en[1] = ~buf02_busy ;
        4'd3:    router_ins_en[1] = ~buf03_busy ;
        default: router_ins_en[1] = 1'b0        ;
        endcase
    end
    else
    begin
        router_ins_en[1] = 1'b0;
    end
end

always@(*)
begin
    if((cur_state == SEARCH) && (des_port_id == 4'd12) && (~fe_input_busy))
    begin
        case(src_port_id)
        4'd4:    router_ins_en[2] = ~buf04_busy ;
        4'd5:    router_ins_en[2] = ~buf05_busy ;
        4'd6:    router_ins_en[2] = ~buf06_busy ;
        4'd7:    router_ins_en[2] = ~buf07_busy ;
        default: router_ins_en[2] = 1'b0        ;
        endcase
    end
    else
    begin
        router_ins_en[2] = 1'b0;
    end
end

always@(*)
begin
    if((cur_state == SEARCH) && (src_port_id == 4'd10) && (~pe_output_busy))
    begin
        case(des_port_id)
        4'd4:    router_ins_en[3] = ~buf04_busy ;
        4'd5:    router_ins_en[3] = ~buf05_busy ;
        4'd6:    router_ins_en[3] = ~buf06_busy ;
        4'd7:    router_ins_en[3] = ~buf07_busy ;
        default: router_ins_en[3] = 1'b0        ;
        endcase
    end
    else
    begin
        router_ins_en[3] = 1'b0;
    end
end


always@(*)
begin
    if((cur_state == SEARCH) && (src_port_id == 4'd12) && (~fe_output_busy))
    begin
        case(des_port_id)
        4'd0:    router_ins_en[4] = ~buf00_busy ;
        4'd1:    router_ins_en[4] = ~buf01_busy ;
        4'd8:    router_ins_en[4] = ~buf08_busy ;
        4'd9:    router_ins_en[4] = ~buf09_busy ;
        default: router_ins_en[4] = 1'b0        ;
        endcase
    end
    else
    begin
        router_ins_en[4] = 1'b0;
    end
end

endmodule
