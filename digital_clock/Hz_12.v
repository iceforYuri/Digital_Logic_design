module Hz_12 (
    input  wire clk,       // 输入时钟 (1kHz)
    output reg clk_1hz,    // 1Hz 输出
    output reg clk_2hz     // 2Hz 输出
);
    reg [9:0] counter;
    
    // 使用单个计数器为两个时钟分频
    always @(posedge clk) begin
        clk_1hz <= 1'b0; 
        if (counter >= 10'd999) begin
            counter <= 10'd0;
            // 1Hz 时钟脉冲赋值
            clk_1hz <= 1'b1;
            // 2Hz 时钟电平翻转
            clk_2hz <= ~clk_2hz;
        end else if (counter == 10'd499) begin
            clk_2hz <= ~clk_2hz;
            counter <= counter + 1'b1;
        end else begin
            counter <= counter + 1'b1;
        end
    end
    
    // 初始化
    initial begin
        counter = 10'd0;
        clk_1hz = 1'b0;
        clk_2hz = 1'b0;
    end
    
endmodule