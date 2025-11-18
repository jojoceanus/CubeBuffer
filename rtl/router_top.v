module router_top #(
    parameter                           ROUTER_INS_WIDTH    =   64  ,
    parameter                           ROUTER_NUM          =   5   ,  
    parameter                           PE_IN_DATA_SIZE     =   2176,//Test data bit width set to 8 bits
    parameter                           PE_OUT_DATA_SIZE    =   1600,
    parameter                           PE_WEIGHT_DATA_SIZE =   640 ,
    parameter                           FE_IN_DATA_SIZE     =   1024,
    parameter                           FE_OUT_DATA_SIZE    =   128
)
(
    input                                 clk              ,
    input                                 rst_n            ,
														   
    input                                 router_ins_vld   ,
    output                                router_ins_rdy   ,
    input       [ROUTER_INS_WIDTH-1:0]    router_ins_data  ,

    input                                 buf00_oport_vld  ,
    output                                buf00_oport_rdy  ,
    input       [PE_IN_DATA_SIZE - 1 : 0] buf00_oport_data , //buff00_to_routing_data

    input                                 buf01_oport_vld  ,
    output                                buf01_oport_rdy  ,
    input       [PE_IN_DATA_SIZE - 1 : 0] buf01_oport_data , //buff01_to_routing_data

    input                                 buf02_oport_vld  ,
    output                                buf02_oport_rdy  ,
    input       [PE_WEIGHT_DATA_SIZE-1:0] buf02_oport_data , //buff02_to_routing_data

    input                                 buf03_oport_vld  ,
    output                                buf03_oport_rdy  ,
    input       [PE_WEIGHT_DATA_SIZE-1:0] buf03_oport_data , //buff03_to_routing_data

    input                                 buf04_oport_vld  ,
    output                                buf04_oport_rdy  ,
    input       [PE_IN_DATA_SIZE - 1 : 0] buf04_oport_data , //buff04_to_routing_data

    input                                 buf05_oport_vld  ,
    output                                buf05_oport_rdy  ,
    input       [PE_IN_DATA_SIZE - 1 : 0] buf05_oport_data , //buff05_to_routing_data

    input                                 buf06_oport_vld  ,
    output                                buf06_oport_rdy  ,
    input       [FE_IN_DATA_SIZE - 1 : 0] buf06_oport_data , //buff06_to_routing_data
	
    input                                 buf07_oport_vld  ,
    output                                buf07_oport_rdy  ,
    input       [FE_IN_DATA_SIZE - 1 : 0] buf07_oport_data , //buff07_to_routing_data
	
    input                                 buf08_oport_vld  ,
    output                                buf08_oport_rdy  ,
    input       [PE_IN_DATA_SIZE - 1 : 0] buf08_oport_data , //buff08_to_routing_data

    input                                 buf09_oport_vld  ,
    output                                buf09_oport_rdy  ,
    input       [PE_IN_DATA_SIZE - 1 : 0] buf09_oport_data , //buff09_to_routing_data

    output                                buf00_iport_vld  ,
    input                                 buf00_iport_rdy  ,
    output      [FE_OUT_DATA_SIZE- 1 : 0] buf00_iport_data , //routing_to_buff00_data
										  
    output                                buf01_iport_vld  ,
    input                                 buf01_iport_rdy  ,
    output      [FE_OUT_DATA_SIZE- 1 : 0] buf01_iport_data , //routing_to_buff01_data										  
										  
    output                                buf04_iport_vld  ,
    input                                 buf04_iport_rdy  ,
    output      [PE_OUT_DATA_SIZE- 1 : 0] buf04_iport_data , //routing_to_buff04_data	
										  
    output                                buf05_iport_vld  ,
    input                                 buf05_iport_rdy  ,
    output      [PE_OUT_DATA_SIZE- 1 : 0] buf05_iport_data , //routing_to_buff05_data	
										  
    output                                buf06_iport_vld  ,
    input                                 buf06_iport_rdy  ,
    output      [PE_OUT_DATA_SIZE- 1 : 0] buf06_iport_data , //routing_to_buff06_data	

    output                                buf07_iport_vld  ,
    input                                 buf07_iport_rdy  ,
    output      [PE_OUT_DATA_SIZE- 1 : 0] buf07_iport_data , //routing_to_buff07_data	
										  
    output                                buf08_iport_vld  ,
    input                                 buf08_iport_rdy  ,
    output      [FE_OUT_DATA_SIZE- 1 : 0] buf08_iport_data , //routing_to_buff08_data

    output                                buf09_iport_vld  ,
    input                                 buf09_iport_rdy  ,
    output      [FE_OUT_DATA_SIZE- 1 : 0] buf09_iport_data , //routing_to_buff09_data
										  
    output                                router_oport2pe_input_vld  ,
    input                                 router_oport2pe_input_rdy  ,
    output      [PE_IN_DATA_SIZE - 1 : 0] router_oport2pe_input_data ,
										  
    output                                router_oport2pe_weight_vld  ,
    input                                 router_oport2pe_weight_rdy  ,
    output      [PE_WEIGHT_DATA_SIZE-1:0] router_oport2pe_weight_data ,

    output                                router_oport2fe_input_vld  ,
    input                                 router_oport2fe_input_rdy  ,
    output      [FE_IN_DATA_SIZE - 1 : 0] router_oport2fe_input_data ,
										  
    input                                 pe_output2router_iport_vld  ,
    output                                pe_output2router_iport_rdy  ,
    input       [PE_OUT_DATA_SIZE- 1 : 0] pe_output2router_iport_data ,
										  
    input                                 fe_output2router_iport_vld  ,
    output                                fe_output2router_iport_rdy  ,
    input       [FE_OUT_DATA_SIZE- 1 : 0] fe_output2router_iport_data );
										 
										 
