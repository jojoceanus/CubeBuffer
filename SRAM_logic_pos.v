module SRAM_logic_pos(
    input                         clk         ,
    input                         rst_n       ,
                                    
    input               [11:0]    WBlock      , 
    input               [11:0]    HBlock      ,
    input               [11:0]    CBlock      ,
    input                         WCell       ,
    input               [ 7:0]    HCell       ,
    input               [ 4:0]    CCell       ,
    input               [ 6:0]    WCellstep   ,
    input               [ 6:0]    HCellstep   ,
    input               [ 6:0]    CCellstep   ,
    input               [ 2:0]    OrderCell   ,
    input                         SRAM_wr     ,
    input               [10:0]    WWindow     ,
    input               [10:0]    HWindow     ,
    input               [10:0]    CWindow     ,
    input               [ 6:0]    WWindowstep ,
    input               [ 6:0]    HWindowstep ,
    input               [ 6:0]    CWindowstep ,
    input               [ 2:0]    OrderWindow ,
    input               [ 9:0]    access_times,
    input  signed       [ 5:0]    WWindowstart,
    input  signed       [ 5:0]    HWindowstart,
    input  signed       [ 5:0]    CWindowstart,
    input               [10:0]    WWindowend  ,
    input               [10:0]    HWindowend  ,
    input               [10:0]    CWindowend  ,
    input                         RWdata_start,
                                      
    output  reg                   position_vld,
    input                         position_rdy,                                    
    output  wire  [11:0]  cell_pos_inside_block_w  ,
    output  wire  [11:0]  cell_pos_inside_block_h  ,
    output  wire  [11:0]  cell_pos_inside_block_c  ,                                    
    output  wire  [9:0]   data_num_outside_negetive_boundary_w,
    output  wire  [9:0]   data_num_outside_negetive_boundary_h,
    output  wire  [9:0]   data_num_outside_negetive_boundary_c,                                  
    output  wire  [ 9:0]  access_w    ,
    output  wire  [ 9:0]  access_h    ,
    output  wire  [ 9:0]  access_c    ,
    output                        last_position_flag  //Logical coordinate calculation end flag
    );

reg                   work_flag                  ; //Work Signal 
reg         [ 9:0]    window_access_cnt          ; //Window Data Repeat Access Count
              
wire                  position_out_en            ; 
wire                  window_access_one_time     ; 
wire                  window_access_done         ; 
wire signed [11:0]    cell_w_pos                 ;
wire signed [11:0]    cell_h_pos                 ;
wire signed [11:0]    cell_c_pos                 ;
wire signed [11:0]    window_w_pos               ;
wire signed [11:0]    window_h_pos               ;
wire signed [11:0]    window_c_pos               ;

wire                  last_cell_pos_in_window    ;
wire                  last_window_in_block_flag  ;

wire signed [11:0]  cell_pos_inside_block_w_orig ;
wire signed [11:0]  cell_pos_inside_block_h_orig ;
wire signed [11:0]  cell_pos_inside_block_c_orig ;                                    


always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        work_flag <= 1'b0;
    else if(RWdata_start)
        work_flag <= 1'b1;
    else if(last_position_flag && position_out_en)
        work_flag <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        position_vld <= 1'b0;
    else if(last_position_flag)
        position_vld <= 1'b0;
    else if(work_flag)
        position_vld <= 1'b1;
    else
        position_vld <= position_vld;
end

//Window Data Repeat Access Count
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        window_access_cnt <= 10'd0;
    else if(window_access_done)
        window_access_cnt <= 10'd0;
    else if(window_access_one_time)
        window_access_cnt <= window_access_cnt + 10'd1;
end

assign position_out_en        = position_vld && position_rdy;
assign window_access_one_time = position_out_en && last_cell_pos_in_window; 
assign window_access_done     =(window_access_cnt == access_times - 1) && window_access_one_time;
assign last_position_flag     = window_access_done & last_window_in_block_flag;

