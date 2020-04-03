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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;   

entity NBitsZeroIdentifier is
    generic (
        LENGTH       : integer := 8
    );
    port (  
        FIRST_HALF              : in std_logic_vector ((LENGTH/2)-1 downto 0);
        SECOND_HALF             : in std_logic_vector ((LENGTH/2)-1 downto 0);
        IS_ZERO                 : out std_logic
    );
end NBitsZeroIdentifier;

architecture NBitsZeroIdentifierArchitecture of NBitsZeroIdentifier is
    signal NOR_RESULTS : std_logic_vector (LENGTH/2 downto 0);
    signal AND_RESULTS: std_logic_vector((LENGTH/2)-1 downto 0);
begin

    FOR_TO_GENERATE_NORS: 
        for i in 0 to (LENGTH/2)-1
            generate
                NOR_RESULTS(i) <= FIRST_HALF(i) nor SECOND_HALF(i); 
            end generate;
    
    AND_RESULTS(0) <= NOR_RESULTS(0);
    
    FOR_TO_GENERATE_ANDS: 
        for i in 1 to (LENGTH/2)-1 generate
            AND_RESULTS(i) <= AND_RESULTS(i-1) and NOR_RESULTS(i);
        end generate; 
    
    IS_ZERO <= AND_RESULTS((LENGTH/2)-1);    

end NBitsZeroIdentifierArchitecture;