wire  [ROUTER_NUM-1:0]        router_ins_en  ;
wire  [ROUTER_INS_WIDTH-1:0]  router_ins_out ;   
wire  [ROUTER_NUM-1:0]        router_done    ;

router_ins_buffer #(
 .ROUTER_INS_WIDTH (ROUTER_INS_WIDTH),
 .ROUTER_NUM       (ROUTER_NUM      )
)
u_router_ins_buffer
(
    .clk             (clk             ),
    .rst_n           (rst_n           ),
    .router_ins_vld  (router_ins_vld  ),
    .router_ins_rdy  (router_ins_rdy  ),
    .router_ins_data (router_ins_data ),
                                      
    .router_done     (router_done     ),       
    .router_ins_en   (router_ins_en   ),
    .router_ins_out  (router_ins_out  )   
);

//********** router Nto1 *********************************//
wire    [10-1:0]                  router0_iport_vld      ;
wire    [10-1:0]                  router0_iport_rdy      ;
wire    [10*PE_IN_DATA_SIZE-1:0]  router0_iport_data     ;

wire    buf09_oport_rdy_router0;
wire    buf08_oport_rdy_router0;                    
wire    buf05_oport_rdy_router0;                   
wire    buf04_oport_rdy_router0;                    
wire    buf01_oport_rdy_router0;                    
wire    buf00_oport_rdy_router0;

assign  buf09_oport_rdy_router0 = router0_iport_rdy[9]; 
assign  buf08_oport_rdy_router0 = router0_iport_rdy[8];                   
assign  buf05_oport_rdy_router0 = router0_iport_rdy[5];                    
assign  buf04_oport_rdy_router0 = router0_iport_rdy[4];                    
assign  buf01_oport_rdy_router0 = router0_iport_rdy[1];                    
assign  buf00_oport_rdy_router0 = router0_iport_rdy[0];

assign router0_iport_vld =  {buf09_oport_vld,buf08_oport_vld,2'd0,buf05_oport_vld,buf04_oport_vld,2'd0,buf01_oport_vld,buf00_oport_vld};
assign router0_iport_data = {buf09_oport_data,buf08_oport_data,4352'd0,buf05_oport_data,buf04_oport_data,4352'd0,buf01_oport_data,buf00_oport_data};

