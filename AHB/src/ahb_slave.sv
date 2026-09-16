`timescale 1ns / 1ps
`include "ahb_defines.svh"

module ahb_slave(
input clk,
input [31:0] hwdata,
input [31:0] haddr, 
input [2:0] hsize,
input [2:0] hburst,
input hresetn, hsel, hwrite,
input [1:0] htrans,
output reg [1:0] hresp,
output reg hready,
output reg [31:0] hrdata
);
 
 
 
reg [7:0] mem [0:255];
integer init_index;

initial begin
    for (init_index = 0; init_index < 256; init_index = init_index + 1)
        mem[init_index] = 8'd12;
end

`include "ahb_transfer_functions.svh"
 
always_ff@(posedge clk)
begin
if(!hresetn)
state <= idle;
else
state <= next_state;
end
///////////////////////////////////////////////////////////////////////////////////
 
 
 
integer len_count = 0;
reg first = 0;
reg [31:0] retaddr;
reg [31:0] next_addr;
reg [7:0] wboundary;
 
 
 
 
/////////////////////////////////////////////////////////////////////////////////
always_comb
begin
    case(state)
  
          idle : 
          begin
          next_state = check_mode;
          hready = 1'b0;
          len_count = 0;
          first = 0;
          hresp = `OKAY;
          end
  
          check_mode : 
          begin
                            hready = 1'b0;
                            if(hresetn && hsel && hwrite)
                                begin
                                     if(haddr < 256) 
                                      begin
                                      next_state = addr_decode;
                                      end
                                     else
                                      begin 
                                       next_state = idle;
                                       hresp = `ERROR;
                                      end
                                end
                           else if (hresetn && hsel && !hwrite)
                                begin
                                        if(haddr < 256)
                                        begin  
                                        next_state = addr_decode;
                                        end
                                        else
                                        begin
                                        next_state = idle;
                                        hresp = `ERROR; 
                                        end
                                end
                           else
                                begin
                                next_state = idle;
                                                                end  
          end
  
         addr_decode: 
          begin
                          if(htrans == `NON_SEQ)
                             begin
                                       next_addr = haddr;
                                       
                                       if(hwrite)
                                       next_state = write;
                                       else
                                       next_state = read;
                                       
                                       
                             end 
                             else if (htrans == `SEQ)  
                             begin
                                     next_addr  = retaddr;
                                            
                                           if(hwrite)
                                           next_state = write;
                                           else
                                           next_state = read;
 
                            end
         
         
         end
  
  
         write:
          begin
               case(hburst)
  
  //////////////////////////Single Write at HADDR
                    3'b000: begin  ////single transfer
                       retaddr = single_tr(next_addr,hsize);
                       hready     = 1'b1;
                       next_state = idle;
                       hresp = `OKAY;
                    end
   
   /////////////////////INCREMENT for UNSPECIFIED LENGTH         
            
                   3'b001: 
                       begin   ////incr mode
                       
                       hready = 1'b1;
                       retaddr = unincr_wr(next_addr, hsize);
                       hresp = `OKAY;      
                       
                       
                       if(len_count < 32)
                          begin
                          len_count = len_count + 1;
                          next_state = check_mode; 
                          end
                       else
                          begin
                          len_count = 0;
                          next_state = idle;
                          end   
                                                
                    end
 ////////////////////////////4 beat wrapping
 
 
                  3'b010: 
                        begin
                          
                          hready = 1'b1; 
                          wboundary = boundary(hburst, hsize);
                          retaddr   = wrap_wr(next_addr, wboundary, hsize);
                          hresp = `OKAY;
                                
                               
                                 if(len_count <= 2) // 0 1 2 3
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end
                      end 
        
///////////////////////////////4 beat Incrementing
 
                 3'b011:
                               begin
                               
                                   hready = 1'b1;
                                   retaddr = incr_wr(next_addr, hsize);
                                   hresp = `OKAY;
                                   
                                   if(len_count <= 2)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     first = 0; 
                                     end
                                   
                               
                               end    
                               
