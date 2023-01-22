`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/06 19:54:47
// Design Name: 
// Module Name: I2C_dri_tb
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


module I2C_dri_tb(

    );
    reg                sys_clk=1'b1    ;    
    reg                rst_n =1'b1     ;
    reg                w_enable=1'b1   ;
    reg                r_enable=1'b0   ;   
                                         
    reg        [ 7:0]  slave_addr=8'h00 ; //包含读写位
    reg        [7:0]   i2c_addr=8'h00    ;  //2bytes address
    reg        [ 7:0]  i2c_data_w=8'h00  ;  //write_data
    wire      [ 7:0]  i2c_data_r=8'h00  ;  //read_data

    wire                scl       ;  
    wire                sda       ;

   
       always #5 sys_clk=~sys_clk;
   

    I2C_driv u_I2C_driv(
        .sys_clk(sys_clk)    , 
        .rst_n  (1'b1)    ,
        .w_enable(1'b1)  ,
        .r_enable(1'b0)  ,  
                     
        .slave_addr(8'hf5), 
        .i2c_addr(8'h05)   , 
        .i2c_data_w(8'h01) , 
        .i2c_data_r(i2c_data_r) , 
        . scl      (scl)  ,
        . sda      (sda)   
    );  
endmodule
