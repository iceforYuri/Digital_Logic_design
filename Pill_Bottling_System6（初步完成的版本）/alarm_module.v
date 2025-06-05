module alarm_module (
    input wire clk,      
    input wire rst_n,    
    input wire [7:0] current_count, 
    input wire [7:0] target_count, 
    input wire [15:0] freq_divider, 
    output reg alarm,     
    output reg buzzer     
);

reg [15:0] div_counter;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        alarm <= 1'b0;
        buzzer <= 1'b0;
        div_counter <= 16'b0;
    end else begin
        if (current_count == target_count) begin
            alarm <= 1'b1;
            if (div_counter == freq_divider) begin
                buzzer <= ~buzzer;
                div_counter <= 16'b0;
            end else begin
                div_counter <= div_counter + 1;
            end
        end else begin
            alarm <= 1'b0;
            buzzer <= 1'b0;
            div_counter <= 16'b0;
        end
    end
end

endmodule    