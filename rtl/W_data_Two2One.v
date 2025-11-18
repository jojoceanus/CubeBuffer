module W_data_Two2One#(
    parameter ID_bit = 0
)(
    input wire clk,
    input wire rst_n,
    input wire vld_0,
    input wire vld_1,
    input wire [127:0] data_out0,
    input wire [127:0] data_out1,
    input wire [11:0]select_input, 
    input wire selected_rdy,
    output  reg [128:0] selected_data,
    output  reg selected_vld,
    output  reg rdy_0,
    output  reg rdy_1,
    input wire vld_fifo
);
wire last;
reg [7:0] cnt;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n) 
        cnt <= 8'b0;    
    else if(cnt == select_input[11:4] & selected_vld & selected_rdy)begin
        cnt <= 8'b0;
    end
    else if(vld_0 & rdy_0 | vld_1 & rdy_1)
        cnt <= cnt + 1'b1;
end
assign last = (cnt == select_input[11:4])  & (selected_vld & selected_rdy) & vld_fifo;
always @(*) begin
    if (!rst_n) begin
        selected_data = 129'b0;   
        selected_vld = 1'b0;  
        rdy_0 = 1'b0;         
        rdy_1 = 1'b0;         
    end else begin
        if (!select_input[ID_bit] & vld_fifo) begin 
            if (vld_0) begin
                selected_data = {last,data_out0};
                selected_vld = 1'b1;
                rdy_0 = selected_rdy;
                rdy_1 = 1'b0;
            end else begin
                selected_data = 129'b0;
                selected_vld = 1'b0; 
                rdy_0 = 1'b0;
                rdy_1 = 1'b0;
            end
        end else  if (select_input[ID_bit] & vld_fifo) begin 
            if (vld_1) begin
                selected_data = {last,data_out1};
                selected_vld = 1'b1;
                rdy_0 = 1'b0;
                rdy_1 = selected_rdy;
            end else begin
                selected_data = 129'b0;
                selected_vld = 1'b0; 
                rdy_0 = 1'b0;
                rdy_1 = 1'b0;
            end
        end
        else begin
            selected_data = 129'b0;
            selected_vld = 1'b0; 
            rdy_0 = 1'b0;
            rdy_1 = 1'b0;
        end
    end
end

endmodule
