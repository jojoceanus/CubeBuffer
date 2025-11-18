module decoder(
    input                        clk                       ,
    input                        rst_n                     ,             
                                                           
    input            [63:0]      ins2fifo                  ,//Instruction from Instruction_distribution
    input                        ins2fifo_vld              ,
    output                       ins2fifo_rdy              , 
    //配置信号                                             
    output reg       [11:0]      WBlock                         ,//The size of the data buffer to store the data
    output reg       [11:0]      HBlock                         ,
    output reg       [11:0]      CBlock                         ,           
    output reg                   WCell                        ,//The size of the data block that the data buffer writes at one time
    output reg       [ 7:0]      HCell                        ,//Second-level data blocks
    output reg       [ 4:0]      CCell                        ,                                
    output reg       [ 6:0]      WCellstep                     ,//stride of the first-level data block over the entire addressing space
    output reg       [ 6:0]      HCellstep                     ,
    output reg       [ 6:0]      CCellstep                     , 
    output reg       [ 2:0]      OrderCell                     ,//Read/write OrderCell of first-level data blocks throughout the addressing space         
    output reg       [ 1:0]      work_mode                 ,//SRAM working modes
    output reg       [ 1:0]      DW                        ,//data size  
    output                       SRAM_wr                   ,//read or write SRAM, 0:read ,1:write   
    output reg       [10:0]      WWindow                   ,//First-level data blocks size
    output reg       [10:0]      HWindow                   ,
    output reg       [10:0]      CWindow                   ,
    output reg       [ 6:0]      WWindowstep               ,//step within a first-level data block for read/write of a second-level data block
    output reg       [ 6:0]      HWindowstep               ,
    output reg       [ 6:0]      CWindowstep               ,
    output reg       [ 2:0]      OrderWindow               ,//Read/write OrderCell of Second-level data blocks within a first-level data block
    output reg       [ 9:0]      access_times              ,//Number of repeated access to first-level data blocks
    output reg signed[ 5:0]      WWindowstart              ,//Starting position of the first-level data block
    output reg signed[ 5:0]      HWindowstart              ,
    output reg signed[ 5:0]      CWindowstart              ,
    output reg       [10:0]      WWindowend                ,//Ending position of the first-level data block
    output reg       [10:0]      HWindowend                ,
    output reg       [10:0]      CWindowend                ,
    output wire                  RWdata_start              ,//SRAM read/write start signal

    input                        sram_array_read_data_done ,//Read SRAM completion signal, level signal
    input                        sram_array_write_data_done,//Write SRAM completion signal, level signal
                       
    output reg       [12:0]      Stride                    ,//each column data step in DDR
    output reg       [12:0]      W0                        ,//Starting coordinate of a set of 3D data in DDR
    output reg       [12:0]      H0                        ,
    output reg       [12:0]      C0                        ,
    output reg       [12:0]      total_line_num            ,//The number of rows of data in a 2D plane when the overall 3D data is laid out in the DDR
    output                       DDR_wr                    ,//read or write DDR, 0:read ,1:write   
    output wire      [26:0]      feature_map_initial_addr  ,//Starting point of the currently accessed Feature map in the DDR address
    output reg       [ 7:0]      Lens                      ,//burst length of AXI4
    output wire                  gen_addr_start            ,//Start signal for the DDR address generation unit to start calculating the address
                          
    input                        gen_addr_done              //DDR address calculation end flag signal Level signal
);
/***************parameter***************/
parameter IDLE          = 2'b00; 
parameter RWDDR         = 2'b01; 
parameter RWROUTING     = 2'b10; 
parameter GENSTART      = 2'b11; 

/***************ins_fifo***************/
wire  [63:0] ins_data;
wire         ins_vld;
wire         ins_rdy;
vld_rdy_fifo#(
    .FIFO_WIDTH (64), 
    .FIFO_DEPTH (32)
)
buffer_ins_fifo
(
    .clk        (clk         ),
    .rst_n      (rst_n       ),
                                  
    .fifo_i_data(ins2fifo    ),
    .fifo_i_vld (ins2fifo_vld),
    .fifo_i_rdy (ins2fifo_rdy),
    
    .fifo_o_data(ins_data    ),
    .fifo_o_vld (ins_vld     ),
    .fifo_o_rdy (ins_rdy     )
);


