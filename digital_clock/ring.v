module ring(
    input wire clk,      // 时钟信号
    input wire clk_1hz_posedge,
    input wire ring1,
    input wire ring2,     // ring信号
    // output reg [1:0] tone_divide, // 音调分频器
    output reg speaker   // 扬声器控制信�?
    
);
    
    // 闹钟1k，最小频�?260 模最大约20  因此可以�?8�?
    reg [3:0] counter; 
    
    // 音调   时钟假设10kHz，此时音�?3 对应330
    reg [1:0] tone_divide;

    reg ban;
    reg ring;
    // reg [1:0] tone_timer; // 计时

    reg ring1_active; // 跟踪ring1是否处于活动状态
    reg ring2_active; // 跟踪ring2是否处于活动状态

    initial begin
        ring1_active = 1'b0;
        ring2_active = 1'b0;
        ban = 1'b0;
        ring = 1'b0;
        tone_divide = 2'b00;
        counter = 4'b0000;
        speaker = 1'b0;
    end

    // 闹钟控制逻辑 - 优先处理ring1
    always @(posedge clk) begin
        if (ring1 && !ring1_active) begin
            // ring1触发，开始闹铃，优先级高
            ring <= 1'b1;
            ban <= 1'b1;
            ring1_active <= 1'b1;
            ring2_active <= 1'b0; // 确保ring2不活动
            tone_divide <= 2'b11;  // 开始使用第一个频率(330Hz)
        // end else if (!ring1) begin
        //     ring1_active <= 1'b0; // 重置ring1活动状态
        end else if (ring2 && !ban && !ring2_active && !ring1_active) begin
            // 只有当ban为0且ring1不活动时，ring2才能激活
            ring <= 1'b1;
            ban <= 1'b1;
            ring2_active <= 1'b1;
            tone_divide <= 2'b00;  // ring2使用不同的起始频率
        // end else if (!ring2) begin
        //     ring2_active <= 1'b0; // 重置ring2活动状态
        end else if (clk_1hz_posedge) begin
            if (ring1_active) begin
                // ring1模式的频率变化
                if (tone_divide == 2'b00) begin
                    ring <= 1'b0;
                    ban <= 1'b0;
                    ring1_active <= 1'b0;
                end else begin
                    tone_divide <= tone_divide - 1'b1;  // 逐渐降低频率
                end
            end else if (ring2_active) begin
                // ring2模式的频率变化
                if (tone_divide == 2'b11) begin
                    ring <= 1'b0;
                    ban <= 1'b0;
                    ring2_active <= 1'b0;
                end else begin
                    tone_divide <= tone_divide + 1'b1;  // 逐渐增高频率
                end
            end
        end
    end

    // // 闹钟控制逻辑
    // always @(posedge clk or posedge ring1) begin
    //     if (ring1 && !ring) begin
    //         // ring1触发，开始闹铃
    //         ring <= 1'b1;
    //         ban <= 1'b1;
    //         // tone_timer <= 2'b00;
    //         tone_divide <= 2'b11;  // 开始使用第一个频率(330Hz)
    //     end else if (clk_1hz_posedge) begin
    //         // 每秒更新一次音调
    //         if (tone_divide == 2'b00) begin
    //             // 当计时满3秒时，停止闹铃
    //             ring <= 1'b0;
    //             ban <= 1'b0;
    //         end else begin
    //             // 计时未满，更新音调并增加计时器
    //             // tone_timer <= tone_timer + 1'b1;
    //             tone_divide <= tone_divide - 1'b1;  // 逐渐降低频率
    //         end
    //     end
    // end


    // always @(posedge clk or posedge ring2) begin
    //     if(!ban)
    //     begin
    //         if (ring2 && !ring) begin
    //             // ring1触发，开始闹铃
    //             ring <= 1'b1;
    //             ban <= 1'b1;
    //             // tone_timer <= 2'b00;
    //             tone_divide <= 2'b00;  // 开始使用第一个频率(330Hz)
    //         end else if (clk_1hz_posedge) begin
    //             // 每秒更新一次音调
    //             if (tone_divide == 2'b11) begin
    //                 // 当计时满3秒时，停止闹铃
    //                 ring <= 1'b0;
    //                 ban <= 1'b0;
    //             end else begin
    //                 // 计时未满，更新音调并增加计时器
    //                 // tone_timer <= tone_timer + 1'b1;
    //                 tone_divide <= tone_divide + 1'b1;  // 逐渐降低频率
    //             end
    //         end
    //     end
    // end
    // always @(posedge ring2) begin
    //     if(ban)
    //     begin

    //     tone_divide <= 2'b11; // 440Hz
    // end

    // 计数器逻辑
    always @(posedge clk) begin
        // if (!ring1 && !ring2) begin
        if(!ring) begin
            counter <= 0;
        end else begin
            if (counter == tone_divide+1'b1) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    // 扬声器逻辑
    always @(posedge clk) begin
        if (!ring) begin
            speaker <= 1'b0;
        end else begin
            speaker <= (counter <= (tone_divide+1'b1)/2)? 1'b1 : 1'b0;
        end
    end

endmodule