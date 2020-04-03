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
-- Description: Parametizable length acumulator
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

entity NBitsAcumulator is
    generic (
        LENGTH       : integer := 8
    );
    port (  
        CLOCK                      : in std_logic;
        RESET                      : in std_logic; 
        
        LOAD_FROM_DATA_BUS         : in std_logic;
        OUTPUT_ENABLE_TO_DATA_BUS  : in std_logic;
        DATA_BUS_IN                : in  std_logic_vector (LENGTH-1 downto 0);
        DATA_BUS_OUT               : out std_logic_vector (LENGTH-1 downto 0);
 
        LOAD_FROM_ALU              : in std_logic;
        OUTPUT_ENABLE_TO_ALU       : in std_logic;
        ALU_BUS_IN                 : in  std_logic_vector (LENGTH-1 downto 0);
        ALU_BUS_OUT                : out  std_logic_vector (LENGTH-1 downto 0)
    );
end NBitsAcumulator;


architecture NBitsAcumulatorArchitecture of NBitsAcumulator is
    signal DATA_BUFFER : std_logic_vector (LENGTH-1 downto 0);
begin
    
    process(CLOCK, RESET) begin
        if RESET = '1' then
            DATA_BUFFER<=std_logic_vector(to_unsigned(0,LENGTH));
            ALU_BUS_OUT<=std_logic_vector(to_unsigned(0,LENGTH));
            DATA_BUS_OUT<=std_logic_vector(to_unsigned(0,LENGTH));
        elsif rising_edge(CLOCK) then
            if LOAD_FROM_DATA_BUS = '1' then
                DATA_BUFFER<=DATA_BUS_IN;
            end if;
            if OUTPUT_ENABLE_TO_DATA_BUS = '1' then
                DATA_BUS_OUT<=DATA_BUFFER;
            else
                DATA_BUS_OUT<=std_logic_vector(to_unsigned(0,LENGTH));
            end if;
            if LOAD_FROM_ALU = '1' then
                DATA_BUFFER <= ALU_BUS_IN; 
            end if;
            if OUTPUT_ENABLE_TO_ALU = '1' then
                ALU_BUS_OUT<=DATA_BUFFER;
            else
                ALU_BUS_OUT<=std_logic_vector(to_unsigned(0,LENGTH));
            end if;    
        end if;
    end process;
    
    
    
        
    
end NBitsAcumulatorArchitecture;
