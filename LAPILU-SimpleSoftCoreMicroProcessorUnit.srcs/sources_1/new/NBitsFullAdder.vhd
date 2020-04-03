----------------------------------------------------------------------------------
-- Company: Escuela Superior de Computo
-- Engineer: Emilio Corona Lopez
-- 
-- Create Date: 03/20/2020 01:20:54 PM
-- Design Name: LAPILU-SimpleSoftcoreMicroProcessorUnit
-- Module Name:  NBitsFullAdder
-- Project Name:LAPILU-SimpleSoftcoreMicroProcessorUnit 
-- Target Devices: NEXYS-A7, NEXYS-4 DDR
-- Tool Versions: Vivado 2019.2
-- Description: N-bits full adder using one bits adder in a chain
-- 
-- Dependencies: 
-- 
-- Revision:0.02
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

-- ONE BIT FULL ADDER IMPLEMENTATION

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity OneBitFullAdder is
    port ( 
        A_OPERAND : in std_logic;
        B_OPERAND : in std_logic;
        CARRY_IN  : in std_logic;
        SUM       : out std_logic;
        CARRY_OUT : out std_logic
    );
end OneBitFullAdder;

architecture OneBitFullAdderArchitecture of OneBitFullAdder is begin

    SUM <= ((A_OPERAND xor B_OPERAND) xor CARRY_IN);
    
    CARRY_OUT <= (CARRY_IN and (A_OPERAND or B_OPERAND)) or (B_OPERAND and A_OPERAND);

end OneBitFullAdderArchitecture;

-- NOW WE USE N ONE BIT ADDER IN CHAIN TO CREATE AN N BIT FULL ADDER

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 

entity NBitsFullAdder is
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
end NBitsFullAdder;

architecture NBitsFullAdderArchitecture of NBitsFullAdder is 

    component OneBitFullAdder is
        port ( 
            A_OPERAND : in std_logic;
            B_OPERAND : in std_logic;
            CARRY_IN  : in std_logic;
            SUM       : out std_logic;
            CARRY_OUT : out std_logic
        );
    end component;
    
    signal CARRYS:std_logic_vector (LENGTH downto 0);
begin

    CARRYS(0) <= CARRY_IN;
    CARRY_OUT <= CARRYS(LENGTH);  
    CARRY_PENULTIMATE_BIT <= CARRYS(LENGTH-1);
    FOR_TO_GENERATE_ADDERS: 
        for i in 0 to LENGTH-1
            generate
                ADDER_i:OneBitFullAdder PORT MAP (A_OPERAND(i),B_OPERAND(i),CARRYS(i),SUM(i),CARRYS(i+1));
            end generate;
    
end NBitsFullAdderArchitecture;
