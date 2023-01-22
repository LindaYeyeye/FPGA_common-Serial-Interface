`timescale 1ns / 1ps

// `timescale 1ns / 1ps
//config conde of ADC128S102  use channe0 and channe2


module adc_config_test(

    input               sys_clk,    //system clkc 50M
    input               reset_n,    //reset flag

    input               sdout,      //ADC to fpga 
 
    output              sclk_out,   //to ADC  
    output              cs_out,     //to ADC  
    output   reg         sdin     //to ADC


//---
// //测试端口连接示波器,实际可以删掉
//     output    test_sclk,
//     output    cs_test,
//     output    sdout_test,
//     output    sdin_test
// //---



    );

wire        cs;

//寄存器配置
    reg        [15:0] WriteReg1={16'h0004}; // register for channe2 
    reg        [15:0] WriteReg2={16'h0000}; // register for channe0 


    wire    clk_10M;//10MHZ
    wire    locked;
    wire    clk_test;

    wire    clk;
    

//PLL产生时钟 20M 以及100M的逻辑分析仪检测时钟
  clk_wiz_0 u_clk_ip
   (
    // Clock out ports
    .clk_out1(clk_test),         // output clk_out1 10M
    .clk_out2(clk_10M),        //100M
    // Status and control signals
    .reset(1'b0),              // input reset
    .locked(locked),            // output locked
   // Clock in ports
    .clk_in1(sys_clk));         // input clk_in1 50M

//时钟分频模块 把10MHz时钟降为3.3MHz
clk_divid u_clk_div(
    .clk(clk_10M),
    .div_clk(clk)
);

//状态机参数设计
    localparam IDLE     = 3'd0;
    localparam WORK1    = 3'd1;
    localparam REST     = 3'd2;
    localparam WORK2    = 3'd3;


  reg    [3:0] state_config=3'b0;
  reg    [8:0] config_cnt1;

  reg      cs1;
  reg      cs2;

  always @(negedge clk  ) begin
    case(state_config)
    3'd0:   
    begin
        state_config  <= WORK1;
        // cs1<=1'b0;
        // cs2<=1'b1;
        config_cnt1<=9'd0; //
    end

    3'd1:begin
        begin
        // cs2<=1'b1;
        sdin<= WriteReg1[config_cnt1];
        end
        if(config_cnt1 == 9'd15)
        begin
            state_config  <= REST;

        end
        else
        begin
            state_config  <= WORK1;
            config_cnt1<=config_cnt1+1'b1;
        end
               
    end

    3'd2:begin
        state_config  <= WORK2;
        config_cnt1<=9'd0;
    end


    3'd3:begin
        begin

        sdin<= WriteReg2[config_cnt1];
        end

        if(config_cnt1 == 9'd15)
        begin
            state_config  <= IDLE;
            config_cnt1<=1'b0;
           
        end
        else
        begin
            state_config  <= WORK2;
            config_cnt1<=config_cnt1+1'b1;
          
        end
    end


        endcase
  end


  always @(posedge clk  ) begin
    case(state_config)
    3'd0:   
    begin
        
        cs1<=1'b0;
        cs2<=1'b1;
       
    end

    3'd1:begin
       cs2<=1'b1;
        if(config_cnt1 == 9'd15)
        begin
            cs1<=1'b1;
        end
        else
        begin
            cs1<=1'b0;
        end
               
    end

    3'd2:begin
        cs2<=1'b0;
        cs1<=1'b1;

    end


    3'd3:begin
        begin
        cs1<=1'b1;      
        end
        if(config_cnt1 == 9'd15)
        begin  
            cs2<=1'b1;
        end
        else
        begin
            cs2<=1'b0;
        end
    end
        endcase
  end

assign       cs=cs1&cs2;

reg          cs_high;

always @(negedge clk ) begin
    if(cs==1'b1)
        cs_high<=1'b1;
        else
        cs_high<=1'b0;
    
end

wire        cs1_posflag;
reg         cs1_posflag_d1;
wire        cs2_posflag;
reg         cs2_posflag_d1;
reg         cs1_d;
reg         cs2_d;

always @(posedge clk_test ) begin
    cs1_d<=cs1;
    cs2_d<=cs2;
end

assign cs1_posflag=~ cs1_d & cs1;
assign cs2_posflag=~ cs2_d & cs2;

always @(posedge clk_test ) begin

    cs1_posflag_d1<=cs1_posflag;
    cs2_posflag_d1<=cs2_posflag;
end



wire    cs_pos;

reg     cs_d1;
reg     cs_d2;

always @(posedge clk_test ) begin
    cs_d1<=cs;
    cs_d2<=cs_d1;
    
end

assign cs_pos = ~cs_d2 & cs;

// wire cs_out;

assign cs_out = cs;

assign sclk_out=cs_pos ^(clk|cs_high) ;



    


//测试引出端口

// assign test_sclk=sclk_out;
// assign cs_test=cs_out;
// assign sdout_test=sdout;
// assign sdin_test=sdin;


// //逻辑分析仪
//   ila_spi spi_ila (
// 	.clk(clk_10M), // input wire clk


// 	.probe0(sdin), // input wire [0:0]  probe0  
// 	.probe1(sdout), // input wire [0:0]  probe1 
// 	.probe2(sdout), // input wire [0:0]  probe2 
// 	.probe3(cs_out),// input wire [0:0]  probe3 
// 	.probe4(sclk_out), // input wire [0:0]  probe4
//     .probe5(clk), // input wire [0:0]  probe4

//     .probe6(outputcnt), // input wire [15:0]  probe5 
// 	.probe7(dataout) // input wire [15:0]  probe6 
// 	// .probe7(cnt), // input wire [8:0]  probe7 
// 	// .probe8(clk) // input wire [0:0]  probe8
// );


endmodule