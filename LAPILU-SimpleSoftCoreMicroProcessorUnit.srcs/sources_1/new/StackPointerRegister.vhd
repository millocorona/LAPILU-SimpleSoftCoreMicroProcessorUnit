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
use work.LAPILU_Aritmetic_Components_PKG.ALL;

entity StackPointerRegister is
    generic (
        DATA_BUS_LENGTH       : integer := 8;
        ADDRESS_BUS_LENGTH    : integer := 16
    );
    port (  
        CLOCK                        : in std_logic;
        RESET                        : in std_logic; 
        
        INCREMENT_STACK_POINTER      : in std_logic;
        DECREMENT_STACK_POINTER      : in std_logic;
        
        LOAD_FROM_DATA_BUS           : in std_logic;
        DATA_INPUT_FROM_DATA_BUS     : in  std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
        
        OUTPUT_ENABLE_TO_DATA_BUS    : in std_logic;
        DATA_OUTPUT_TO_DATA_BUS      : out std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
        
        OUTPUT_ENABLE_TO_ADDRESS_BUS : in std_logic;
        DATA_OUTPUT_TO_ADDRESS_BUS   : out std_logic_vector (ADDRESS_BUS_LENGTH-1 downto 0)
    );
end StackPointerRegister;


architecture StackPointerRegisterArchitecture of StackPointerRegister is
    signal DATA_BUFFER         : std_logic_vector (DATA_BUS_LENGTH-1 downto 0):=std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH));
    signal ADDER_RESULT_BUFFER : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
    signal ADDER_B_OPERAND     : std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
begin
    
    NBitsFullAdder: 
        entity work.NBitsFullAdder
            generic map (
                LENGTH   => DATA_BUS_LENGTH
            )
            port map (
                A_OPERAND     => DATA_BUFFER,
                B_OPERAND     => ADDER_B_OPERAND,
                CARRY_IN      => '1',
                SUM           => ADDER_RESULT_BUFFER,
                OVERFLOW_FLAG => open,
                CARRY_OUT     => open
            );
    
    ADDER_B_OPERAND<= std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH))              when (INCREMENT_STACK_POINTER = '1') else
                      not (std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH-1))&'1')  when (DECREMENT_STACK_POINTER = '1');
    process(CLOCK, RESET) begin
        if RESET = '1' then
            DATA_BUFFER<=std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH)); 
        elsif rising_edge(CLOCK) then
            if INCREMENT_STACK_POINTER = '1' or DECREMENT_STACK_POINTER = '1' then
                DATA_BUFFER<=ADDER_RESULT_BUFFER;
            end if;
            if LOAD_FROM_DATA_BUS = '1' then
                DATA_BUFFER <= DATA_INPUT_FROM_DATA_BUS; 
            end if;
            if OUTPUT_ENABLE_TO_DATA_BUS = '1' then
                DATA_OUTPUT_TO_DATA_BUS<=DATA_BUFFER;
            end if;
            if OUTPUT_ENABLE_TO_ADDRESS_BUS = '1' then
                for i in 0 to DATA_BUS_LENGTH-1 loop
                     DATA_OUTPUT_TO_ADDRESS_BUS(i)<=DATA_BUFFER(i);
                end loop;
                DATA_OUTPUT_TO_ADDRESS_BUS(DATA_BUS_LENGTH)<='1';
                for i in DATA_BUS_LENGTH+1 to ADDRESS_BUS_LENGTH-1 loop
                     DATA_OUTPUT_TO_ADDRESS_BUS(i)<='0';
                end loop;
            end if;
        end if;
    end process;
        
end StackPointerRegisterArchitecture;
