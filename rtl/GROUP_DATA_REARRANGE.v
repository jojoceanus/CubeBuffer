module GROUP_DATA_REARRANGE(
                 clk                 ,
                 rst_n               ,

                 DW                  ,
                                     
                 in_vld              ,
                 in_rdy              ,
                 bank_id             ,
                 access_num          ,
                 bit_select          ,
                 in_data             ,
                 padding_h           ,
                 in_true_data_flag   ,
                                     
                 out_vld             ,
                 out_rdy             ,
                 out_true_data_flag  ,
                 out_data            );

parameter  D_WIDTH = 16  ;
parameter  BANK_NUM= 17  ;

input                              clk                 ;
input                              rst_n               ;

input   [1:0]                      DW                  ;
                                        
input                              in_vld              ;
output                             in_rdy              ;
input   [4:0]                      bank_id             ;
input   [6:0]                      access_num          ;
input   [1:0]                      bit_select          ;
input   [D_WIDTH*BANK_NUM-1:0]     in_data             ;
input   [5:0]                      padding_h           ;
input   [BANK_NUM-1:0]             in_true_data_flag   ;
                                         
output                             out_vld             ;
input                              out_rdy             ;
output                             out_true_data_flag  ;
output  [D_WIDTH*BANK_NUM-1:0]     out_data            ;

reg     [D_WIDTH*BANK_NUM-1:0]     group_data_shfit_by_bank       ;
reg     [D_WIDTH*BANK_NUM-1:0]     group_data_shfit_by_item       ;
reg     [D_WIDTH*BANK_NUM-1:0]     group_data_mask_by_access_num       ;
reg     [D_WIDTH*BANK_NUM-1:0]     group_data_after_padding       ;
reg     [D_WIDTH*BANK_NUM-1:0]     out_data            ;
reg                                out_vld             ;

wire out_true_data_flag_comb;
reg  out_true_data_flag;
assign out_true_data_flag_comb = |in_true_data_flag;

generate
case(BANK_NUM)
    32'd8:
    begin: gc8
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                //5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                //5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                //5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                //5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                //5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                //5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                //5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                //5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                //5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                //5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd9:
    begin: gc9
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                //5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                //5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                //5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                //5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                //5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                //5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                //5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                //5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                //5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd10:
    begin: gc10
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                //5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                //5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                //5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                //5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                //5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                //5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                //5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                //5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd11:
    begin: gc11
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                //5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                //5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                //5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                //5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                //5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                //5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                //5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd12:
    begin: gc12
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                //5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                //5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                //5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                //5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                //5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                //5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd13:
    begin: gc13
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                //5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                //5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                //5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                //5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                //5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd14:
    begin: gc14
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                //5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                //5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                //5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                //5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd15:
    begin: gc15
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                //5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                //5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                //5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd16:
    begin: gc16
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                //5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                //5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd17:
    begin: gc17
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                //5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd18:
    begin: gc18
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                //5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd19:
    begin: gc19
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                //5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    32'd20:
    begin: gc20
        always@(*)
        begin
            case(bank_id)
                5'd1:      group_data_shfit_by_bank ={in_data[D_WIDTH* 1-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 1]};
                5'd2:      group_data_shfit_by_bank ={in_data[D_WIDTH* 2-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 2]};
                5'd3:      group_data_shfit_by_bank ={in_data[D_WIDTH* 3-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 3]};
                5'd4:      group_data_shfit_by_bank ={in_data[D_WIDTH* 4-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 4]};
                5'd5:      group_data_shfit_by_bank ={in_data[D_WIDTH* 5-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 5]};
                5'd6:      group_data_shfit_by_bank ={in_data[D_WIDTH* 6-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 6]};
                5'd7:      group_data_shfit_by_bank ={in_data[D_WIDTH* 7-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 7]};
                5'd8:      group_data_shfit_by_bank ={in_data[D_WIDTH* 8-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 8]};
                5'd9:      group_data_shfit_by_bank ={in_data[D_WIDTH* 9-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH* 9]};
                5'd10:     group_data_shfit_by_bank ={in_data[D_WIDTH*10-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*10]};
                5'd11:     group_data_shfit_by_bank ={in_data[D_WIDTH*11-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*11]};
                5'd12:     group_data_shfit_by_bank ={in_data[D_WIDTH*12-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*12]};
                5'd13:     group_data_shfit_by_bank ={in_data[D_WIDTH*13-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*13]};
                5'd14:     group_data_shfit_by_bank ={in_data[D_WIDTH*14-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*14]};
                5'd15:     group_data_shfit_by_bank ={in_data[D_WIDTH*15-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*15]};
                5'd16:     group_data_shfit_by_bank ={in_data[D_WIDTH*16-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*16]};
                5'd17:     group_data_shfit_by_bank ={in_data[D_WIDTH*17-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*17]};
                5'd18:     group_data_shfit_by_bank ={in_data[D_WIDTH*18-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*18]};
                5'd19:     group_data_shfit_by_bank ={in_data[D_WIDTH*19-1:0],in_data[D_WIDTH*BANK_NUM-1:D_WIDTH*19]};
                default:   group_data_shfit_by_bank = in_data;
            endcase
        end
    end
    endcase
