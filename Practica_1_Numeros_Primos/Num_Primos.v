module Num_Primos (

	input [3:0] SW,
	output reg LED
	
);
	
	always @(*)
		begin
			case (SW)	
		    	4'b0010:LED = 1'b1;	// Estos son los números primos definidos del 2 al 13 y tienen como salida el 1 y se prende el LED
				4'b0011:LED = 1'b1;
				4'b0101:LED = 1'b1;
				4'b0111:LED = 1'b1;
				4'b1011:LED = 1'b1;
				4'b1101:LED = 1'b1;
				default:LED = 1'b0;	// El default es para que los números sin definir tengan como salida el 0 y se apague el LED
			endcase
		end

endmodule
