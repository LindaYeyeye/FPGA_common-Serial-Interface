`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/20 15:11:12
// Design Name: 
// Module Name: Uart_rx_tb
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


module Uart_tx_tb(

    );

   

	reg         clk;          //时钟
  	reg       uart_rst_n;  //复位
	reg 	  uart_en;
 
  	reg  [7:0] tx_data;      //发送的字数据
 
    wire txd;		
    wire tx_state=1'b1;


 	
localparam    CNT= 50_000_000/115200 *200;//传输一位数据所需周期数为:T_cnt = clk / bound = 6_000_000 / 115200
    

uart_tx u_uart_tx(
	.clk( clk),			
	.uart_rst_n(uart_rst_n),
	.uart_en (uart_en),			
	.tx_data(tx_data),			
	.txd(txd),		
	.tx_state(tx_state)	
);



initial begin
//初始时刻定义
		clk	<=1'b0;	
		uart_rst_n	<=1'b1;		
		uart_en<=1'b0;
		tx_data=8'b01011011;
	// #5 uart_en<=1'b1;
	// #25 uart_en<=1'b0;
	
	
end
 
always begin
	// #10	clk=~clk;	//时钟20ns,50M
	#200 uart_en=~uart_en;
end

always  begin
	#10 clk=~clk;
end


endmodule
