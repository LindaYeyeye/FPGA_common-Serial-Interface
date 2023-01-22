`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/20 15:52:48
// Design Name: 
// Module Name: clk_divid
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


module clk_divid_LT(

        input    clk,
        output  div_clk
    );

    parameter divide_number = 25'd6;

    reg [26:0] cnt_number=4'b0 ;

    always @(posedge clk ) begin
        if (cnt_number == (divide_number/2)-1) begin
         cnt_number    <= 'b0 ;
      end
      else begin
         cnt_number    <= cnt_number + 1'b1 ;
      end
        
    end

    reg     clk_div_r=1'b0;

    always @(posedge clk ) begin
        if (cnt_number == (divide_number/2)-1 ) begin
         clk_div_r <= ~clk_div_r ;
      end
    end

    assign div_clk = clk_div_r;
endmodule
