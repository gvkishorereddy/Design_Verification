function bit[31:0] single_tr (input bit [31:0] addr, input bit [2:0] hsize);
    unique case(hsize)
    3'b000: begin
         mem[addr]  = hwdata[7:0];   
    end 
    
    3'b001: begin
         mem[addr]     = hwdata[7:0];
         mem[addr + 1] = hwdata[15:8];
    end
    
    3'b010: begin
         mem[addr]     = hwdata[7:0];
         mem[addr + 1] = hwdata[15:8];
         mem[addr + 2] = hwdata[23:16];
         mem[addr + 3] = hwdata[31:24];
    end
    endcase
    return addr;
    
endfunction
 
 
///////////////////////////////////////////////////////////////////////////////////
function bit[31:0] unincr_wr (input bit [31:0] addr, input bit [2:0] hsize);
    bit [31:0] raddr;
    unique case(hsize)
    
     3'b000: begin
          mem[addr]    = hwdata[7:0];
          raddr        = addr + 1; 
     end
     
     3'b001: begin
         mem[addr]     = hwdata[7:0];
         mem[addr + 1] = hwdata[15:8];
         raddr         = addr + 2;
     end
 
     3'b010: begin
         mem[addr]     = hwdata[7:0];
         mem[addr + 1] = hwdata[15:8];
         mem[addr + 2] = hwdata[23:16];
         mem[addr + 3] = hwdata[31:24];
         raddr         = addr + 4;
     end
 endcase
    
return raddr;
 
endfunction
 
 
 
 
 
 
//////////////////////////////////////////////////////////////////////////////
function bit[7:0] boundary(input bit [2:0] hburst, input [2:0] hsize);
   bit [7:0] temp;
   unique case(hsize)
      3'b000: begin
           unique case (hburst)
              3'b010 : temp = 4 * 1;
              
              3'b100 : temp =  8 * 1;
              
              3'b110 : temp = 16 * 1;
            endcase
      end
      
      3'b001 : begin
            unique case (hburst)
              3'b010 :  temp = 4 * 2;
              
              3'b100 : temp =  8 * 2;
              
              3'b110 : temp = 16 * 2;
            endcase
      end
      
      
      3'b010 : begin
            unique case (hburst)
              3'b010 :  temp = 4 * 4;
              
              3'b100 : temp =  8 * 4;
              
              3'b110 : temp = 16 * 4;
            endcase
    end
    
    endcase
    
    return temp;
    
endfunction
 
 
function bit[31:0] wrap_wr (input bit [31:0] addr, input bit [7:0] boundary, input [2:0] hsize);
  bit [31:0] addr1, addr2, addr3,addr4;
  
  unique case(hsize)
    3'b000: begin
       mem[addr] = hwdata[7:0];
       
        if((addr + 1) % boundary == 0)
         addr1 = (addr + 1) - boundary;
        else
         addr1 = (addr + 1);
         
       return addr1;  
    end
    
    3'b001: begin
        mem[addr] = hwdata[7:0];
       
        if((addr + 1) % boundary == 0)
         addr1 = (addr + 1) - boundary;
        else
         addr1 = (addr + 1);
         
         mem[addr1] = hwdata[15:8];
         
       if((addr1 + 1) % boundary == 0)
         addr2 = (addr1 + 1) - boundary;
        else
         addr2 = (addr1 + 1);
         
        return addr2;
        
       end
    
    3'b010: begin
        
        mem[addr] = hwdata[7:0];
       
        if((addr + 1) % boundary == 0)
         addr1 = (addr + 1) - boundary;
        else
         addr1 = (addr + 1);
         
         mem[addr1] = hwdata[15:8];
         
       if((addr1 + 1) % boundary == 0)
         addr2 = (addr1 + 1) - boundary;
        else
         addr2 = (addr1 + 1);
         
         mem[addr2] = hwdata[23:16];
        
         if((addr2 + 1) % boundary == 0)
         addr3 = (addr2 + 1) - boundary;
         else
         addr3 = (addr2 + 1); 
         
        mem[addr3] = hwdata[31:24];
        
        if((addr3 + 1) % boundary == 0)
         addr4 = (addr3 + 1) - boundary;
         else
         addr4 = (addr3 + 1); 
       
       return addr4;
    end
    
  
  endcase
  
endfunction
////////////////////////////////////////////////////////////////////////////////////////////
 
 
function bit[31:0] incr_wr(input bit [31:0] addr, input bit [2:0] hsize);
    
    bit [31:0] raddr;
    
    unique case(hsize)
    
     3'b000: begin
          mem[addr]    = hwdata[7:0];
          raddr        = addr + 1; 
     end
     
     3'b001: begin
         mem[addr]     = hwdata[7:0];
         mem[addr + 1] = hwdata[15:8];
         raddr         = addr + 2;
     end
 
     3'b010: begin
         mem[addr]     = hwdata[7:0];
         mem[addr + 1] = hwdata[15:8];
         mem[addr + 2] = hwdata[23:16];
         mem[addr + 3] = hwdata[31:24];
         raddr         = addr + 4;
     end
 endcase
 
