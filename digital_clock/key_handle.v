module key_handle(
    input wire clk,             // 系统时钟
    input wire set_shift_pre,   // 位置调整键脉冲信号
    input wire set_time_pre,    // 时间调整键脉冲信号
    output reg set_shift,       // 位置调整键电平信号
    output reg set_time         // 时间调整键电平信号
);
    //将上升沿转换成一次一个时钟周期的电平信号
    // 信号延时一周期
    reg set_shift_pre_r;
    always @(posedge clk) begin
        set_shift_pre_r <= set_shift_pre;
    end
    //// 检测上升沿：当前为高电平且前一个时钟周期为低电平
    wire set_shift_pos = set_shift_pre & (~set_shift_pre_r); 

    reg set_time_pre_r;
    always @(posedge clk) begin
        set_time_pre_r <= set_time_pre;
    end
    wire set_time_pos = set_time_pre & (~set_time_pre_r); // 上升沿检测
    
    // 将上升沿转换为电平信号
    always @(posedge clk) begin
        if(set_shift_pos)
            set_shift <= 1'b1;
        else
            set_shift <= 1'b0;
    end
    
    always @(posedge clk) begin
        if(set_time_pos)
            set_time <= 1'b1;
        else
            set_time <= 1'b0;
    end

endmodule