module Modify_Setting_Module(
input [1:0]in_display_state,
input in_display_setting,
input in_CLR,
input in_PULSE,
input in_inc_five,
output reg [1:0]out_flash,
output reg [5:0]out_target_bottle_num,
output reg [5:0]out_target_pill_num
);

parameter d_standard=2'b00,d_setting_bottle=2'b01,d_setting_pill=2'b11;
parameter s_zero=2'b00,s_operation=2'b01,s_report=2'b11;

always@(*)
begin
	case(in_display_state)
		d_standard:begin
			out_flash=2'b00;end
		d_setting_bottle:begin
			out_flash=2'b10;end
		d_setting_pill:begin
			out_flash=2'b01;end
		default:begin
			out_flash=2'b00;end
	endcase
end

always @(posedge in_PULSE,negedge in_CLR)
begin
    if (!in_CLR) begin
        out_target_bottle_num <= (in_display_setting && (in_display_state == d_setting_bottle) ) ? 0 : out_target_bottle_num;
        out_target_pill_num   <= (in_display_setting && (in_display_state == d_setting_pill) ) ? 0 : out_target_bottle_num;
    end else begin
		out_target_bottle_num <= 
			(in_display_setting && (in_display_state == d_setting_bottle)) ? ((in_inc_five)?out_target_bottle_num+5:out_target_bottle_num + 1): out_target_bottle_num;
		out_target_pill_num   <= 
			(in_display_setting && (in_display_state == d_setting_pill))   ? ((in_inc_five)?out_target_pill_num + 5:out_target_pill_num+1)   : out_target_pill_num;
	end
end
	
/*
always @(posedge in_PULSE , negedge in_CLR) begin
    out_target_bottle_num <= (!in_CLR) ? 0 : ((in_display_setting && (in_display_state == d_setting_bottle)) ? out_target_bottle_num + 1 : out_target_bottle_num);
    out_target_pill_num   <= (!in_CLR) ? 0 : ((in_display_setting && (in_display_state == d_setting_pill))   ? out_target_pill_num + 1   : out_target_pill_num);
end
*/

	/*
always @(posedge in_PULSE)
begin
		out_target_bottle_num <= 
			(in_display_setting && (in_display_state == d_setting_bottle)) ? ((in_inc_five)?out_target_bottle_num+5:out_target_bottle_num + 1): out_target_bottle_num;
		out_target_pill_num   <= 
			(in_display_setting && (in_display_state == d_setting_pill))   ? ((in_inc_five)?out_target_pill_num + 5:out_target_pill_num+1)   : out_target_pill_num;
end
*/

endmodule
