module Extend (
    input  wire [31:0] instr,    
    input  wire [1:0]  ImmSrc,   
    output reg  [31:0] ImmExt    
);

    always @* begin
        case (ImmSrc)
            // 00 : I-type 
            2'b00: ImmExt = {{20{instr[31]}}, instr[31:20]};

            // 01 : S-type  
            2'b01: ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // 10 : B-type                              
            2'b10: ImmExt = {{19{instr[31]}},instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                              
            2'b11:
              case(instr[6:0])	//11 : J-type
                 7'b 1101111: ImmExt = {{11{instr[31]}},instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
                 
                 default: ImmExt = {instr[31:12], 12'b0};          // U-type because 11 corresponds to J or U. So if its not J then it must be a U type instruction
	      endcase
            default: ImmExt = 32'b0;
        endcase
    end

endmodule