endgenerate





always@(*)
begin
    if(DW == 2'b00)  // DW = 4bit
    begin
       case(bit_select)
           2'b00:    group_data_shfit_by_item = group_data_shfit_by_bank;
           2'b01:    group_data_shfit_by_item = { 4'b0,group_data_shfit_by_bank[D_WIDTH*BANK_NUM-1: 4]};
           2'b10:    group_data_shfit_by_item = { 8'b0,group_data_shfit_by_bank[D_WIDTH*BANK_NUM-1: 8]};
           2'b11:    group_data_shfit_by_item = {12'b0,group_data_shfit_by_bank[D_WIDTH*BANK_NUM-1:12]};
           default:  group_data_shfit_by_item = group_data_shfit_by_bank;
       endcase
    end
    else if (DW == 2'b01)   //DW = 8bit
    begin
        if(bit_select == 2'b00)
            group_data_shfit_by_item = group_data_shfit_by_bank;
        else 
            group_data_shfit_by_item = {8'b0,group_data_shfit_by_bank[D_WIDTH*BANK_NUM-1:8]};
    end
    else //DW = 16bit
    begin
        group_data_shfit_by_item = group_data_shfit_by_bank;
    end
end

wire [D_WIDTH*BANK_NUM-1:0] group_data_mask_by_access_num_DW00;
wire [D_WIDTH*BANK_NUM-1:0] group_data_mask_by_access_num_DW01;
wire [D_WIDTH*BANK_NUM-1:0] group_data_mask_by_access_num_DW10;
wire [D_WIDTH*BANK_NUM-1:0] group_data_after_padding_DW00;
wire [D_WIDTH*BANK_NUM-1:0] group_data_after_padding_DW01;
wire [D_WIDTH*BANK_NUM-1:0] group_data_after_padding_DW10;

genvar gj;
generate
    for (gj = 0; gj < BANK_NUM * 4; gj = gj + 1) begin: GEN_GROUP_DATA_MASK_BY_ACCESS_NUM_DW00
        assign group_data_mask_by_access_num_DW00[4*(gj+1)-1:4*gj] = (gj >= access_num) ? 4'b0 : group_data_shfit_by_item[4*(gj+1)-1:4*gj];
    end
endgenerate

genvar gk;
generate
    for (gk = 0; gk < BANK_NUM * 2; gk = gk + 1) begin: GEN_GROUP_DATA_MASK_BY_ACCESS_NUM_DW01
        assign group_data_mask_by_access_num_DW01[8*(gk+1)-1:8*gk] = (gk >= access_num) ? 8'b0 : group_data_shfit_by_item[8*(gk+1)-1:8*gk];
    end 
endgenerate

genvar gm;
generate
    for (gm = 0; gm < BANK_NUM    ; gm = gm + 1) begin: GEN_GROUP_DATA_MASK_BY_ACCESS_NUM_DW10
        assign group_data_mask_by_access_num_DW10[16*(gm+1)-1:16*gm] = (gm >= access_num) ? 16'b0 : group_data_shfit_by_item[16*(gm+1)-1:16*gm];
    end 
endgenerate

assign group_data_after_padding_DW00    = group_data_mask_by_access_num << (padding_h[3:0]* 4);
assign group_data_after_padding_DW01    = group_data_mask_by_access_num << (padding_h[3:0]* 8);
assign group_data_after_padding_DW10    = group_data_mask_by_access_num << (padding_h[3:0]*16);


always@(*)
begin
// --------------------------------- modify by gyp ---------------------------------
    group_data_mask_by_access_num = group_data_shfit_by_item;
// --------------------------------- modify end ---------------------------------
    if(DW == 2'b00)  // DW = 4bit
    begin
        group_data_mask_by_access_num = group_data_mask_by_access_num_DW00;
        group_data_after_padding      = group_data_after_padding_DW00;
    end
    else if (DW == 2'b01)   //DW = 8bit
    begin
        group_data_mask_by_access_num = group_data_mask_by_access_num_DW01;
        group_data_after_padding      = group_data_after_padding_DW01;
    end       
    else //DW = 16bit
    begin
        group_data_mask_by_access_num = group_data_mask_by_access_num_DW10;
        group_data_after_padding      = group_data_after_padding_DW10;
    end
end

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        out_vld <= 1'b0;
    else if(in_vld)
        out_vld <= 1'b1;
    else if(out_rdy)
        out_vld <= 1'b0;
end

assign in_rdy = ~out_vld || out_rdy;

always@(posedge clk)
    if(in_vld && in_rdy)
    begin
        out_data           <= group_data_after_padding;
        out_true_data_flag <= out_true_data_flag_comb;
    end

endmodule

