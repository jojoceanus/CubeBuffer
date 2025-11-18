module PHY_ADDR_INS_DECODER(
                       clk                        ,
                       rst_n                      ,
                   
                       sram_array_in_vld          ,
                       sram_array_in_rdy          ,
                       sram_array_in_rw_flag      ,
                       sram_array_in_group_id     ,
                       sram_array_in_group_num    ,
                       sram_array_in_bank_id      ,
                       sram_array_in_bank_num     ,
                       sram_array_in_access_num   ,
                       sram_array_in_bit_select   ,
                       sram_array_in_sram_addr    ,
                       sram_array_in_block_offset ,
                       sram_array_in_padding_h    ,
                       sram_array_in_padding_c    ,
                       sram_array_in_last_flag    ,
                       sram_array_in_data         ,

                       dec_vld                    ,
                       dec_rdy                    ,
                       dec_group_hit_flag         ,
                       dec_rw_flag                ,
                       dec_group_id               ,
                       dec_group_num              ,
                       dec_bank_id                ,
                       dec_bank_num               ,
                       dec_access_num             ,
                       dec_bit_select             ,
                       dec_group_addr             ,
                       dec_padding_h              ,
                       dec_padding_c              ,
                       dec_last_flag              ,
                       dec_data                   );

parameter  A_WIDTH = 12  ;
parameter  D_WIDTH = 16  ;
parameter  BANK_NUM= 17  ;
parameter  GROUP_NUM= 10  ;

input                      clk       ;
input                      rst_n     ;


input                                         sram_array_in_vld            ;
output                                        sram_array_in_rdy            ;
input                                         sram_array_in_rw_flag        ;
input                                         sram_array_in_last_flag      ;
input     [3:0]                               sram_array_in_group_id       ;
input     [3:0]                               sram_array_in_group_num      ;
input     [4:0]                               sram_array_in_bank_id        ;
input     [4:0]                               sram_array_in_bank_num       ;
input     [6:0]                               sram_array_in_access_num     ;
input     [1:0]                               sram_array_in_bit_select     ;
input     [5:0]                               sram_array_in_padding_h      ;
input     [5:0]                               sram_array_in_padding_c      ;
input     [A_WIDTH-1:0]                       sram_array_in_sram_addr      ;
input     [A_WIDTH-1:0]                       sram_array_in_block_offset   ;
input     [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]    sram_array_in_data           ;

output                                        dec_vld                    ;
input                                         dec_rdy                    ;
output   [GROUP_NUM-1:0]                      dec_group_hit_flag         ;
output                                        dec_rw_flag                ;
output                                        dec_last_flag              ;
output   [3:0]                                dec_group_id               ;
output   [3:0]                                dec_group_num              ;
output   [4:0]                                dec_bank_id                ;
output   [4:0]                                dec_bank_num               ;
output   [6:0]                                dec_access_num             ;
output   [1:0]                                dec_bit_select             ;
output   [5:0]                                dec_padding_h              ;
output   [5:0]                                dec_padding_c              ;
output   [A_WIDTH*GROUP_NUM-1:0]              dec_group_addr             ;
output   [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]     dec_data                   ;

wire      [4:0]                               last_group_id_tmp;
wire      [A_WIDTH-1:0]                       addr_offset      ;

reg       [GROUP_NUM*BANK_NUM*D_WIDTH-1:0]    dec_data_comb;
reg       [GROUP_NUM-1:0]                     group_hit_flag_comb  ;
reg       [A_WIDTH*GROUP_NUM-1:0]             group_addr_comb  ;

assign last_group_id_tmp   = {1'b0,sram_array_in_group_id} + {1'b0,sram_array_in_group_num} - 5'd1;
assign addr_offset         = sram_array_in_sram_addr + sram_array_in_block_offset;

genvar i;
generate 
    for(i=0;i<GROUP_NUM;i=i+1)
    begin:genblk0
        always@(*)
        begin
            if(last_group_id_tmp > GROUP_NUM-1 && (i<=last_group_id_tmp - GROUP_NUM))
                group_addr_comb[(i+1)*A_WIDTH-1:i*A_WIDTH] = addr_offset;
            else
                group_addr_comb[(i+1)*A_WIDTH-1:i*A_WIDTH] = sram_array_in_sram_addr;
        end
    end
endgenerate

