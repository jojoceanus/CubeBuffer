module GROUP_INS_DECODER(
                       clk       ,
                       rst_n     ,

                   
                       group_cmd_vld  ,
                       group_cmd_rdy  ,
                       group_hit_flag ,
                       rw_flag        ,
                       bank_id        ,
                       bank_num       ,
                       access_num     ,
                       bit_select     ,
                       sram_addr      ,
                       padding_h      ,
                       group_in_data  ,
                   
                       dec_vld        ,
                       dec_rdy        ,
                       dec_hit_flag   ,
                       dec_addr       ,
                       dec_data       ,
                       dec_bit_select ,
                       dec_rw_flag    , //0 for read, 1 for write
                       dec_bank_id    ,
                       dec_bank_num   ,
                       dec_padding_h  ,
                       dec_access_num );

parameter  A_WIDTH = 12  ;
parameter  D_WIDTH = 16  ;
parameter  BANK_NUM= 17  ;

input                      clk       ;
input                      rst_n     ;


input                               group_cmd_vld  ;
output                              group_cmd_rdy  ;
input                               group_hit_flag ;
input                               rw_flag        ;
input     [4:0]                     bank_id        ;
input     [4:0]                     bank_num       ;
input     [6:0]                     access_num     ;
input     [1:0]                     bit_select     ;
input     [A_WIDTH-1:0]             sram_addr      ;
input     [5:0]                     padding_h      ;
input     [D_WIDTH*BANK_NUM-1:0]    group_in_data  ;

output                              dec_vld;
input                               dec_rdy;
output    [BANK_NUM-1:0]            dec_hit_flag;
output    [BANK_NUM*A_WIDTH-1:0]    dec_addr;
output    [BANK_NUM*D_WIDTH-1:0]    dec_data;
output    [1:0]                     dec_bit_select   ;
output    [5:0]                     dec_padding_h    ;
output                              dec_rw_flag      ; //0 for read, 1 for write
output    [4:0]                     dec_bank_id      ;
output    [4:0]                     dec_bank_num     ;
output    [6:0]                     dec_access_num   ;

wire      [5:0]                     last_bank_id_tmp;

reg       [BANK_NUM*A_WIDTH-1:0]    dec_addr_comb;
reg       [BANK_NUM*D_WIDTH-1:0]    dec_data_comb;
reg       [BANK_NUM-1:0]            bank_hit_flag_comb1  ;
wire      [BANK_NUM-1:0]            bank_hit_flag_comb  ;

assign last_bank_id_tmp   = {2'b0,bank_id} + {1'b0,bank_num} - 6'd1;
assign bank_hit_flag_comb = {BANK_NUM{group_hit_flag}} & bank_hit_flag_comb1;

genvar j;
generate 
    for(j=0;j<BANK_NUM;j=j+1)
    begin:genblk0
        always@(*)
        begin
            if(bank_num == 5'd0)
                bank_hit_flag_comb1[j] = 1'b0;
            else if(last_bank_id_tmp > BANK_NUM - 1 && ((j >= bank_id) || (j<=last_bank_id_tmp - BANK_NUM)))
                bank_hit_flag_comb1[j] = 1'b1;
            else if(last_bank_id_tmp < BANK_NUM && ((j >= bank_id) && (j <= last_bank_id_tmp)))
                bank_hit_flag_comb1[j] = 1'b1;
            else
                bank_hit_flag_comb1[j] = 1'b0;
        end
    end
endgenerate

genvar i;
generate 
    for(i=0;i<BANK_NUM;i=i+1)
    begin:genblk1
        always@(*)
        begin
            if(last_bank_id_tmp > BANK_NUM -1  && (i<=last_bank_id_tmp - BANK_NUM))
                dec_addr_comb[A_WIDTH*(i+1)-1:A_WIDTH*i] = sram_addr + 12'd1;
            else
                dec_addr_comb[A_WIDTH*(i+1)-1:A_WIDTH*i] = sram_addr;
        end
    end
endgenerate

generate
case(BANK_NUM)
    32'd8:
    begin: gc8
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                //5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                //5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                //5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                //5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                //5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                //5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                //5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                //5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                //5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                //5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd9:
    begin: gc9
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                //5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                //5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                //5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                //5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                //5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                //5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                //5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                //5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                //5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd10:
    begin: gc10
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                //5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                //5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                //5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                //5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                //5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                //5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                //5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                //5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd11:
    begin: gc11
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                //5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                //5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                //5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                //5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                //5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                //5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                //5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd12:
    begin: gc12
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                //5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                //5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                //5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                //5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                //5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                //5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd13:
    begin: gc13
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                //5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                //5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                //5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                //5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                //5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd14:
    begin: gc14
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                //5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                //5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                //5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                //5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd15:
    begin: gc15
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                //5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                //5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                //5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd16:
    begin: gc16
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                //5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                //5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd17:
    begin: gc17
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                //5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd18:
    begin: gc18
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                //5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd19:
    begin: gc19
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                //5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    32'd20:
    begin: gc20
        always@(*)
        begin
            case(bank_id)
                5'd1:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 1)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 1)]};
                5'd2:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 2)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 2)]};
                5'd3:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 3)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 3)]};
                5'd4:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 4)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 4)]};
                5'd5:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 5)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 5)]};
                5'd6:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 6)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 6)]};
                5'd7:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 7)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 7)]};
                5'd8:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 8)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 8)]};
                5'd9:      dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM- 9)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM- 9)]};
                5'd10:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-10)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-10)]};
                5'd11:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-11)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-11)]};
                5'd12:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-12)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-12)]};
                5'd13:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-13)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-13)]};
                5'd14:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-14)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-14)]};
                5'd15:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-15)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-15)]};
                5'd16:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-16)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-16)]};
                5'd17:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-17)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-17)]};
                5'd18:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-18)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-18)]};
                5'd19:     dec_data_comb ={group_in_data[D_WIDTH*(BANK_NUM-19)-1:0],group_in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*(BANK_NUM-19)]};
                default:   dec_data_comb = group_in_data;
            endcase
        end
    end
    endcase
endgenerate


// --------------------------------- modify end ---------------------------------

VLD_RDY_PIPE #(.DATA_WIDTH((A_WIDTH+D_WIDTH+1)*BANK_NUM + 26))
u_input_reg(
            .clk         (clk  ),             
            .rst_n       (rst_n),               
            .in_data_vld (group_cmd_vld),                     
            .in_data_rdy (group_cmd_rdy),                     
            .out_data_vld(dec_vld ),                      
            .out_data_rdy(dec_rdy ),                      
            .in_data     ({rw_flag      ,bank_id    ,bank_num    ,access_num  ,bank_hit_flag_comb,bit_select    ,dec_addr_comb,padding_h,dec_data_comb}), 
            .out_data    ({dec_rw_flag  ,dec_bank_id,dec_bank_num,dec_access_num  ,dec_hit_flag      ,dec_bit_select,dec_addr     ,dec_padding_h,dec_data}));

endmodule
