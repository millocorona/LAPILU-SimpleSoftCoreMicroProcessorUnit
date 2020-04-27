----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2020 02:11:05 PM
-- Design Name: 
-- Module Name: InterruptHandler - InterruptHandlerArchitecture
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InterruptHandler is 
    generic (
        DATA_BUS_LENGTH       : integer := 8;
        ADDRESS_BUS_LENGTH    : integer := 16
    ); 
    port (
        RESET                                           : in  std_logic;
        IRQ                                             : in  std_logic;
        IRQ_DISABLE_FLAG                                : in  std_logic;
        IRQ_PENDING                                     : out std_logic;
        OUTPUT_ENABLE_INTERRUPT_VECTOR_LOW_TO_DATA_BUS  : in  std_logic;
        OUTPUT_ENABLE_INTERRUPT_VECTOR_HIGH_TO_DATA_BUS : in  std_logic;
        INTERRUPT_VECTOR_DATA_BUS_OUTPUT                : out std_logic_vector(DATA_BUS_LENGTH-1 downto 0)
     );
end InterruptHandler;

architecture InterruptHandlerArchitecture of InterruptHandler is
    signal IRQ_SIGNAL_BUFFER : std_logic:='0';
begin
    process (RESET,OUTPUT_ENABLE_INTERRUPT_VECTOR_LOW_TO_DATA_BUS,OUTPUT_ENABLE_INTERRUPT_VECTOR_HIGH_TO_DATA_BUS,IRQ) begin
       if(RESET = '1' ) then
          IRQ_SIGNAL_BUFFER<='0';
       elsif OUTPUT_ENABLE_INTERRUPT_VECTOR_LOW_TO_DATA_BUS = '1' then
            for i in 0 to DATA_BUS_LENGTH-1 loop
                INTERRUPT_VECTOR_DATA_BUS_OUTPUT(i)<='0';
            end loop;            
       elsif OUTPUT_ENABLE_INTERRUPT_VECTOR_HIGH_TO_DATA_BUS = '1' then
            INTERRUPT_VECTOR_DATA_BUS_OUTPUT(DATA_BUS_LENGTH)  <='0';
            INTERRUPT_VECTOR_DATA_BUS_OUTPUT(DATA_BUS_LENGTH+1)<='0';
            for i in 2 to DATA_BUS_LENGTH-1 loop
                INTERRUPT_VECTOR_DATA_BUS_OUTPUT(i)<='0';
            end loop;
       elsif(rising_edge(IRQ)) then 
           if (IRQ_DISABLE_FLAG = '0') then
               IRQ_SIGNAL_BUFFER<=IRQ;    
           end if;
       end if;
    end process;
    IRQ_PENDING<=IRQ_SIGNAL_BUFFER;
end InterruptHandlerArchitecture;
