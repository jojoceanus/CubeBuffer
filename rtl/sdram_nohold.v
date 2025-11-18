module sdram_nohold (CLK, 
              WEN, 
              WA, 
              WD, 
              REN, 
              RA, 
              RD);

parameter DATA_WIDTH = 17;
parameter DATA_DEPTH = 1024;
parameter ADD_WIDTH  = 10;

input  CLK;

input                    WEN;
input  [ADD_WIDTH-1:0]   WA;
input  [DATA_WIDTH-1:0]  WD;

input                    REN;
input  [ADD_WIDTH-1:0]   RA;
output [DATA_WIDTH-1:0]  RD;

reg  [DATA_WIDTH-1:0]  mem_data [0:DATA_DEPTH-1];
reg  [DATA_WIDTH-1:0]  RD;

always@(posedge CLK)
begin
    if(WEN)
        mem_data[WA] <= WD;
end
   
always@(posedge CLK)
begin
    if(REN)
        RD <= mem_data[RA] ;
    else
        RD <= 'bx ;
end

endmodule


