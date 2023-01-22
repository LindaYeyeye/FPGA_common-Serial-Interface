`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/22 21:35:27
// Design Name: 
// Module Name: adc_config_LT
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adc_config_LT(

    
    input  sdout,
    input  sys_clk,

    output reg sdin=1'b0,
    output sclk,
    output cs,
    // output test,

    output sclk_show,
    output sdin_test,
    output cs_show,
    output sdout_test 
    

    );

    // assign test=1'b1;

    // //测试端口
    // wire cs;

    wire    clk_10M;//10MHZ
    wire    locked;
    wire    clk_test;

    wire    clk; //3.3MHz

//PLL产生时钟 20M 以及100M的逻辑分析仪检测时钟
  clk_spi u_clk_spi
   (
    // Clock out ports
    .clk_out1(clk_10M),         // output clk_out1 10M
    .clk_out2(clk_test),        //100M
    // Status and control signals
    .reset(1'b0),              // input reset
    .locked(locked),            // output locked
   // Clock in ports
    .clk_in1(sys_clk));         // input clk_in1 50M

//时钟分频模块 把10MHz时钟降为5kHz
clk_divid_LT u_clk_div(
    .clk(clk_10M),
    .div_clk(clk)
);


//cs_in每5个时钟拉底一下检测
reg    cs_test=1'b1;

reg    [3:0]cs_test_cnt=4'b0;

always @(negedge clk ) begin
    if(cs_test_cnt<4'd5)
         cs_test_cnt<=cs_test_cnt+1'b1;
    else if(cs_test_cnt==4'd5)
         cs_test_cnt<=1'b0;
end

always @(posedge clk ) begin
    if(cs_test_cnt==4'd5)
        cs_test<=1'b0;
    else
        cs_test<=1'b1;
end



wire    EOC_test;
// reg     EOC_test_d1;
// wire    EOC_test_neg_flag;

assign  EOC_test = ~(cs_test | sdout);

// always @(posedge clk ) begin
//         EOC_test_d1<=EOC_test;
// end

// assign  EOC_test_neg_flag= EOC_test & ~ EOC_test_d1 ;

reg    [6:0] cnt_cs_enable=7'b0;

//每一个下降沿检测到，就把计数器拉到32，开始倒计时32个时钟

always @(negedge clk ) begin
    if(cnt_cs_enable==7'b0 & EOC_test )
        cnt_cs_enable<=7'd32;
    else if(cnt_cs_enable>7'b0)
        cnt_cs_enable<=cnt_cs_enable-1'b1;
    else
        cnt_cs_enable<=7'b0;
end

reg     cs_enable;

always @(negedge clk ) begin
    if(cnt_cs_enable>7'b0)
        cs_enable<=1'b0;
    else
        cs_enable<=1'b1;
end

wire     cs_out;

assign  cs_out=cs_test & cs_enable;

wire     sclk_test;

assign sclk_test=~cs_enable & clk  ;


reg [31:0]WriteReg1=32'hB0500000;

always @(negedge clk ) begin
    if(cnt_cs_enable>1'b0)
        sdin<=WriteReg1[cnt_cs_enable-1];
end


assign sclk = sclk_test;
assign cs   = cs_out;



// assign sclk_show = sclk;
// assign sdin_test=sdin;
// assign sdout_test=sdout;
// assign cs_show = cs;









endmodule
