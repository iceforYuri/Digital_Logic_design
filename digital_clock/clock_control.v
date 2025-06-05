module clock_control (
    input wire clk,
    input wire clk_1hz,
    input wire set_time,    // 时间调整键（按下后当前选中位+1）
    input wire rst_n,
    input wire [1:0] mode,  // 模式控制
    input wire [2:0] pos,   // 位置控制
    
    output reg [3:0] sec_ones,  // 秒个位
    output reg [2:0] sec_tens,  // 秒十位
    output reg [3:0] min_ones,  // 分个位
    output reg [2:0] min_tens,  // 分十位
    output reg [3:0] hour_ones, // 时个位
    output reg [1:0] hour_tens  // 时十位
);
    // 模式定义
    localparam NORMAL_MODE = 2'b00;
    localparam CLOCK_SET_MODE = 2'b01;
    
    // 时钟更新逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位时时间为00:00:00
            sec_ones <= 4'd0;
            sec_tens <= 3'd0;
            min_ones <= 4'd0;
            min_tens <= 3'd0;
            hour_ones <= 4'd0;
            hour_tens <= 2'd0;	
        end else begin
            // 处理时间调整 - 直接使用按键状态，不进行边沿检测
            if (mode == CLOCK_SET_MODE && set_time) begin
                case (pos)
                    3'd6: begin // 秒个位
                        if (sec_ones == 4'd9)
                            sec_ones <= 4'd0;
                        else
                            sec_ones <= sec_ones + 1'b1;
                    end
                    3'd5: begin // 秒十位
                        if (sec_tens == 3'd5)
                            sec_tens <= 3'd0;
                        else
                            sec_tens <= sec_tens + 1'b1;
                    end
                    3'd4: begin // 分个位
                        if (min_ones == 4'd9)
                            min_ones <= 4'd0;
                        else
                            min_ones <= min_ones + 1'b1;
                    end
                    3'd3: begin // 分十位
                        if (min_tens == 3'd5)
                            min_tens <= 3'd0;
                        else
                            min_tens <= min_tens + 1'b1;
                    end
                    3'd2: begin // 时个位
                        if (hour_tens == 2'd2 && hour_ones == 4'd3)
                            hour_ones <= 4'd0;
                        else if (hour_ones == 4'd9)
                            hour_ones <= 4'd0;
                        else
                            hour_ones <= hour_ones + 1'b1;
                    end
                    3'd1: begin // 时十位
                        if (hour_tens == 2'd2)
                            hour_tens <= 2'd0;
                        else
                            hour_tens <= hour_tens + 1'b1;
                        // 如果从1变为2，且小时个位>3，需要修正
                        if (hour_tens == 2'd1 && hour_ones > 4'd3)
                            hour_ones <= 4'd3;
                    end
                endcase
            end
            // 正常模式下时钟运行，只在clk_1hz上升沿时计数
            else if (mode!= CLOCK_SET_MODE&&clk_1hz) begin//就减去一个mode判断条件，多了9个资源
                // 秒个位进位
                if (sec_ones == 4'd9) begin
                    sec_ones <= 4'd0;
                    
                    // 秒十位进位
                    if (sec_tens == 3'd5) begin
                        sec_tens <= 3'd0;
                        
                        // 分个位进位
                        if (min_ones == 4'd9) begin
                            min_ones <= 4'd0;
                            
                            // 分十位进位
                            if (min_tens == 3'd5) begin
                                min_tens <= 3'd0;
                                
                                // 时位进位
                                if (hour_tens == 2'd2 && hour_ones == 4'd3) begin
                                    hour_tens <= 2'd0;
                                    hour_ones <= 4'd0;
                                end else if (hour_ones == 4'd9) begin
                                    hour_ones <= 4'd0;
                                    hour_tens <= hour_tens + 1'b1;
                                end else begin
                                    hour_ones <= hour_ones + 1'b1;
                                end
                            end else begin
                                min_tens <= min_tens + 1'b1;
                            end
                        end else begin
                            min_ones <= min_ones + 1'b1;
                        end
                    end else begin
                        sec_tens <= sec_tens + 1'b1;
                    end
                end else begin
                    sec_ones <= sec_ones + 1'b1;
                end
            end
        end
    end
endmodule