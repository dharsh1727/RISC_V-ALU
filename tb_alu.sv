

`timescale 1ns / 1ps

// 1. Transaction Class: Defines the inputs and constrains them to "nasty" values
class alu_transaction;
    rand bit [31:0] SrcA;
    rand bit [31:0] SrcB;
    rand bit [31:0] ImmExt;
    rand bit [3:0]  alu_control;
    rand bit        alu_src;

    // Outputs to verify
    bit [31:0] ALU_result;
    bit        zero;

    // Constraint 1: Distribute values to hit corner cases often
    constraint corner_cases {
        SrcA dist { 0:=5, -1:=5, 32'h7FFFFFFF:=5, 32'h80000000:=5, [1:100]:=10, [32'hFFFFFF00:32'hFFFFFFFE]:=10 };//These will provide you how much percentage time the given value must occur in the random 
        SrcB dist { 0:=5, -1:=5, 32'h7FFFFFFF:=5, 32'h80000000:=5, [1:31]:=20 }; // Focus on shift amounts
        ImmExt dist { 0:=5, -1:=5, [1:100]:=10 };
    }

    // Constraint 2: Ensure we hit all valid operations + some invalid ones
    constraint control_dist {
        alu_control dist {
            4'b0000:=10, 4'b0001:=10, 4'b0010:=10, 4'b0011:=10,
            4'b0100:=10, 4'b0101:=10, 4'b0110:=10, 4'b0111:=10,
            4'b1000:=10, 4'b1101:=10,
            [4'b1001:4'b1100]:=2, 4'b1110:=2, 4'b1111:=2 // Invalid ops to test default case
        };
    }
endclass

// 2. Scoreboard/Golden Model: The Reference Logic
class alu_scoreboard;
    int error_count = 0;

    // The Golden Model: mimics ideal ALU behavior
    function bit [31:0] get_expected_result(alu_transaction tr);
        bit [31:0] operand2;
        
        // MUX Logic
        operand2 = (tr.alu_src) ? tr.ImmExt : tr.SrcB;

        // ALU Operation Logic
        case (tr.alu_control)
            4'b0000: return tr.SrcA + operand2;                    // ADD
            4'b0001: return tr.SrcA << operand2[4:0];              // SLL
            4'b0010: return (tr.SrcA < operand2) ? 1 : 0;          // SLT (Unsigned)
            4'b0011: return ($signed(tr.SrcA) < $signed(operand2)) ? 1 : 0; // SLT (Signed)
            4'b0100: return tr.SrcA ^ operand2;                    // XOR
            4'b0101: return tr.SrcA >> operand2[4:0];              // SRL
            4'b0110: return tr.SrcA | operand2;                    // OR
            4'b0111: return tr.SrcA & operand2;                    // AND
            4'b1000: return tr.SrcA - operand2;                    // SUB
            4'b1101: return $signed(tr.SrcA) >>> operand2[4:0];    // SRA
            default: return 32'bx;                                 // Undefined
        endcase
    endfunction

    // Compare DUT result with Expected result
    task check(alu_transaction tr);
        bit [31:0] expected;
        bit        expected_zero;
        
        expected = get_expected_result(tr);
        expected_zero = (expected == 32'b0) ? 1'b1 : 1'b0;

        // Use === for comparison to handle X/Z correctly
        if (tr.ALU_result !== expected) begin
            $error("[FAIL] Time=%0t | Op=%b | SrcA=%h | Op2=%h | DUT=%h | Exp=%h", 
                   $time, tr.alu_control, tr.SrcA, (tr.alu_src ? tr.ImmExt : tr.SrcB), tr.ALU_result, expected);
            error_count++;
        end else if (tr.zero !== expected_zero) begin
            $error("[FAIL ZERO] Time=%0t | Result=%h | DUT_Zero=%b | Exp_Zero=%b", 
                   $time, tr.ALU_result, tr.zero, expected_zero);
            error_count++;
        end else begin
            // Uncomment below for verbose passing
            // $display("[PASS] Op=%b Result=%h", tr.alu_control, tr.ALU_result);
        end
    endtask
endclass

// 3. Top Module
module tb_alu;

    // Interface Signals
    reg [31:0] SrcA, SrcB, ImmExt;
    reg [3:0]  alu_control;
    reg        alu_src;
    wire       zero;
    wire [31:0] ALU_result;

    // Instantiation
    alu dut (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ImmExt(ImmExt),
        .alu_control(alu_control),
        .alu_src(alu_src),
        .zero(zero),
        .ALU_result(ALU_result)
    );

    // Objects
    alu_transaction tr;
    alu_scoreboard  sb;

    initial begin
        tr = new();
        sb = new();

        $display("----------------------------------------------------------------");
        $display("Starting COMPLEX ALU Verification with Corner Cases");
        $display("----------------------------------------------------------------");

        // Run 1000 randomized test vectors
        repeat (1000) begin
            // 1. Randomize inputs
            if (!tr.randomize()) $fatal("Randomization failed!");

            // 2. Drive Inputs to DUT
            SrcA        = tr.SrcA;
            SrcB        = tr.SrcB;
            ImmExt      = tr.ImmExt;
            alu_control = tr.alu_control;
            alu_src     = tr.alu_src;

            // 3. Wait for combinatorial logic to settle
            #10; 

            // 4. Sample Outputs
            tr.ALU_result = ALU_result;
            tr.zero       = zero;

            // 5. Compare
            sb.check(tr);
        end

        $display("----------------------------------------------------------------");
        if (sb.error_count == 0)
            $display("TEST PASSED: No errors found in 1000 vectors.");
        else
            $display("TEST FAILED: Found %0d mismatches.", sb.error_count);
        $display("----------------------------------------------------------------");
        $finish;
    end
    
    // Assertion for Zero Flag Logic Consistency
    // This ensures that even if the result calculation is wrong, the zero flag logic matches the result
    property check_zero_flag;
        @(ALU_result) (ALU_result == 0) |-> (zero == 1);
    endproperty
    
    assert property (check_zero_flag) else $error("Assertion Failed: Result is 0 but Zero flag is low!");

endmodule

is this system verilog 
how it executes
and tell me can i execute it in vivado 2017.4
