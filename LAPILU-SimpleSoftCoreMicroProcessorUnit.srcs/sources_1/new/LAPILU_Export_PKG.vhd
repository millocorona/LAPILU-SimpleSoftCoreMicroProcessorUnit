----------------------------------------------------------------------------------
-- Company: Escuela Superior de Computo
-- Engineer: Emilio Corona Lopez
-- 
-- Create Date: 03/20/2020 01:20:54 PM
-- Design Name: LAPILU-SimpleSoftcoreMicroProcessorUnit
-- Module Name: 
-- Project Name:LAPILU-SimpleSoftcoreMicroProcessorUnit 
-- Target Devices: NEXYS-A7, NEXYS-4 DDR
-- Tool Versions: Vivado 2019.2
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:0.02
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;   

package LAPILU_Export_PKG is
    
    component LAPILU is
        generic (
            DATA_BUS_LENGTH    : integer := 8; -- This value needs to be an even number GRATER OR EQUAL TO 8 
            ADDRESS_BUS_LENGTH : integer := 16 -- This value, should be between DATA_BUS_LENGTH and 2 * DATA_BUS_LENGTH, 
                                               -- due to how the program counter, memory address register and stack pointer works  
        );
        port (
            CLOCK           : in     std_logic;
            INVERTED_CLOCK  : out    std_logic;
            DATA_BUS_IN     : in     std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
            DATA_BUS_OUT    : out    std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
            ADDRESS_BUS     : out    std_logic_vector (ADDRESS_BUS_LENGTH-1 downto 0);
            RW              : out    std_logic; --HIGH is READ,LOW is WRITE
            IRQ             : in     std_logic;
            CPU_RESET       : in     std_logic
        ); 
    end component;
   
end LAPILU_Export_PKG;