router_Nto1#(
.PORT_NUM         (10               ),
.ROUTER_INS_WIDTH (ROUTER_INS_WIDTH),
.DATA_WIDTH       (PE_IN_DATA_SIZE ) 
)
u_buffer2pe_input_router0(
    .clk             (clk                        ),
    .rst_n           (rst_n                      ),
    .router_ins_en   (router_ins_en[0]           ),
    .router_ins_data (router_ins_out             ),
    .input_vld       (router0_iport_vld          ),
    .input_rdy       (router0_iport_rdy          ),
    .input_data      (router0_iport_data         ),
    .output_vld      (router_oport2pe_input_vld  ),
    .output_rdy      (router_oport2pe_input_rdy  ),
    .output_data     (router_oport2pe_input_data ),
    .router_done     (router_done[0]             ) 
);

wire    [10-1:0]                       router1_iport_vld      ;
wire    [10-1:0]                       router1_iport_rdy      ;
wire    [10*PE_WEIGHT_DATA_SIZE-1:0]   router1_iport_data     ;

wire    buf03_oport_rdy_router1;
wire    buf02_oport_rdy_router1;
                   
assign  buf03_oport_rdy_router1 = router1_iport_rdy[3];                    
assign  buf02_oport_rdy_router1 = router1_iport_rdy[2];

assign router1_iport_vld = {6'd0,buf03_oport_vld,buf02_oport_vld,2'd0};
assign router1_iport_data = {3840'd0,buf03_oport_data,buf02_oport_data,1280'd0};

router_Nto1#(
.PORT_NUM         (10                  ),
.ROUTER_INS_WIDTH (ROUTER_INS_WIDTH   ),
.DATA_WIDTH       (PE_WEIGHT_DATA_SIZE) 
)
u_buffer2pe_weight_router1(
    .clk             (clk                        ),
    .rst_n           (rst_n                      ),
    .router_ins_en   (router_ins_en[1]           ),
    .router_ins_data (router_ins_out             ),
    .input_vld       (router1_iport_vld          ),
    .input_rdy       (router1_iport_rdy          ),
    .input_data      (router1_iport_data         ),
    .output_vld      (router_oport2pe_weight_vld ),
    .output_rdy      (router_oport2pe_weight_rdy ),
    .output_data     (router_oport2pe_weight_data),
    .router_done     (router_done[1]             ) 
);

wire    [10-1:0]              router2_iport_vld      ;
wire    [10-1:0]              router2_iport_rdy      ;
wire    [10*FE_IN_DATA_SIZE-1:0] router2_iport_data     ;

wire    buf07_oport_rdy_router2;
wire    buf06_oport_rdy_router2;                    
wire    buf05_oport_rdy_router2;                   
wire    buf04_oport_rdy_router2;                    

assign  buf07_oport_rdy_router2 = router2_iport_rdy[7]; 
assign  buf06_oport_rdy_router2 = router2_iport_rdy[6];                   
assign  buf05_oport_rdy_router2 = router2_iport_rdy[5];                    
assign  buf04_oport_rdy_router2 = router2_iport_rdy[4];                    

assign router2_iport_vld  = {   2'b0,buf07_oport_vld,buf06_oport_vld,buf05_oport_vld,buf04_oport_vld,4'd0};
assign router2_iport_data = {2048'd0,buf07_oport_data,buf06_oport_data,buf05_oport_data[1023:0],buf04_oport_data[1023:0],4096'd0};

router_Nto1#(
.PORT_NUM         (10               ),
.ROUTER_INS_WIDTH (ROUTER_INS_WIDTH),
.DATA_WIDTH       (FE_IN_DATA_SIZE    ) 
)
u_buffer2fe_input_router2(
    .clk             (clk                       ),
    .rst_n           (rst_n                     ),
    .router_ins_en   (router_ins_en[2]          ),
    .router_ins_data (router_ins_out            ),
    .input_vld       (router2_iport_vld         ),
    .input_rdy       (router2_iport_rdy         ),
    .input_data      (router2_iport_data        ),
    .output_vld      (router_oport2fe_input_vld ),
    .output_rdy      (router_oport2fe_input_rdy ),
    .output_data     (router_oport2fe_input_data),
    .router_done     (router_done[2]            ) 
);

