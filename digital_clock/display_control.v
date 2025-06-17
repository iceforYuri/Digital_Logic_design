module display_control(
    input wire clk,
    input wire rst_n,
    input wire [1:0] mode,         // 模式：00-正常，01-设置时钟，10-设置闹钟
    
    // 时钟数据
    input wire [3:0] sec_ones,
    input wire [2:0] sec_tens,
    input wire [3:0] min_ones,
    input wire [2:0] min_tens,
    input wire [3:0] hour_ones,
    input wire [1:0] hour_tens,
    
    // 闹钟数据
    input wire [1:0] alarm_hour_tens,
    input wire [3:0] alarm_hour_ones,
    input wire [2:0] alarm_minute_tens,
    input wire [3:0] alarm_minute_ones,
    // input wire [2:0] alarm_second_tens,
    // input wire [3:0] alarm_second_ones,
    
    input wire [2:0] pos,          // 当前位置
    input wire clk_1hz,            // 1Hz时钟
    input wire clk_2hz,            // 2Hz时钟
    
    // 零位抑制控制
    output wire sec_ten_zero,      // 秒十位为0时置1
    output wire min_ten_zero,      // 分十位为0时置1
    output wire hour_ten_zero1,    // 时十位为0时置1(显示时)
    output wire hour_ten_zero2,    // 时十位为0时置1(设置时)
    
    // 显示输出
    output reg [6:0] seven_led,    // 秒个位七段LED
    output reg [2:0] display_sec_tens,
    output reg [3:0] display_min_ones,
    output reg [2:0] display_min_tens,
    output reg [3:0] display_hour_ones,
    output reg [1:0] display_hour_tens
);
    // 模式定义
    localparam NORMAL_MODE = 2'b00;
    localparam CLOCK_SET_MODE = 2'b01;
    localparam ALARM_SET_MODE = 2'b10;
    
    // 闪烁常量定义
    localparam BCD_BLANK = 4'd15;  // BCD码闪烁时的显示值
    

    
    // 闪烁使能信号 - 当处于设置模式且为选中位时有效
    wire blink_enable = (mode != NORMAL_MODE) && clk_2hz;
    
    // 位置对应的闪烁控制 (1为闪烁)
    wire hour_tens_blink = blink_enable && (pos == 3'd1);
    wire hour_ones_blink = blink_enable && (pos == 3'd2);
    wire min_tens_blink = blink_enable && (pos == 3'd3);
    wire min_ones_blink = blink_enable && (pos == 3'd4);
    wire sec_tens_blink = blink_enable && (pos == 3'd5);
    wire sec_ones_blink = blink_enable && (pos == 3'd6);
    
    // 零位抑制 - 特定位为0时输出1
    assign sec_ten_zero = ((mode == NORMAL_MODE) ? 3'd0 : ((pos == 3'd5)&&sec_tens_blink));
    assign min_ten_zero = ((mode == NORMAL_MODE) ? 3'd0 : ((pos == 3'd3)&&min_tens_blink));
    assign hour_ten_zero1 = ((mode == NORMAL_MODE) ? 2'd0 : ((pos == 3'd1)&&hour_tens_blink));
    assign hour_ten_zero2 = ((mode == NORMAL_MODE) ? 2'd0 : ((pos == 3'd1)&&hour_tens_blink));
    
    // 7段译码器 - 将BCD码转为7段显示码（低电平有效）
    function [6:0] bcd_to_seg;
        input [3:0] bcd;
        begin
            case (bcd)
                4'd0: bcd_to_seg = 7'b0111111; // 0
				4'd1: bcd_to_seg = 7'b0000110; // 1
				4'd2: bcd_to_seg = 7'b1011011; // 2
				4'd3: bcd_to_seg = 7'b1001111; // 3
				4'd4: bcd_to_seg = 7'b1100110; // 4
				4'd5: bcd_to_seg = 7'b1101101; // 5
				4'd6: bcd_to_seg = 7'b1111100; // 6
				4'd7: bcd_to_seg = 7'b0000111; // 7
				4'd8: bcd_to_seg = 7'b1111111; // 8
				4'd9: bcd_to_seg = 7'b1100111; // 9
                default: bcd_to_seg = 7'b0000000; // 全灭
            endcase
        end
    endfunction
    
    // 秒个位显示 - 七段译码
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seven_led <= 7'b1000000; // 显示0
        end else begin
            // 秒个位显示 - 根据模式选择数据源
            if (mode == ALARM_SET_MODE)
                // 闹钟模式 - 闪烁时熄灭，否则显示闹钟值
                seven_led <= sec_ones_blink ? 7'b0000000 : bcd_to_seg(4'b0); // 闹钟秒个位为0
            else 
                // 普通或设置时钟模式 - 闪烁时熄灭，否则显示时钟值
                seven_led <= sec_ones_blink ? 7'b0000000 : bcd_to_seg(sec_ones);
        end
    end
    
    // 其他位显示 - 直接输出BCD
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            display_sec_tens <= 3'd0;
            display_min_ones <= 4'd0;
            display_min_tens <= 3'd0;
            display_hour_ones <= 4'd0;
            display_hour_tens <= 2'd0;
        end else begin
            // 秒十位 (3位转为4位BCD码输出，闪烁时为全1)
            if (mode == ALARM_SET_MODE)
                display_sec_tens <= 4'd0; // 闹钟模式下不显示秒十位
            else
                display_sec_tens <= sec_tens_blink ? BCD_BLANK[2:0] : sec_tens;
                
            // 分个位 (本身就是4位BCD码)
            if (mode == ALARM_SET_MODE)
                display_min_ones <= min_ones_blink ? BCD_BLANK : alarm_minute_ones;
            else
                display_min_ones <= min_ones_blink ? BCD_BLANK : min_ones;
                
            // 分十位 (3位转为4位BCD码输出，闪烁时为全1)
            if (mode == ALARM_SET_MODE)
                display_min_tens <= min_tens_blink ? BCD_BLANK[2:0] : alarm_minute_tens;
            else
                display_min_tens <= min_tens_blink ? BCD_BLANK[2:0] : min_tens;
                
            // 时个位 (本身就是4位BCD码)
            if (mode == ALARM_SET_MODE)
                display_hour_ones <= hour_ones_blink ? BCD_BLANK : alarm_hour_ones;
            else
                display_hour_ones <= hour_ones_blink ? BCD_BLANK : hour_ones;
                
            // 时十位 (2位转为4位BCD码输出，闪烁时为全1)
            if (mode == ALARM_SET_MODE)
                display_hour_tens <= hour_tens_blink ? BCD_BLANK[1:0] : alarm_hour_tens;
            else
                display_hour_tens <= hour_tens_blink ? BCD_BLANK[1:0] : hour_tens;
        end
    end
    
endmodule