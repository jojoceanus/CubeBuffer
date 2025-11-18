module SRAM_DATA_REARRANGE(
                 clk                 ,
                 rst_n               ,
                                     
                 in_vld              ,
                 in_rdy              ,
                 group_id            ,
                 rw_flag             ,
                 padding_c           ,
                 last_flag           ,
                 in_data             ,
                 in_true_data_flag   ,
                                     
                 out_vld             ,
                 out_rdy             ,
                 out_last_flag       ,
                 out_data            );

parameter  D_WIDTH = 16  ;
parameter  BANK_NUM= 17  ;
parameter  GROUP_NUM= 10  ;

input                              clk                 ;
input                              rst_n               ;
                                        
input                              in_vld              ;
output                             in_rdy              ;
input   [3:0]                      group_id            ;
input                              rw_flag             ;
input   [5:0]                      padding_c           ;
input                              last_flag           ;
input   [GROUP_NUM-1:0]            in_true_data_flag   ;

input   [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]     in_data   ;
                                         
output                             out_vld             ;
input                              out_rdy             ;
output                             out_last_flag       ;

output  [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]     out_data  ;

reg                                out_vld             ;
reg                                out_last_flag       ;

reg     [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]     out_data_tmp        ;
wire    [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]     out_data_tmp1       ;
reg     [GROUP_NUM*D_WIDTH*BANK_NUM-1:0]     out_data            ;

wire    out_true_data_flag_comb;

assign out_true_data_flag_comb = |in_true_data_flag;

// always@(*)
// begin
//     case({rw_flag,group_id})
//         5'h1 :    out_data_tmp = {in_data[ 1*D_WIDTH*BANK_NUM-1:0],in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1: 1*D_WIDTH*BANK_NUM]};
//         5'h2 :    out_data_tmp = {in_data[ 2*D_WIDTH*BANK_NUM-1:0],in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1: 2*D_WIDTH*BANK_NUM]};       
//         5'h3 :    out_data_tmp = {in_data[ 3*D_WIDTH*BANK_NUM-1:0],in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1: 3*D_WIDTH*BANK_NUM]};  
//         5'h4 :    out_data_tmp = {in_data[ 4*D_WIDTH*BANK_NUM-1:0],in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1: 4*D_WIDTH*BANK_NUM]};       
//         5'h5 :    out_data_tmp = {in_data[ 5*D_WIDTH*BANK_NUM-1:0],in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1: 5*D_WIDTH*BANK_NUM]};       
//         5'h6 :    out_data_tmp = {in_data[ 6*D_WIDTH*BANK_NUM-1:0],in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1: 6*D_WIDTH*BANK_NUM]};       
//         5'h7 :    out_data_tmp = {in_data[ 7*D_WIDTH*BANK_NUM-1:0],in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1: 7*D_WIDTH*BANK_NUM]};
//         5'h8 :    out_data_tmp = {in_data[ 8*D_WIDTH*BANK_NUM-1:0],in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1: 8*D_WIDTH*BANK_NUM]}; 
//         5'h9 :    out_data_tmp = {in_data[ 9*D_WIDTH*BANK_NUM-1:0],in_data[GROUP_NUM*BANK_NUM*D_WIDTH-1: 9*D_WIDTH*BANK_NUM]}; 		
//         default:  out_data_tmp =  in_data;
//     endcase
// end