////////////////////////////////////////////////8 beat wrapping
 
 
                  3'b100: 
                      begin
                                          
                                          hready = 1'b1; 
                                          wboundary = boundary(hburst, hsize);
                                          retaddr = wrap_wr(next_addr, wboundary, hsize);
                                          hresp = `OKAY;
                                           
                                   if(len_count <= 6)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end
                                    end
                                       
 ////////////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////8 beat Incrementing
                        3'b101:
                               begin
                                   hready = 1'b1;
                                   retaddr = incr_wr(next_addr, hsize);
                                   hresp = `OKAY;
                                   
                                 if(len_count <= 6)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end
                               
                               end  
 
 /////////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////16 beat wrapping
 
                       3'b110: 
                          begin
                              
                              hready = 1'b1; 
                              wboundary = boundary(hburst, hsize);
                              retaddr = wrap_wr(next_addr, wboundary, hsize);
                              hresp = `OKAY;
                               
                                 if(len_count <= 14)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end
                        end
 
 /////////////////////////////////////////////////////////////////////////////////
 //////////////////////16 beat incr
                            3'b111:
                               begin
                                   hready = 1'b1;
                                   retaddr = incr_wr(next_addr, hsize);
                                   hresp = `OKAY;
                                   
                                 if(len_count <= 14)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end
                               
                                     end 
       
                 endcase
  end
 
read : begin
 
               case(hburst)
  
  //////////////////////////Single Write at HADDR
                    3'b000: begin  ////single transfer
                       retaddr = single_tr_rd(haddr,hsize);
                       hready     = 1'b1;
                       next_state = idle;
                       hresp = `OKAY;
                    end
   
   /////////////////////INCREMENT for UNSPECIFIED LENGTH         
            
                   3'b001: 
                       begin   ////incr mode
                       hready = 1'b1;
                       retaddr = unincr_rd(next_addr, hsize);
                       hresp = `OKAY;
        
                              if( len_count < 32) 
                              begin
                              len_count = len_count + 1;
                              next_state = check_mode;
                              end
                              else
                              begin
                              len_count = 0;  
                              next_state = idle;
                              end                            
                       end  
 ////////////////////////////4 beat wrapping
 
 
                  3'b010: 
                        begin
                          
                          hready = 1'b1; 
                          wboundary = boundary(hburst, hsize);
                          retaddr = wrap_rd(next_addr, wboundary, hsize);
                          hresp = `OKAY;
                          
                                   if(len_count <= 2)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end 
                           
                            
                        end 
        
///////////////////////////////4 beat Incrementing read
 
                 3'b011:
                               begin
                                   hready = 1'b1;
                                   retaddr = incr_rd(next_addr, hsize);
                                   hresp = `OKAY;
                                   
                                 if(len_count <= 2)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end
                               
                               end    
                               
////////////////////////////////////////////////8 beat wrapping
 
 
                  3'b100: 
                      begin
                                          
                                          hready = 1'b1; 
                                          wboundary = boundary(hburst, hsize);
                                          retaddr = wrap_rd(next_addr, wboundary, hsize);
                                          hresp = `OKAY;
                                           
                                  if(len_count <= 6)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end
                                     
                                     
                                    end
                                       
 ////////////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////8 beat Incrementing
                        3'b101:
                               begin
                                   hready = 1'b1;
                                   retaddr = incr_rd(next_addr, hsize);
                                   hresp = `OKAY;
                                   
                                 if(len_count <= 6)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end
                               
                               end  
 
 /////////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////16 beat wrapping
 
                       3'b110: 
                          begin
                              
                              hready = 1'b1; 
                              wboundary = boundary(hburst, hsize);
                              retaddr = wrap_rd(next_addr, wboundary, hsize);
                              hresp = `OKAY;
                               
                                  if(len_count <= 14)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end
                        end
 
 /////////////////////////////////////////////////////////////////////////////////
 //////////////////////16 beat incr
                            3'b111:
                               begin
                                   hready = 1'b1;
                                   retaddr = incr_rd(next_addr, hsize);
                                   hresp = `OKAY;
                                   
                                 if(len_count <= 14)
                                     begin
                                     len_count = len_count + 1;
                                     next_state = check_mode;
                                     end
                                     else
                                     begin
                                     next_state = idle;
                                     len_count = 0;
                                     end
                               
                                     end 
       
                 endcase
 
end
 
endcase
 
end
endmodule
