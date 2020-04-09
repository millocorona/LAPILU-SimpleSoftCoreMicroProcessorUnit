----------------------------------------------------------------------------------
-- Company: Escuela Superior de Computo
-- Engineer: Emilio Corona Lopez
-- 
-- Create Date: 03/20/2020 01:20:54 PM
-- Design Name: LAPILU-SimpleSoftcoreMicroProcessorUnit
-- Module Name: NBitsRegister - NBitsRegisterArchitecture
-- Project Name:LAPILU-SimpleSoftcoreMicroProcessorUnit 
-- Target Devices: NEXYS-A7, NEXYS-4 DDR
-- Tool Versions: Vivado 2019.2
-- Description: Parametizable length parallel input - parallel output synchronous register with async reset, load and output enable
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

entity NBitsRegister is
    generic (
        LENGTH       : integer := 8
    );
    port (  
        CLOCK         : in std_logic;
        RESET         : in std_logic; 
        LOAD          : in std_logic;
        OUTPUT_ENABLE : in std_logic;
        DATA_INPUT    : in  std_logic_vector (LENGTH-1 downto 0);
        DATA_OUTPUT   : out std_logic_vector (LENGTH-1 downto 0)
    );
end NBitsRegister;


architecture NBitsRegisterArchitecture of NBitsRegister is
    signal DATA_BUFFER : std_logic_vector (LENGTH-1 downto 0);
begin

    process(CLOCK, RESET) begin
        if RESET = '1' then
            DATA_BUFFER<=std_logic_vector(to_unsigned(0,LENGTH)); 
        elsif rising_edge(CLOCK) then
            if LOAD = '1' then
                DATA_BUFFER <= DATA_INPUT; 
            end if;
            if OUTPUT_ENABLE = '1' then
                DATA_OUTPUT<=DATA_BUFFER;
            else
                DATA_OUTPUT<=std_logic_vector(to_unsigned(0,LENGTH));
            end if;
        end if;
    end process;
        
end NBitsRegisterArchitecture;
