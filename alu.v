module alu(
    input [31:0] SrcA,SrcB,ImmExt,
    input [3:0] alu_control,
    
    input wire alu_src,
    output wire zero,
    output wire [31:0] ALU_result
);
reg [31:0] result_reg;
always@(*) begin
  case(alu_src)
  1'b0 : 
    case (alu_control)
         4'b0000 : result_reg = SrcA + SrcB;
         4'b0001 : result_reg = SrcA << SrcB[4:0];
         4'b0010 : result_reg = (SrcA < SrcB )? 1 : 0;
         4'b0011 : result_reg = ($signed(SrcA) < $signed(SrcB) )? 1 : 0;
         4'b0100 : result_reg = SrcA ^ SrcB;
         4'b0101 : result_reg = SrcA >> SrcB[4:0]; 
         4'b0110 : result_reg = SrcA | SrcB;
         4'b0111 : result_reg = SrcA & SrcB;
         4'b1000 : result_reg = SrcA - SrcB;
         4'b1101 : result_reg = $signed(SrcA) >>> SrcB[4:0]; 
         default : result_reg = 32'bx;
    endcase
  1'b1 :
   case(alu_control)
      4'b0000 : result_reg = SrcA + ImmExt;
      4'b0001 : result_reg = SrcA << ImmExt[4:0];
      4'b0010 : result_reg = (SrcA < ImmExt )? 1 : 0;
      4'b0011 : result_reg = ($signed(SrcA) < $signed(ImmExt) )? 1 : 0;
      4'b0100 : result_reg = SrcA ^ ImmExt;
      4'b0101 : result_reg = SrcA >> ImmExt[4:0]; 
      4'b0110 : result_reg = SrcA | ImmExt;
      4'b0111 : result_reg = SrcA & ImmExt;
      4'b1000 : result_reg = SrcA - ImmExt;
      4'b1101 : result_reg = $signed(SrcA) >>> ImmExt[4:0]; 
      default : result_reg = 32'bx;
    endcase
endcase    

end
assign zero = (ALU_result == 32'b0) ? 1'b1 : 1'b0;
assign ALU_result = result_reg;

endmodule
