module alarm_control (
    input wire clk,
    input wire rst_n,
    input wire clk_1hz,           // 1Hz 时刻脉冲信号
    input wire set_time,          // 时间调整键
    input wire [1:0] mode,        // 模式控制
    input wire [2:0] pos,         // 位置控制

    // 当前时钟值
    input wire [1:0] hour_tens,
    input wire [3:0] hour_ones,
    input wire [2:0] minute_tens,
    input wire [3:0] minute_ones,
    input wire [2:0] second_tens,
    input wire [3:0] second_ones,

    // 闹钟设置值输出
    output reg [1:0] alarm_hour_tens,
    output reg [3:0] alarm_hour_ones,
    output reg [2:0] alarm_minute_tens,
    output reg [3:0] alarm_minute_ones,
    // output reg [2:0] alarm_second_tens,
    // output reg [3:0] alarm_second_ones,
    // output reg alarm_set, // 闹钟设置标志

    // 闹钟响铃和整点报时输出
    output reg alarm_ring,
    output reg time_ring
);
    localparam NORMAL_MODE = 2'b00; // 假设正常模式是 00
    localparam ALARM_SET_MODE = 2'b10;

    // 移除计数器 reg [3:0] alarm_counter;
    // 移除计数器 reg [3:0] time_counter;

    // 状态寄存器，用于保持响铃/报时状态一秒
    reg alarm_set = 1'b0; // 闹钟设置标志
    reg alarm_ring_active = 1'b0;
    reg time_ring_active = 1'b0;

    // // 闹钟有效标志 (保持不变)
    // wire alarm_valid = ((alarm_hour_tens < 2'd2) ||
    //                 (alarm_hour_tens == 2'd2 && alarm_hour_ones <= 4'd3)) &&
    //                 (alarm_minute_tens <= 3'd5) &&
    //                 (alarm_minute_ones <= 4'd9) &&
    //                 (alarm_second_tens <= 3'd5) &&
    //                 (alarm_second_ones <= 4'd9);

    // 闹钟设置逻辑 (保持不变)
    always @(posedge clk or negedge rst_n) begin
        // ... (内容不变) ...
        if (!rst_n) begin
            // 复位闹钟设置为非法值(25:00:00)，确保初始未设置时不会响
            alarm_hour_tens <= 2'd0;
            alarm_hour_ones <= 4'd0;
            alarm_minute_tens <= 3'd0;
            alarm_minute_ones <= 4'd0;
            // alarm_second_tens <= 3'd0;
            // alarm_second_ones <= 4'd0;
            alarm_set <= 1'b0; // 复位闹钟设置标志
        // ...
        end
        // else if (mode == NORMAL_MODE && alarm_set == 1'b0)//这里能占3个
        // begin
        //     alarm_hour_ones <= hour_ones; // 直接使用当前时钟值
        //     alarm_hour_tens <= hour_tens; // 直接使用当前时钟值
        //     alarm_minute_ones <= minute_ones; // 直接使用当前时钟值
        //     alarm_minute_tens <= minute_tens; // 直接使用当前时钟值
        // end
        else if(mode == ALARM_SET_MODE && pos == 3'd0)begin
            alarm_hour_ones <= hour_ones; // 直接使用当前时钟值
            alarm_hour_tens <= hour_tens; // 直接使用当前时钟值
            alarm_minute_ones <= minute_ones; // 直接使用当前时钟值
            alarm_minute_tens <= minute_tens; // 直接使用当前时钟值
        end
        else if (mode == ALARM_SET_MODE && set_time) begin
            // 在闹钟设置模式下，根据位置调整闹钟
            alarm_set <= 1'b1; // 设置闹钟标志
            case (pos) // pos 的值从 0 递增
            3'd1: begin // pos=0 对应 时十位
                if (alarm_hour_tens == 2'd2)
                    alarm_hour_tens <= 2'd0;
                else
                    alarm_hour_tens <= alarm_hour_tens + 1'd1;
                // 修正超出范围的小时值 (应该在设置时个位时处理更佳)
                // if (alarm_hour_tens == 2'd2 && alarm_hour_ones > 4'd3)
                //     alarm_hour_ones <= 4'd3;
            end
            3'd2: begin // pos=1 对应 时个位
                if (alarm_hour_tens == 2'd2 && alarm_hour_ones == 4'd3)
                    alarm_hour_ones <= 4'd0;
                else if (alarm_hour_ones == 4'd9)
                    alarm_hour_ones <= 4'd0;
                else
                    alarm_hour_ones <= alarm_hour_ones + 1'd1;
            end
            3'd3: begin // pos=2 对应 分十位
                if (alarm_minute_tens == 3'd5)
                    alarm_minute_tens <= 3'd0;
                else
                    alarm_minute_tens <= alarm_minute_tens + 1'd1;
            end
            3'd4: begin // pos=3 对应 分个位
                if (alarm_minute_ones == 4'd9)
                    alarm_minute_ones <= 4'd0;
                else
                    alarm_minute_ones <= alarm_minute_ones + 1'd1;
            end
            // 注意：如果已经移除了闹钟秒设置，pos 在 ALARM_SET_MODE 下不会等于 4 或 5
            // 如果仍然保留秒设置，则需要添加：
            /*
            3'd4: begin // pos=4 对应 秒十位
                if (alarm_second_tens == 3'd5)
                    alarm_second_tens <= 3'd0;
                else
                    alarm_second_tens <= alarm_second_tens + 1'd1;
            end
            3'd5: begin // pos=5 对应 秒个位
                if (alarm_second_ones == 4'd9)
                    alarm_second_ones <= 4'd0;
                else
                    alarm_second_ones <= alarm_second_ones + 1'd1;
            end
            */
            default: ; // 处理未预期的 pos 值
            endcase
        end
        else if(mode == NORMAL_MODE && alarm_set)
        begin
            if (hour_tens == alarm_hour_tens &&
                    hour_ones == alarm_hour_ones &&
                    minute_tens == alarm_minute_tens &&
                    minute_ones == alarm_minute_ones &&
                    // 根据是否设置闹钟秒来决定是否比较秒
                    second_tens == 3'b0 && // 比较秒十位
                    second_ones == 4'b0) begin // 比较秒个位
                    // 闹钟时间到达，清除设置标志 (响铃由第二个 always 块处理)
                    alarm_set <= 1'b0;
                end
        end
// ...
    end

    // 闹钟响铃和整点报时控制 - 使用状态寄存器和 clk_1hz 脉冲
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alarm_ring <= 1'b0;
            time_ring <= 1'b0;
            alarm_ring_active <= 1'b0; // 复位状态
            time_ring_active <= 1'b0; // 复位状态
        end else begin
            // 默认输出等于状态寄存器的值
            alarm_ring <= alarm_ring_active;
            time_ring <= time_ring_active;

            // 当 1Hz 脉冲到来时，清除激活状态
            if (clk_1hz) begin
                alarm_ring_active <= 1'b0;
                time_ring_active <= 1'b0;
            end

            // 检查触发条件 (这会覆盖同一时钟周期的 clk_1hz 清除操作，如果条件满足的话)
            if (mode == NORMAL_MODE) begin
                // 处理闹钟响铃触发
                if (
                    hour_tens == alarm_hour_tens &&
                    hour_ones == alarm_hour_ones &&
                    minute_tens == alarm_minute_tens &&
                    minute_ones == alarm_minute_ones &&
                    second_tens == 3'b0 &&
                    second_ones == 4'b0 &&
                    alarm_set) begin
                    alarm_ring_active <= 1'b1; // 激活闹钟状态
                end

                // 处理整点报时触发
                if (minute_tens == 3'd0 && minute_ones == 4'd0 &&
                    second_tens == 3'd0 && second_ones == 4'd0) begin
                    time_ring_active <= 1'b1; // 激活报时状态
                end
            end else begin
                // 在设置模式下，确保状态不被激活 (即使时间恰好匹配)
                // 并且如果因为模式切换导致 clk_1hz 没有清除状态，这里也强制清除
                 alarm_ring_active <= 1'b0;
                 time_ring_active <= 1'b0;
            end
        end
    end
endmodule