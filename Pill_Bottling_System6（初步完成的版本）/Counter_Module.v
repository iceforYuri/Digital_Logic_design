module Counter_Module(
input in_clk,                     // ϵͳʱ������
input [1:0]in_state,
input in_suspend,                 // ��ͣ�����ź�(1=��ͣ��0=����)
input [5:0] in_target_bottle_num, 
input [5:0] in_target_pill_num,
output reg [5:0] out_bottle_num,  // ��ǰ��װ�õ�ҩƿ�������
output reg [5:0] out_pill_num,     // ��ǰҩƿ����װ���ҩƬ�������
output reg out_finish,
output reg out_next_bottle
);

parameter s_zero=2'b00,s_operation=2'b01,s_report=2'b11;

always@(posedge in_clk) 
begin
	case(in_state)
		//装瓶复位
		s_zero: begin
			out_bottle_num <= 6'b0;     
			out_pill_num <= 6'b0;
			out_next_bottle<=1'b0;
			out_finish<=1'b0; end
		s_operation: begin
			if(out_bottle_num==in_target_bottle_num)
			// 已完成
			begin
				out_finish<=1'b1;
				out_next_bottle<=1'b0;
			end
			else 
			begin
				if (out_pill_num == in_target_pill_num-1'b1) 
				// 当前瓶装满时
				begin
					out_bottle_num <=(in_suspend)?out_bottle_num: out_bottle_num + 1;
					out_pill_num <=(in_suspend)?out_pill_num: 0;
					out_next_bottle <= (in_suspend)?0:1;
					out_finish<=1'b0; 
				end			
				else 
				// 继续
				begin
					out_pill_num<=(in_suspend)?out_pill_num:out_pill_num+1'b1;
					out_next_bottle <= 0;
					out_finish<=1'b0; 
				end
			end
		end
		default:begin
			out_next_bottle<=0;
			out_finish<=1'b0;end
	endcase
end
endmodule