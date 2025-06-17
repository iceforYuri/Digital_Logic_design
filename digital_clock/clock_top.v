module clock_top (
    input wire clk,          // 系统时钟
    input wire rst_n,        // 复位信号

    input wire set_clock,    // 设置时钟控制
    input wire set_alarm,    // 设置闹钟控制
    input wire set_shift_pre,    // 位置调整键
    input wire set_time_pre,     // 时间调整键

    output wire alarm_ring,         // 闹钟响铃
    output wire time_ring,          // 整点报时

    // 显示输出
    output wire sec_ten_zero,
    output wire min_ten_zero,
    output wire hour_ten_zero1,
    output wire hour_ten_zero2,
    
    output wire [6:0] seven_led,  // 秒个位七段LED输出
    output wire [2:0] display_sec_tens,
    output wire [3:0] display_min_ones,
    output wire [2:0] display_min_tens,
    output wire [3:0] display_hour_ones,
    output wire [1:0] display_hour_tens,
    output wire speaker
);
    wire clk_1hz;          // 1Hz时钟信号
    wire clk_2hz;          // 2Hz时钟信号
    wire set_shift;       // 位置调整信号
    wire set_time;        // 时间调整信号

    wire [1:0] mode;       // 模式控制
    wire [2:0] pos;        // 位置控制
    
    // 时钟数据
    wire [3:0] sec_ones;
    wire [3:0] min_ones;
    wire [3:0] hour_ones;
    wire [2:0] sec_tens;
    wire [2:0] min_tens;
    wire [1:0] hour_tens;
    
    // 闹钟数据
    wire [1:0] alarm_hour_tens;
    wire [3:0] alarm_hour_ones;
    wire [2:0] alarm_minute_tens;
    wire [3:0] alarm_minute_ones;
    // wire [2:0] alarm_second_tens;
    // wire [3:0] alarm_second_ones;
    
    
    // 实例化1Hz时钟分频器 (修复语法错误)
    Hz_12 u_Hz(
        .clk(clk),
        .clk_1hz(clk_1hz),
        .clk_2hz(clk_2hz),
    );


    key_handle u_key_handle(
        .clk(clk),
        .set_shift_pre(set_shift_pre),
        .set_time_pre(set_time_pre),
        .set_shift(set_shift),
        .set_time(set_time),
    );
    // 模式控制模块，分为设置时钟、设置闹钟和正常模式
    mode_control u_mode_controller(
        .clk(clk),
        .rst_n(rst_n),
        .set_clock(set_clock),
        .set_alarm(set_alarm),
        .set_shift(set_shift),
        .mode(mode),
        .pos(pos)
    );

    // 时钟控制模块
    clock_control u_clock_controller(
        .clk(clk),
        .clk_1hz(clk_1hz),
        .set_time(set_time),
        .rst_n(rst_n),
        .mode(mode),
        .pos(pos),
        .sec_ones(sec_ones),
        .sec_tens(sec_tens),
        .min_ones(min_ones),
        .min_tens(min_tens),
        .hour_ones(hour_ones),
        .hour_tens(hour_tens)
    );

    // 闹钟控制模块
    alarm_control u_alarm_controller(
        .clk(clk),
        .rst_n(rst_n),
        .clk_1hz(clk_1hz),         // 注意这里与注释中不同
        .set_time(set_time),       // 添加了时间调整信号
        .mode(mode),
        .pos(pos),
        .hour_tens(hour_tens),
        .hour_ones(hour_ones),
        .minute_tens(min_tens),
        .minute_ones(min_ones),
        .second_tens(sec_tens),
        .second_ones(sec_ones),
        .alarm_hour_tens(alarm_hour_tens),
        .alarm_hour_ones(alarm_hour_ones),
        .alarm_minute_tens(alarm_minute_tens),
        .alarm_minute_ones(alarm_minute_ones),
        .alarm_ring(alarm_ring),
        .time_ring(time_ring)
    );
    
    
    ring u_ring(
		.clk(clk),
        .clk_1hz_posedge(clk_1hz),
		.ring1(alarm_ring),
		.ring2(time_ring),
        .tone_divide(tone_divide),
		.speaker(speaker)
	);

    // 显示控制模块
display_control u_display_controller(
    .clk(clk),
    .rst_n(rst_n),
    .mode(mode),
    .sec_ones(sec_ones),
    .sec_tens(sec_tens),
    .min_ones(min_ones),
    .min_tens(min_tens),
    .hour_ones(hour_ones),
    .hour_tens(hour_tens),
    .alarm_hour_tens(alarm_hour_tens),
    .alarm_hour_ones(alarm_hour_ones),
    .alarm_minute_tens(alarm_minute_tens),
    .alarm_minute_ones(alarm_minute_ones),
    .pos(pos),
    .sec_ten_zero(sec_ten_zero),
    .min_ten_zero(min_ten_zero),
    .hour_ten_zero1(hour_ten_zero1),
    .hour_ten_zero2(hour_ten_zero2),
    .clk_1hz(clk_1hz),
    .clk_2hz(clk_2hz),
    .seven_led(seven_led),
    .display_sec_tens(display_sec_tens),
    .display_min_ones(display_min_ones),
    .display_min_tens(display_min_tens),
    .display_hour_ones(display_hour_ones),
    .display_hour_tens(display_hour_tens)
);
endmodule