return raddr;
 
endfunction
 
////////////////////////////////////////////////////////////////////////////////
////////////////////////////single transfer read
 
function bit[31:0] single_tr_rd (input bit [31:0] addr, input bit [2:0] hsize);
    unique case(hsize)
    3'b000: begin
         hrdata[7:0] = mem[addr];  
    end 
    
    3'b001: begin
         hrdata[7:0]  = mem[addr];
         hrdata[15:8] = mem[addr + 1];
    end
    
    3'b010: begin
         hrdata[7:0]   = mem[addr];
         hrdata[15:8]  = mem[addr + 1];
         hrdata[23:16] = mem[addr + 2];
         hrdata[31:24] = mem[addr + 3];
    end
    endcase
    return addr;
    
endfunction
///////////////////////////////////////////////////////
 
//////////////////////////////////////////////////////////////////////////////////
/////////////////////////////Read for unspec length
function bit[31:0] unincr_rd (input bit [31:0] addr, input bit [2:0] hsize);
    bit [31:0] raddr;
    unique case(hsize)
    
     3'b000: begin
          hrdata[7:0] = mem[addr];
          raddr        = addr + 1; 
     end
     
     3'b001: begin
         hrdata[7:0] = mem[addr];
         hrdata[15:8] = mem[addr + 1];
         raddr         = addr + 2;
     end
 
     3'b010: begin
         hrdata[7:0]   = mem[addr];
         hrdata[15:8]  = mem[addr + 1];
         hrdata[23:16] = mem[addr + 2];
         hrdata[31:24] = mem[addr + 3];
         raddr         = addr + 4;
     end
 endcase
    
return raddr;
 
endfunction
 
//////////////////////////////////////////////////////
/////////////////////////////wrapping read////////////////////////////////////////////////////
function bit[31:0] wrap_rd (input bit [31:0] addr, input bit [7:0] boundary, input [2:0] hsize);
  bit [31:0] addr1, addr2, addr3,addr4;
  
  unique case(hsize)
    3'b000: begin
       hrdata[7:0] = mem[addr];
       
        if((addr + 1) % boundary == 0)
         addr1 = (addr + 1) - boundary;
        else
         addr1 = (addr + 1);
         
       return addr1;  
    end
    
    3'b001: begin
         hrdata[7:0] = mem[addr];
       
        if((addr + 1) % boundary == 0)
         addr1 = (addr + 1) - boundary;
        else
         addr1 = (addr + 1);
         
         hrdata[15:8] = mem[addr1];
         
       if((addr1 + 1) % boundary == 0)
         addr2 = (addr1 + 1) - boundary;
        else
         addr2 = (addr1 + 1);
         
        return addr2;
        
       end
    
    3'b010: begin
        
        hrdata[7:0] = mem[addr];
       
        if((addr + 1) % boundary == 0)
         addr1 = (addr + 1) - boundary;
        else
         addr1 = (addr + 1);
         
        hrdata[15:8] = mem[addr1];
         
       if((addr1 + 1) % boundary == 0)
         addr2 = (addr1 + 1) - boundary;
        else
         addr2 = (addr1 + 1);
         
         hrdata[23:16] = mem[addr2];
        
         if((addr2 + 1) % boundary == 0)
         addr3 = (addr2 + 1) - boundary;
         else
         addr3 = (addr2 + 1); 
         
        hrdata[31:24] = mem[addr3];
        
         if((addr3 + 1) % boundary == 0)
         addr4 = (addr3 + 1) - boundary;
         else
         addr4 = (addr3 + 1); 
       
       return addr4;
    end
    
  
  endcase
  
endfunction
 
/////////////////////////////////////////////////////////////////////////////////////////
function bit[31:0] incr_rd(input bit [31:0] addr, input bit [2:0] hsize);
    
    bit [31:0] raddr;
    
    unique case(hsize)
    
     3'b000: begin
          hrdata[7:0]  = mem[addr];
          raddr        = addr + 1; 
     end
     
     3'b001: begin
         hrdata[7:0]  = mem[addr];
         hrdata[15:8] = mem[addr + 1];
         raddr         = addr + 2;
     end
 
     3'b010: begin
         hrdata[7:0]   = mem[addr];
         hrdata[15:8]  = mem[addr + 1];
         hrdata[23:16] = mem[addr + 2];
         hrdata[31:24] = mem[addr + 3];
         raddr         = addr + 4;
     end
 endcase
 
return raddr;
 
endfunction
 
 
//////////////////////////////////////////////////////////////////////////////////
 
typedef enum  {idle = 0, check_mode = 1, write = 2, read = 3, addr_decode = 4} state_type;
state_type state, next_state;
 