//cell can never cross window boundary
wire    [11:0] last_legal_cell_pos_w_inside_window;
wire    [11:0] last_legal_cell_pos_h_inside_window;
wire    [11:0] last_legal_cell_pos_c_inside_window;

assign last_legal_cell_pos_w_inside_window = {1'b0,WWindow} - {11'd0,WCell};
assign last_legal_cell_pos_h_inside_window = {1'b0,HWindow} - { 4'd0,HCell};
assign last_legal_cell_pos_c_inside_window = {1'b0,CWindow} - { 7'd0,CCell};

pos_ctrl #(
    .POS_WIDTH(12 ),
    .STP_WIDTH(7  )
)
cell_pos_ctrl_in_window   (
    .clk                (clk                                    ),
    .rst_n              (rst_n                                  ),
    .start              (RWdata_start                           ), 
    .access_en          (position_out_en                        ), // one access over
    .access_order       (OrderCell                              ), // access OrderCell
    .w_init_pos         (12'd0                                  ), // initial pos 
    .h_init_pos         (12'd0                                  ), // initial pos 
    .c_init_pos         (12'd0                                  ), // initial pos 
    .w_last_legal_pos   (last_legal_cell_pos_w_inside_window    ), // last legal pos
    .h_last_legal_pos   (last_legal_cell_pos_h_inside_window    ), // last legal pos
    .c_last_legal_pos   (last_legal_cell_pos_c_inside_window    ), // last legal pos
    .w_step             (WCellstep                              ), // move step between two access
    .h_step             (HCellstep                              ), // move step between two access
    .c_step             (CCellstep                              ), // move step between two access
    .w_pos              (cell_w_pos                             ), // access position
    .h_pos              (cell_h_pos                             ), // access position
    .c_pos              (cell_c_pos                             ), // access position
    .last_pos_flag      (last_cell_pos_in_window                )  // last window access position
);

pos_ctrl #(
    .POS_WIDTH(12 ),
    .STP_WIDTH(7  )
)
window_pos_ctrl_in_block    (
    .clk                   (clk                                ),
    .rst_n                 (rst_n                              ),
    .start                 (RWdata_start                       ), 
    .access_en             (window_access_done                 ), // one access over
    .access_order          (OrderWindow                        ), // access OrderCell
    .w_init_pos            ({{6{WWindowstart[5]}},WWindowstart}), // initial pos 
    .h_init_pos            ({{6{HWindowstart[5]}},HWindowstart}), // initial pos 
    .c_init_pos            ({{6{CWindowstart[5]}},CWindowstart}), // initial pos 
    .w_last_legal_pos      ({1'b0,WWindowend}                  ), // last legal pos
    .h_last_legal_pos      ({1'b0,HWindowend}                  ), // last legal pos
    .c_last_legal_pos      ({1'b0,CWindowend}                  ), // last legal pos
    .w_step                (WWindowstep                        ), // move step between two access
    .h_step                (HWindowstep                        ), // move step between two access
    .c_step                (CWindowstep                        ), // move step between two access
    .w_pos                 (window_w_pos                       ), // access position
    .h_pos                 (window_h_pos                       ), // access position
    .c_pos                 (window_c_pos                       ), // access position
    .last_pos_flag         (last_window_in_block_flag          )  // last center access position  
);
//access position
assign cell_pos_inside_block_w_orig = cell_w_pos + window_w_pos;
assign cell_pos_inside_block_h_orig = cell_h_pos + window_h_pos;
assign cell_pos_inside_block_c_orig = cell_c_pos + window_c_pos;

wire  [11:0]  abs_cell_pos_inside_block_w  ;
wire  [11:0]  abs_cell_pos_inside_block_h  ;
wire  [11:0]  abs_cell_pos_inside_block_c  ;                                   
assign abs_cell_pos_inside_block_w = cell_pos_inside_block_w_orig[11] ? (~cell_pos_inside_block_w_orig + 12'd1) : cell_pos_inside_block_w_orig;
assign abs_cell_pos_inside_block_h = cell_pos_inside_block_h_orig[11] ? (~cell_pos_inside_block_h_orig + 12'd1) : cell_pos_inside_block_h_orig;
assign abs_cell_pos_inside_block_c = cell_pos_inside_block_c_orig[11] ? (~cell_pos_inside_block_c_orig + 12'd1) : cell_pos_inside_block_c_orig;

//how many points are outside the positive boundary
wire signed [12:0]  cell_cross_block_positive_boundary_w ;
wire signed [12:0]  cell_cross_block_positive_boundary_h ;
wire signed [12:0]  cell_cross_block_positive_boundary_c ;                                    
assign cell_cross_block_positive_boundary_w = {cell_pos_inside_block_w_orig[11],cell_pos_inside_block_w_orig} + {12'b0,WCell} - {1'b0,WBlock};
assign cell_cross_block_positive_boundary_h = {cell_pos_inside_block_h_orig[11],cell_pos_inside_block_h_orig} + { 5'b0,HCell} - {1'b0,HBlock};
assign cell_cross_block_positive_boundary_c = {cell_pos_inside_block_c_orig[11],cell_pos_inside_block_c_orig} + { 8'b0,CCell} - {1'b0,CBlock};

wire  [9:0]   data_num_outside_positive_boundary_w;
wire  [9:0]   data_num_outside_positive_boundary_h;
wire  [9:0]   data_num_outside_positive_boundary_c;                                    

assign data_num_outside_positive_boundary_w = cell_cross_block_positive_boundary_w[12] ? 10'd0 : cell_cross_block_positive_boundary_w[9:0];
assign data_num_outside_positive_boundary_h = cell_cross_block_positive_boundary_h[12] ? 10'd0 : cell_cross_block_positive_boundary_h[9:0];
assign data_num_outside_positive_boundary_c = cell_cross_block_positive_boundary_c[12] ? 10'd0 : cell_cross_block_positive_boundary_c[9:0];

assign data_num_outside_negetive_boundary_w = cell_pos_inside_block_w_orig[11] ? abs_cell_pos_inside_block_w[9:0] : 10'd0;
assign data_num_outside_negetive_boundary_h = cell_pos_inside_block_h_orig[11] ? abs_cell_pos_inside_block_h[9:0] : 10'd0;
assign data_num_outside_negetive_boundary_c = cell_pos_inside_block_c_orig[11] ? abs_cell_pos_inside_block_c[9:0] : 10'd0;
assign cell_pos_inside_block_w              = cell_pos_inside_block_w_orig[11] ? 12'd0 : cell_pos_inside_block_w_orig;
assign cell_pos_inside_block_h              = cell_pos_inside_block_h_orig[11] ? 12'd0 : cell_pos_inside_block_h_orig;
assign cell_pos_inside_block_c              = cell_pos_inside_block_c_orig[11] ? 12'd0 : cell_pos_inside_block_c_orig;


wire signed [ 9:0]  access_w_orig ;
wire signed [ 9:0]  access_h_orig ;
wire signed [ 9:0]  access_c_orig ;
assign access_w_orig = {9'b0,WCell} - data_num_outside_positive_boundary_w - data_num_outside_negetive_boundary_w;
assign access_h_orig = {2'b0,HCell} - data_num_outside_positive_boundary_h - data_num_outside_negetive_boundary_h;
assign access_c_orig = {5'b0,CCell} - data_num_outside_positive_boundary_c - data_num_outside_negetive_boundary_c;

assign access_w = access_w_orig[9] ? 10'd0 : access_w_orig;
assign access_h = access_h_orig[9] ? 10'd0 : access_h_orig;
assign access_c = access_c_orig[9] ? 10'd0 : access_c_orig;


reg [31:0]   position_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        position_cnt <= 'd0;
    else if(last_position_flag)
        position_cnt <= 0;
    else if(position_vld && position_rdy)
        position_cnt <= position_cnt + 'd1;
end


endmodule


