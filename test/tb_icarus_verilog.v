`default_nettype none
`timescale 1ns / 1ps

`include "top.v"
/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
//temp regs
  reg [5:0] key;
  reg start;
  reg enc_dec;

  always @(*) begin
    uio_in[5:0] = key;
    uio_in[6] = start;
    uio_in[7]=enc_dec;
  end

  initial begin
    rst_n=0; clk=0;
    #100 rst_n=1;
    //test vectors
    // Test-1 encryption
    ui_in=8'hDF;key=6'b010010;start=1;enc_dec=1;
    #200 start=0;
    // Test-2 encryption
    ui_in=8'h6A;key=6'b11001;start=1;enc_dec=1;
    #200 start=0;
    //Test-3
    ui_in=8'h92;key=6'b101011;start=1;enc_dec=1;
    #200 start=0;
    // Decryption test
     // Test-1 decryption
    ui_in=8'h61;key=6'b010010;start=1;enc_dec=0;
    #200 start=0;
    // Test-2 decryption
    ui_in=8'h8F;key=6'b11001;start=1;enc_dec=0;
    #200 start=0;
    // Test-3 decryption
    ui_in=8'hF7;key=6'b101011;start=1;enc_dec=0;//exp-92
    #200 start=0;

    #100;
$finish;
  end

  initial begin
    $monitor("Data=%h,key=%b,start=%b,enc_dec=%b, data_out=%h",ui_in, key, start,enc_dec,uo_out);
  end
//clock generation
  always #5 clk=!clk;

  // Replace tt_um_example with your module name:
 tt_um_crypto8_unified user_project (
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

endmodule