//********** router 1toN *********************************//
wire    [10-1:0]                    router3_oport_vld      ;
wire    [10-1:0]                    router3_oport_rdy      ;
wire    [10*PE_OUT_DATA_SIZE-1:0]   router3_oport_data     ;

router_1toN#(
.PORT_NUM         (10               ),
.ROUTER_INS_WIDTH (ROUTER_INS_WIDTH),
.DATA_WIDTH       (PE_OUT_DATA_SIZE) 
)
u_pe_output2buffer_router3(
    .clk             (clk             ),
    .rst_n           (rst_n           ),
    .router_ins_en   (router_ins_en[3]),
    .router_ins_data (router_ins_out ),
    .input_vld       (pe_output2router_iport_vld ),
    .input_rdy       (pe_output2router_iport_rdy ),
    .input_data      (pe_output2router_iport_data),
    .output_vld      (router3_oport_vld          ),
    .output_rdy      (router3_oport_rdy          ),
    .output_data     (router3_oport_data         ),
    .router_done     (router_done[3]  ) 
);

wire    [10-1:0]                    router4_oport_vld      ;
wire    [10-1:0]                    router4_oport_rdy      ;
wire    [10*FE_OUT_DATA_SIZE-1:0]   router4_oport_data     ;

router_1toN#(
.PORT_NUM         (10               ),
.ROUTER_INS_WIDTH (ROUTER_INS_WIDTH),
.DATA_WIDTH       (FE_OUT_DATA_SIZE) 
)
u_fe_output2buffer_router4(
    .clk             (clk                        ),
    .rst_n           (rst_n                      ),
    .router_ins_en   (router_ins_en[4]           ),
    .router_ins_data (router_ins_out             ),
    .input_vld       (fe_output2router_iport_vld ),
    .input_rdy       (fe_output2router_iport_rdy ),
    .input_data      (fe_output2router_iport_data),
    .output_vld      (router4_oport_vld          ),
    .output_rdy      (router4_oport_rdy          ),
    .output_data     (router4_oport_data         ),
    .router_done     (router_done[4]             ) 
);

//******************* Connect Nto1  ******************//

assign buf00_oport_rdy               = buf00_oport_rdy_router0;              
assign buf01_oport_rdy               = buf01_oport_rdy_router0;
assign buf02_oport_rdy               = buf02_oport_rdy_router1;
assign buf03_oport_rdy               = buf03_oport_rdy_router1;
assign buf04_oport_rdy               = buf04_oport_rdy_router0 | buf04_oport_rdy_router2;
assign buf05_oport_rdy               = buf05_oport_rdy_router0 | buf05_oport_rdy_router2;
assign buf06_oport_rdy               = buf06_oport_rdy_router2;              
assign buf07_oport_rdy               = buf07_oport_rdy_router2;
assign buf08_oport_rdy               = buf08_oport_rdy_router0;
assign buf09_oport_rdy               = buf09_oport_rdy_router0;

//******************* Connect 1toN  ******************//
wire [PE_OUT_DATA_SIZE-1:0]  buf07_iport_data_router3;
wire [PE_OUT_DATA_SIZE-1:0]  buf06_iport_data_router3;
wire [PE_OUT_DATA_SIZE-1:0]  buf05_iport_data_router3;
wire [PE_OUT_DATA_SIZE-1:0]  buf04_iport_data_router3;

wire [FE_OUT_DATA_SIZE-1:0]  buf09_iport_data_router4;
wire [FE_OUT_DATA_SIZE-1:0]  buf08_iport_data_router4;
wire [FE_OUT_DATA_SIZE-1:0]  buf01_iport_data_router4;
wire [FE_OUT_DATA_SIZE-1:0]  buf00_iport_data_router4;

wire    buf07_iport_vld_router3;
wire    buf06_iport_vld_router3;
wire    buf05_iport_vld_router3;
wire    buf04_iport_vld_router3;

