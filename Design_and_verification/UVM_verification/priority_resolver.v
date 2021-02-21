/*

Priority resolver

No	Signals	Type	Size	Description
1	reqA	input	1	Request A
2	reqB	input	1	Request B
3	reqC	input	1	Request C
4	reqD	Input	1	Request D
5	clk	input	1	clock
6	rst	Input	1	Reset
7	Rot_en	input	1	Rotating priority enable
8	gntA	output	1	gnt A
9	gntB	Output	1	gnt B
10	gntC	Output	1	gnt C
11	gntD	Output	1	gnt D
12	Busy	Output	1	Busy flag
*/

module priority_resolver (gnt,req,clk,rst,rot_en,pr_en);

  //----------input output port declaration
  input [3:0]  req;     	//request
  input        clk;     	//clock
  input        rst;     	//asynchronous reset
  input        rot_en;		//rotating priority enable
  input        pr_en;   	// priority enable
  output [3:0] gnt; 
	                       
  reg    [3:0] gnt_pstate , grant;
	
  assign gnt = grant;
  

  always @(posedge clk or negedge rst) 
	  begin
		if(!rst) begin
		  gnt_pstate <= 4'h0;	
		  grant      <= 4'h0;
		end
	
	else if(pr_en) 
		begin
		
			if(rot_en) 
				begin 											//rotating priority
					gnt_pstate <= grant;
				case (gnt_pstate)
					4'b0000 : begin
									 casez(req)
										4'b???1 : grant <= 4'b0001;
										4'b??10 : grant <= 4'b0010;
										4'b?100 : grant <= 4'b0100;
										4'b1000 : grant <= 4'b1000;
										default : grant <= 4'b0000;
									 endcase
								 end
								 
					4'b0001 : begin 
									 casez(req)
										4'b??1? : grant <= 4'b0010;
										4'b?10? : grant <= 4'b0100;
										4'b100? : grant <= 4'b1000;
										4'b0001 : grant <= 4'b0001;
										default : grant <= 4'b0001;
									 endcase 
								 end
								 
					4'b0010 : begin 
									 casez(req)
										4'b?1?? : grant <= 4'b0100;
										4'b10?? : grant <= 4'b1000;
										4'b00?1 : grant <= 4'b0001;
										4'b0010 : grant <= 4'b0010;
										default : grant <= 4'b0010;
									 endcase
								 end
					
					4'b0100 : begin
									 casez(req)
										4'b1??? : grant <= 4'b1000;
										4'b0??1 : grant <= 4'b0001;
										4'b0?10 : grant <= 4'b0010;
										4'b0100 : grant <= 4'b0100;
										default : grant <= 4'b0100;
									 endcase
								 end
					
					4'b1000 : begin
									 casez(req)
										4'b???1 : grant <= 4'b0001;
										4'b??10 : grant <= 4'b0010;
										4'b?100 : grant <= 4'b0100;
										4'b1000 : grant <= 4'b1000;
										default : grant <= 4'b1000;
									 endcase
								 end
								 
					default : grant <= gnt_pstate;
					
				endcase
						  
			end
			
			else 
			begin 												//fixed priority        
				casez(req[3:0])
					4'b???1 : grant <= 4'b0001;
					4'b??10 : grant <= 4'b0010;
					4'b?100 : grant <= 4'b0100;
					4'b1000 : grant <= 4'b1000;
					default : grant <= 4'b0000;
				endcase 
			end    
		end 

		else
			grant <= grant;
	  end
	
endmodule