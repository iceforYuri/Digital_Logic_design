module mode_control (
    input wire clk,
    input wire rst_n,
    input wire set_clock,    // 设置时钟控制
    input wire set_alarm,    // 设置闹钟控制
    input wire set_shift,    // 位置调整键
    output reg [1:0] mode,   // 模式：00-正常，01-设置时钟，10-设置闹钟
    output reg [2:0] pos     // 位置：0-时十位，1-时个位，2-分十位，3-分个位，4-秒十位，5-秒个位
);
    // 模式定义
    localparam NORMAL_MODE = 2'b00;
    localparam CLOCK_SET_MODE = 2'b01;
    localparam ALARM_SET_MODE = 2'b10;
    
    // 模式切换逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mode <= NORMAL_MODE;
        end else begin
            if (set_clock) begin
                mode <= CLOCK_SET_MODE;
            end else if (set_alarm) begin
                mode <= ALARM_SET_MODE;
            end else if (!set_clock && !set_alarm && (mode != NORMAL_MODE)) begin
                mode <= NORMAL_MODE;
            end
            else
            begin
                // 保持当前模式
                mode <= mode;

            end
        end
    end
    
    // 位置控制逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pos <= 3'd0;
        end else if (mode == NORMAL_MODE) begin
            pos <= 3'd0;
        end else if (set_shift) begin
            // 在设置模式下，按下位置调整键循环切换位置
            if(mode == CLOCK_SET_MODE)
            begin
            if (pos <= 3'd0)
                pos <= 3'd6;
            else
                pos <= pos - 1'b1;
            end
            else
            begin
            if (pos <= 3'd0)
                pos <= 3'd4;
            else
                pos <= pos - 1'b1;
            end
        end
    end
endmodule