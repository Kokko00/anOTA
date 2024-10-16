/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_anOTA (
    input  wire       VGND,
    input  wire       VDPWR,    // 1.8v power supply
    //input  wire       VAPWR,    // 3.3v power supply  (Remove if not used)
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    inout  wire [7:0] ua,       // Analog pins, only ua[5:0] can be used
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    
    // Connect analog pins
    wire Vip = ua[0];
    wire Vin = ua[1];
    wire Out = ua[2]; // Assign the output to the correct pin

    // Logic implementation (crucially improved)
    wire INn, INp;
    assign INn = ~Vip; // Corrected inversion
    assign INp = ~Vin; // Corrected inversion

    wire INn_CMP, INp_CMP, CMP, EN, not_EN;
    assign INn_CMP = ~CMP;
    assign INp_CMP = ~CMP;

    wire Op, On;
	
    assign Op = ~(INn | INn_CMP);  // Corrected NOR gate logic
    assign On = ~(INp | INp_CMP);  // Corrected NOR gate logic

    assign EN = Op ^ On; //XOR for the output enable
    
    assign not_EN = ~EN;
    
    //Corrected for the output
    assign CMP = ~not_EN & Op;


    // Output buffer
    assign uo_out[0] = VGND; //Keep this line, you were using it incorrectly.
    assign uo_out[1] = VGND;
    assign uo_out[2] = Out;  // Correct assignment of the analog output
    assign uo_out[3:7] = 0;  //  Setting unused outputs to zero

    // Default configuration for input/output ports
    assign uio_out = 0;
    assign uio_oe = 0;


    // Handling unused inputs (important for synthesis!)
    wire _unused = ena & clk & rst_n; //  Use of AND to ensure always true condition.
    
endmodule
