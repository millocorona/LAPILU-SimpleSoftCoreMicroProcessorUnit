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

package LAPILU_Aritmetic_Components_PKG is
   component NBitsFullAdder is
        generic (
            LENGTH       : integer := 8
        );
        port (  
            A_OPERAND             : in std_logic_vector (LENGTH-1 downto 0);
            B_OPERAND             : in std_logic_vector (LENGTH-1 downto 0);
            CARRY_IN              : in std_logic;
            SUM                   : out std_logic_vector (LENGTH-1 downto 0);
            CARRY_PENULTIMATE_BIT : out std_logic;
            CARRY_OUT             : out std_logic
        );
    end component;
   
   component NBitsZeroIdentifier is
        generic (
            LENGTH       : integer := 8
        );
        port (  
            FIRST_HALF              : in std_logic_vector (LENGTH/2 downto 0);
            SECOND_HALF             : in std_logic_vector (LENGTH/2 downto 0);
            IS_ZERO                 : out std_logic
        );
    end component;
   
end LAPILU_Aritmetic_Components_PKG;