genvar j;
generate 
    for(j=0;j<GROUP_NUM;j=j+1)
    begin:genblk1
        always@(*)
        begin
            if(sram_array_in_group_num == 0)
                group_hit_flag_comb[j] = 1'b0;
            else if(last_group_id_tmp > GROUP_NUM-1 && ((j>= sram_array_in_group_id) || (j<=last_group_id_tmp - GROUP_NUM)))
                group_hit_flag_comb[j] = 1'b1;
            else if(last_group_id_tmp < GROUP_NUM && ((j>= sram_array_in_group_id) && (j<=last_group_id_tmp)))
                group_hit_flag_comb[j] = 1'b1;
            else
                group_hit_flag_comb[j] = 1'b0;
        end
    end
endgenerate

generate
case(GROUP_NUM)
    32'd1:
    begin: gc1
        always@(*)
        begin
            dec_data_comb = sram_array_in_data;
        end
    end
    32'd2:
    begin: gc2
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                //5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                //5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                //5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                //5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                //5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                //5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                //5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                //5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                //5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                //5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd3:
    begin: gc3
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                //5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                //5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                //5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                //5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                //5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                //5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                //5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                //5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                //5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd4:
    begin: gc4
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                //5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                //5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                //5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                //5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                //5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                //5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                //5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                //5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd5:
    begin: gc5
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                //5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                //5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                //5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                //5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                //5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                //5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                //5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd6:
    begin: gc6
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                //5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                //5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                //5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                //5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                //5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                //5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd7:
    begin: gc7
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                //5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                //5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                //5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                //5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                //5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd8:
    begin: gc8
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                //5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                //5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                //5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                //5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd9:
    begin: gc9
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                //5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                //5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                //5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd10:
    begin: gc10
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                //5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                //5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd11:
    begin: gc11
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                //5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd12:
    begin: gc12
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                //5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd13:
    begin: gc13
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                //5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd14:
    begin: gc14
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                //5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd15:
    begin: gc15
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                //5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd16:
    begin: gc16
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                //5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd17:
    begin: gc17
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                //5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd18:
    begin: gc18
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                //5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd19:
    begin: gc19
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                //5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    32'd20:
    begin: gc20
        always@(*)
        begin
            case(sram_array_in_group_id)
                5'd1:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 1)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 1)]};
                5'd2:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 2)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 2)]};
                5'd3:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 3)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 3)]};
                5'd4:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 4)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 4)]};
                5'd5:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 5)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 5)]};
                5'd6:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 6)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 6)]};
                5'd7:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 7)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 7)]};
                5'd8:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 8)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 8)]};
                5'd9:      dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM- 9)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM- 9)]};
                5'd10:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-10)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-10)]};
                5'd11:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-11)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-11)]};
                5'd12:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-12)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-12)]};
                5'd13:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-13)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-13)]};
                5'd14:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-14)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-14)]};
                5'd15:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-15)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-15)]};
                5'd16:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-16)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-16)]};
                5'd17:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-17)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-17)]};
                5'd18:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-18)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-18)]};
                5'd19:     dec_data_comb ={sram_array_in_data[D_WIDTH*BANK_NUM*(GROUP_NUM-19)-1:0],sram_array_in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*(GROUP_NUM-19)]};
                default:   dec_data_comb = sram_array_in_data;
            endcase
        end
    end
    endcase
endgenerate

VLD_RDY_PIPE #(.DATA_WIDTH(41 + A_WIDTH*GROUP_NUM + D_WIDTH*BANK_NUM*GROUP_NUM + GROUP_NUM))
u_input_reg(
            .clk         (clk  ),             
            .rst_n       (rst_n),               
            .in_data_vld (sram_array_in_vld),                     
            .in_data_rdy (sram_array_in_rdy),                     
            .out_data_vld(dec_vld ),                      
            .out_data_rdy(dec_rdy ),                      
            .in_data     ({group_hit_flag_comb,sram_array_in_rw_flag,sram_array_in_group_id,sram_array_in_group_num,sram_array_in_bank_id,sram_array_in_bank_num,sram_array_in_access_num,sram_array_in_bit_select,group_addr_comb,dec_data_comb,sram_array_in_padding_h,sram_array_in_padding_c,sram_array_in_last_flag}), 
            .out_data    ({dec_group_hit_flag ,dec_rw_flag,dec_group_id,dec_group_num,dec_bank_id,dec_bank_num,dec_access_num,dec_bit_select,dec_group_addr,dec_data,dec_padding_h,dec_padding_c,dec_last_flag}));


endmodule