generate
case(GROUP_NUM)
    32'd1:
    begin: gc1
        always@(*)
        begin
            out_data_tmp = in_data;
        end
    end
    32'd2:
    begin: gc2
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                //5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                //5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                //5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                //5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                //5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                //5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                //5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                //5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                //5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                //5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd3:
    begin: gc3
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                //5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                //5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                //5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                //5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                //5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                //5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                //5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                //5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                //5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd4:
    begin: gc4
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                //5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                //5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                //5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                //5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                //5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                //5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                //5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                //5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd5:
    begin: gc5
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                //5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                //5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                //5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                //5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                //5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                //5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                //5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd6:
    begin: gc6
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                //5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                //5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                //5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                //5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                //5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                //5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd7:
    begin: gc7
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                //5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                //5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                //5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                //5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                //5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd8:
    begin: gc8
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                //5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                //5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                //5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                //5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd9:
    begin: gc9
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                //5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                //5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                //5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd10:
    begin: gc10
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                //5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                //5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd11:
    begin: gc11
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                //5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd12:
    begin: gc12
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                //5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd13:
    begin: gc13
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                //5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd14:
    begin: gc14
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                //5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd15:
    begin: gc15
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                //5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd16:
    begin: gc16
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                //5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd17:
    begin: gc17
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                //5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd18:
    begin: gc18
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                //5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd19:
    begin: gc19
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                //5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    32'd20:
    begin: gc20
        always@(*)
        begin
            case(group_id)
                5'd1:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 1-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 1]};
                5'd2:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 2-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 2]};
                5'd3:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 3-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 3]};
                5'd4:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 4-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 4]};
                5'd5:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 5-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 5]};
                5'd6:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 6-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 6]};
                5'd7:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 7-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 7]};
                5'd8:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 8-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 8]};
                5'd9:      out_data_tmp ={in_data[D_WIDTH*BANK_NUM* 9-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM* 9]};
                5'd10:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*10-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*10]};
                5'd11:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*11-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*11]};
                5'd12:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*12-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*12]};
                5'd13:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*13-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*13]};
                5'd14:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*14-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*14]};
                5'd15:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*15-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*15]};
                5'd16:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*16-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*16]};
                5'd17:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*17-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*17]};
                5'd18:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*18-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*18]};
                5'd19:     out_data_tmp ={in_data[D_WIDTH*BANK_NUM*19-1:0],in_data[D_WIDTH*BANK_NUM*GROUP_NUM-1:D_WIDTH*BANK_NUM*19]};
                default:   out_data_tmp = in_data;
            endcase
        end
    end
    endcase
endgenerate

// always@(*)
// begin
//     case(padding_c)
//         6'd0 :    out_data_tmp1 = out_data_tmp;
//         6'd1 :    out_data_tmp1 = {out_data_tmp[ GROUP_NUM*D_WIDTH*BANK_NUM - 1*D_WIDTH*BANK_NUM-1:0],272'd0};
//         6'd2 :    out_data_tmp1 = {out_data_tmp[ GROUP_NUM*D_WIDTH*BANK_NUM - 2*D_WIDTH*BANK_NUM-1:0],544'd0};       
//         6'd3 :    out_data_tmp1 = {out_data_tmp[ GROUP_NUM*D_WIDTH*BANK_NUM - 3*D_WIDTH*BANK_NUM-1:0],816'd0};  
//         6'd4 :    out_data_tmp1 = {out_data_tmp[ GROUP_NUM*D_WIDTH*BANK_NUM - 4*D_WIDTH*BANK_NUM-1:0],1088'd0};       
//         6'd5 :    out_data_tmp1 = {out_data_tmp[ GROUP_NUM*D_WIDTH*BANK_NUM - 5*D_WIDTH*BANK_NUM-1:0],1360'd0};       
//         6'd6 :    out_data_tmp1 = {out_data_tmp[ GROUP_NUM*D_WIDTH*BANK_NUM - 6*D_WIDTH*BANK_NUM-1:0],1632'd0};       
//         6'd7 :    out_data_tmp1 = {out_data_tmp[ GROUP_NUM*D_WIDTH*BANK_NUM - 7*D_WIDTH*BANK_NUM-1:0],1904'd0}; 
//         6'd8 :    out_data_tmp1 = {out_data_tmp[ GROUP_NUM*D_WIDTH*BANK_NUM - 8*D_WIDTH*BANK_NUM-1:0],2176'd0}; 	
//         6'd9 :    out_data_tmp1 = {out_data_tmp[ GROUP_NUM*D_WIDTH*BANK_NUM - 9*D_WIDTH*BANK_NUM-1:0],2448'd0}; 		
//         default:  out_data_tmp1 = {GROUP_NUM*D_WIDTH*BANK_NUM{1'b0}};
//     endcase
// end

assign  out_data_tmp1 = out_data_tmp << (D_WIDTH*BANK_NUM*padding_c[3:0]);

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        out_vld <= 1'b0;
    else if(in_vld & in_rdy & ~rw_flag)
        out_vld <= 1'b1;
    else if(out_rdy)
        out_vld <= 1'b0;
end

assign in_rdy = rw_flag ? 1'b1 : (~out_vld || out_rdy);

always@(posedge clk)
    if(in_vld && in_rdy && ~rw_flag)
        out_data <= out_true_data_flag_comb ? out_data_tmp1 : {GROUP_NUM*D_WIDTH*BANK_NUM{1'b0}};

always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        out_last_flag <= 1'b0;
    else if(in_vld && in_rdy)
        out_last_flag <= last_flag;
end
endmodule