/***************reg*********************/                                            
    
reg  [1:0]        cur_state              ;
reg  [1:0]        nxt_state              ;

/***************wire********************/
wire [2:0]        ins_id                   ;
wire              work_ins_flag            ;
wire              conf1_ins_flag           ;
wire              conf2_ins_flag           ;
wire              conf3_ins_flag           ;
wire              conf4_ins_flag           ;
wire              conf5_ins_flag           ;
wire              ins_receive              ;
reg  [12:0]       feature_map_initial_addr1;
reg  [13:0]       feature_map_initial_addr2;

assign ins_rdy        = (cur_state == IDLE) ? 1'b1 : 1'b0 ;
assign ins_receive    = ins_vld & ins_rdy          ;   
                                                                  
assign ins_id         = ins_data[56:54];
assign work_ins_flag  = (ins_id == 3'b000) ? 1'b1 : 1'b0;
assign conf1_ins_flag = (ins_id == 3'b001) ? 1'b1 : 1'b0;
assign conf2_ins_flag = (ins_id == 3'b010) ? 1'b1 : 1'b0;  
assign conf3_ins_flag = (ins_id == 3'b011) ? 1'b1 : 1'b0;
assign conf4_ins_flag = (ins_id == 3'b100) ? 1'b1 : 1'b0;
assign conf5_ins_flag = (ins_id == 3'b101) ? 1'b1 : 1'b0;

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        WWindowstep               <= 'b0;
        HWindowstep               <= 'b0;
        CWindowstep               <= 'b0;
        WCellstep                 <= 'b0;
        HCellstep                 <= 'b0;
        CCellstep                 <= 'b0;        
        OrderCell                 <= 'b0;        
        work_mode                 <= 'b0;
        feature_map_initial_addr1 <= 'b0;
        feature_map_initial_addr2 <= 'b0;
        Stride                    <= 'b0;
        DW                        <= 'b0;    
        W0                        <= 'b0; 
        H0                        <= 'b0;
        C0                        <= 'b0;
        total_line_num            <= 'b0;
        Lens                      <= 'b0;    
        WBlock                    <= 'b0;
        HBlock                    <= 'b0;
        CBlock                    <= 'b0;
        WCell                     <= 'b0;
        HCell                     <= 'b0;
        CCell                     <= 'b0;
        access_times              <= 'b0;
        WWindow                   <= 'b0;
        HWindow                   <= 'b0;
        CWindow                   <= 'b0;
        WWindowstart              <= 'b0;
        HWindowstart              <= 'b0;
        CWindowstart              <= 'b0;
        WWindowend                <= 'b0;
        HWindowend                <= 'b0;
        CWindowend                <= 'b0;
        OrderWindow               <= 'b0;
    end
    else if(ins_receive)
    begin
        WWindowstep               <= work_ins_flag  ? {1'b0,ins_data[53:48]} + 1'd1: WWindowstep              ;
        HWindowstep               <= work_ins_flag  ? {1'b0,ins_data[47:42]} + 1'd1: HWindowstep              ;
        CWindowstep               <= work_ins_flag  ? {1'b0,ins_data[41:36]} + 1'd1: CWindowstep              ;
        WCellstep                 <= work_ins_flag  ? {1'b0,ins_data[35:30]} + 1'd1: WCellstep                ;
        HCellstep                 <= work_ins_flag  ? {1'b0,ins_data[29:24]} + 1'd1: HCellstep                ;
        CCellstep                 <= work_ins_flag  ? {1'b0,ins_data[23:18]} + 1'd1: CCellstep                ;
        OrderCell                 <= work_ins_flag  ? ins_data[17:15]              : OrderCell                ;
        work_mode                 <= work_ins_flag  ? ins_data[14:13]              : work_mode                  ;
        feature_map_initial_addr1 <= work_ins_flag  ? ins_data[12: 0]              : feature_map_initial_addr1;
                                                                                  
        Stride                    <= conf1_ins_flag ? ins_data[53:41]              : Stride                   ;
        DW                        <= conf1_ins_flag ? ins_data[40:39]              : DW                       ;
        W0                        <= conf1_ins_flag ? ins_data[38:26]              : W0                       ;
        H0                        <= conf1_ins_flag ? ins_data[25:13]              : H0                       ;
        C0                        <= conf1_ins_flag ? ins_data[12: 0]              : C0                       ;
                                                                                                              
        total_line_num            <= conf2_ins_flag ? ins_data[53:41]              : total_line_num           ;
        Lens                      <= conf2_ins_flag ? ins_data[40:33]              : Lens                     ;
        WBlock                    <= conf2_ins_flag ? {1'b0,ins_data[32:22]} + 1'd1: WBlock                   ;
        HBlock                    <= conf2_ins_flag ? {1'b0,ins_data[21:11]} + 1'd1: HBlock                   ;
        CBlock                    <= conf2_ins_flag ? {1'b0,ins_data[10: 0]} + 1'd1: CBlock                   ;

        WCell                     <= conf3_ins_flag ?        ins_data[   53] + 1'd1: WCell                    ;
        HCell                     <= conf3_ins_flag ?        ins_data[52:46] + 1'd1: HCell                    ;
        CCell                     <= conf3_ins_flag ?        ins_data[45:42] + 1'd1: CCell                    ;
        access_times              <= conf3_ins_flag ? {1'b0,ins_data[41:33]} + 1'd1: access_times             ;
        WWindow                   <= conf3_ins_flag ?        ins_data[32:22] + 1'd1: WWindow                  ;
        HWindow                   <= conf3_ins_flag ?        ins_data[21:11] + 1'd1: HWindow                  ;
        CWindow                   <= conf3_ins_flag ?        ins_data[10: 0] + 1'd1: CWindow                  ;
                                                                                                              
        WWindowstart              <= conf4_ins_flag ? ins_data[53:48]              : WWindowstart             ;
        HWindowstart              <= conf4_ins_flag ? ins_data[36:31]              : HWindowstart             ;
        CWindowstart              <= conf4_ins_flag ? ins_data[19:14]              : CWindowstart             ;
        WWindowend                <= conf4_ins_flag ? ins_data[47:37]              : WWindowend               ;
        HWindowend                <= conf4_ins_flag ? ins_data[30:20]              : HWindowend               ;
        CWindowend                <= conf4_ins_flag ? ins_data[13: 3]              : CWindowend               ;
        OrderWindow               <= conf4_ins_flag ? ins_data[ 2: 0]              : OrderWindow              ;
        
        feature_map_initial_addr2 <= conf5_ins_flag ? ins_data[13: 0]              : feature_map_initial_addr2;
    end 
end

//work_mode: 00 -> data from ddr to sram; 01 -> data from router to sram
//           10 -> data from sram to ddr; 11 -> data from sram to router
//SRAM_wr:    1 -> write the sram,         0 -> read the sram
assign SRAM_wr = ~work_mode[1];
//DDR_wr:     1 -> write the ddr,          0 -> read the ddr
assign DDR_wr  =  work_mode[1];

assign gen_addr_start = ((cur_state == GENSTART) && (work_mode[0] == 1'b0)) ? 1'b1 : 1'b0;
assign RWdata_start = (cur_state == GENSTART) ? 1'b1 : 1'b0; 

reg [3:0] work_time_cnt;
always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        work_time_cnt <= 4'd0;
    end
    else if(RWdata_start)
    begin
        work_time_cnt <= work_time_cnt + 4'd1;
    end
end

assign feature_map_initial_addr = {feature_map_initial_addr2 , feature_map_initial_addr1};

/***************** FSM ***********/
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cur_state <= IDLE;
    else
        cur_state <= nxt_state  ;
end

always@(*)                                 
begin                                      
    case(cur_state)
    IDLE : 
    begin
        if(ins_receive && work_ins_flag)
            nxt_state = GENSTART;
        else
            nxt_state = IDLE;
    end
    GENSTART : 
    begin
        if(work_mode == 2'b00 || work_mode == 2'b10)
            nxt_state = RWDDR;
        else
            nxt_state = RWROUTING;
    end
    RWDDR       :   nxt_state = (gen_addr_done && (sram_array_read_data_done || sram_array_write_data_done)) ? IDLE : RWDDR;
    RWROUTING   :   nxt_state = (sram_array_read_data_done || sram_array_write_data_done) ? IDLE : RWROUTING             ;
    default     :   nxt_state = IDLE;
    endcase 
end                                                    
                                                           
endmodule
