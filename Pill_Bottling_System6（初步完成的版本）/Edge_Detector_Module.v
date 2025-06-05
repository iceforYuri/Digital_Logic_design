module Edge_Detector_Module(
input in_clk,
input in_QD,
output reg out_pos_QD
);
reg pre_QD;

always@(posedge in_clk)
begin
	pre_QD <= in_QD; 
	out_pos_QD <= (in_QD && !pre_QD);
end
endmodule