wire    buf09_iport_vld_router4;
wire    buf08_iport_vld_router4;
wire    buf01_iport_vld_router4;
wire    buf00_iport_vld_router4;

assign  buf07_iport_vld_router3 = router3_oport_vld[7]; 
assign  buf06_iport_vld_router3 = router3_oport_vld[6];                   
assign  buf05_iport_vld_router3 = router3_oport_vld[5];                    
assign  buf04_iport_vld_router3 = router3_oport_vld[4];  

assign  buf07_iport_data_router3 = router3_oport_data[PE_OUT_DATA_SIZE*8-1:PE_OUT_DATA_SIZE*7]; 
assign  buf06_iport_data_router3 = router3_oport_data[PE_OUT_DATA_SIZE*7-1:PE_OUT_DATA_SIZE*6];                   
assign  buf05_iport_data_router3 = router3_oport_data[PE_OUT_DATA_SIZE*6-1:PE_OUT_DATA_SIZE*5];                    
assign  buf04_iport_data_router3 = router3_oport_data[PE_OUT_DATA_SIZE*5-1:PE_OUT_DATA_SIZE*4]; 

assign  router3_oport_rdy = {2'd0,buf07_iport_rdy,buf06_iport_rdy,buf05_iport_rdy,buf04_iport_rdy,4'd0};

assign  buf09_iport_vld_router4 = router4_oport_vld[9]; 
assign  buf08_iport_vld_router4 = router4_oport_vld[8];                   
assign  buf01_iport_vld_router4 = router4_oport_vld[1];                    
assign  buf00_iport_vld_router4 = router4_oport_vld[0];  

assign  buf09_iport_data_router4 = router4_oport_data[FE_OUT_DATA_SIZE*10-1:FE_OUT_DATA_SIZE*9]; 
assign  buf08_iport_data_router4 = router4_oport_data[FE_OUT_DATA_SIZE*9-1:FE_OUT_DATA_SIZE*8];                   
assign  buf01_iport_data_router4 = router4_oport_data[FE_OUT_DATA_SIZE*2-1:FE_OUT_DATA_SIZE*1];                    
assign  buf00_iport_data_router4 = router4_oport_data[FE_OUT_DATA_SIZE*1-1:FE_OUT_DATA_SIZE*0]; 

assign  router4_oport_rdy = {buf09_iport_rdy,buf08_iport_rdy,6'd0,buf01_iport_rdy,buf00_iport_rdy};

assign buf00_iport_vld = buf00_iport_vld_router4;              
assign buf01_iport_vld = buf01_iport_vld_router4;              
assign buf04_iport_vld = buf04_iport_vld_router3;              
assign buf05_iport_vld = buf05_iport_vld_router3;              
assign buf06_iport_vld = buf06_iport_vld_router3;              
assign buf07_iport_vld = buf07_iport_vld_router3;              
assign buf08_iport_vld = buf08_iport_vld_router4;
assign buf09_iport_vld = buf09_iport_vld_router4;          

assign buf00_iport_data = ({FE_OUT_DATA_SIZE{buf00_iport_vld_router4}} & buf00_iport_data_router4);
assign buf01_iport_data = ({FE_OUT_DATA_SIZE{buf01_iport_vld_router4}} & buf01_iport_data_router4);
assign buf04_iport_data = ({PE_OUT_DATA_SIZE{buf04_iport_vld_router3}} & buf04_iport_data_router3);
assign buf05_iport_data = ({PE_OUT_DATA_SIZE{buf05_iport_vld_router3}} & buf05_iport_data_router3);
assign buf06_iport_data = ({PE_OUT_DATA_SIZE{buf06_iport_vld_router3}} & buf06_iport_data_router3);
assign buf07_iport_data = ({PE_OUT_DATA_SIZE{buf07_iport_vld_router3}} & buf07_iport_data_router3);
assign buf08_iport_data = ({FE_OUT_DATA_SIZE{buf08_iport_vld_router4}} & buf08_iport_data_router4);
assign buf09_iport_data = ({FE_OUT_DATA_SIZE{buf09_iport_vld_router4}} & buf09_iport_data_router4);



endmodule

