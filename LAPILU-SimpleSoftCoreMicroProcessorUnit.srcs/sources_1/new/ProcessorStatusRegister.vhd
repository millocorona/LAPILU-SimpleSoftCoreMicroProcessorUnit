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

entity ProcessorStatusRegister is
    generic (
        DATA_BUS_LENGTH       : integer := 8
    );
    port (  
        CLOCK                        : in std_logic;
        RESET                        : in std_logic;
        LOAD_FROM_ALU                : in std_logic;
        ALU_IN_FLAG_CARRY            : in std_logic;
        ALU_IN_FLAG_OVERFLOW         : in std_logic;
        ALU_IN_FLAG_ZERO             : in std_logic;
        ALU_IN_FLAG_NEGATIVE         : in std_logic;
        
        SET_CARRY_FLAG               : in std_logic;
        SET_OVERFLOW_FLAG            : in std_logic;
        SET_ZERO_FLAG                : in std_logic;
        SET_NEGATIVE_FLAG            : in std_logic;
        SET_IRQ_DISABLE_FLAG         : in std_logic;

        CLEAR_CARRY_FLAG             : in std_logic;
        CLEAR_OVERFLOW_FLAG          : in std_logic;
        CLEAR_ZERO_FLAG              : in std_logic;
        CLEAR_NEGATIVE_FLAG          : in std_logic;
        CLEAR_IRQ_DISABLE_FLAG       : in std_logic;
        
        SIGNAL_OUT_FLAG_CARRY        : out std_logic;
        SIGNAL_OUT_FLAG_OVERFLOW     : out std_logic;
        SIGNAL_OUT_FLAG_ZERO         : out std_logic;
        SIGNAL_OUT_FLAG_NEGATIVE     : out std_logic;
        SIGNAL_OUT_FLAG_IRQ_DISABLE  : out std_logic;

        LOAD_FROM_DATA_BUS          : in std_logic;
        ENABLE_OUTPUT_TO_DATA_BUS   : in std_logic;
        DATA_BUS_INPUT              : in  std_logic_vector (DATA_BUS_LENGTH-1 downto 0);
        DATA_BUS_OUTPUT             : out std_logic_vector (DATA_BUS_LENGTH-1 downto 0)
    );
end ProcessorStatusRegister;


architecture ProcessorStatusRegisterArchitecture of ProcessorStatusRegister is
       signal SIGNAL_BUFFER_FLAG_CARRY        : std_logic;
       signal SIGNAL_BUFFER_FLAG_OVERFLOW     : std_logic;
       signal SIGNAL_BUFFER_FLAG_ZERO         : std_logic;
       signal SIGNAL_BUFFER_FLAG_NEGATIVE     : std_logic;
       signal SIGNAL_BUFFER_FLAG_IRQ_DISABLE  : std_logic;
begin

    process(CLOCK, RESET) begin
        if RESET = '1' then
            SIGNAL_BUFFER_FLAG_CARRY<='0';
            SIGNAL_BUFFER_FLAG_OVERFLOW<='0';
            SIGNAL_BUFFER_FLAG_ZERO<='1';
            SIGNAL_BUFFER_FLAG_NEGATIVE<='0';
            SIGNAL_BUFFER_FLAG_IRQ_DISABLE<='1';            
        elsif rising_edge(CLOCK) then
            if LOAD_FROM_ALU = '1' then
                SIGNAL_BUFFER_FLAG_CARRY<=ALU_IN_FLAG_CARRY;
                SIGNAL_BUFFER_FLAG_OVERFLOW<=ALU_IN_FLAG_OVERFLOW;
                SIGNAL_BUFFER_FLAG_ZERO<=ALU_IN_FLAG_ZERO;
                SIGNAL_BUFFER_FLAG_NEGATIVE<=ALU_IN_FLAG_NEGATIVE;
            end if;
            
            if SET_CARRY_FLAG = '1' then
                SIGNAL_BUFFER_FLAG_CARRY<='1';
            end if;
            
            if SET_OVERFLOW_FLAG = '1' then
                SIGNAL_BUFFER_FLAG_OVERFLOW<='1';
            end if;
            
            if SET_ZERO_FLAG = '1' then
                SIGNAL_BUFFER_FLAG_ZERO<='1';
            end if;
            
            if SET_NEGATIVE_FLAG = '1' then
                SIGNAL_BUFFER_FLAG_NEGATIVE<='1';
            end if;
            
            if SET_IRQ_DISABLE_FLAG = '1' then
                SIGNAL_BUFFER_FLAG_IRQ_DISABLE<='1';
            end if;
            
            if CLEAR_CARRY_FLAG = '1' then
                SIGNAL_BUFFER_FLAG_CARRY<='0';
            end if;
            
            if CLEAR_OVERFLOW_FLAG = '1' then
                SIGNAL_BUFFER_FLAG_OVERFLOW<='0';
            end if;
            
            if CLEAR_ZERO_FLAG = '1' then
                SIGNAL_BUFFER_FLAG_ZERO<='0';
            end if;
            
            if CLEAR_NEGATIVE_FLAG = '1' then
                SIGNAL_BUFFER_FLAG_NEGATIVE<='0';
            end if;
            
            if CLEAR_IRQ_DISABLE_FLAG = '1' then
                SIGNAL_BUFFER_FLAG_IRQ_DISABLE<='0';
            end if;
            
            if LOAD_FROM_DATA_BUS = '1' then
                SIGNAL_BUFFER_FLAG_CARRY<=DATA_BUS_INPUT(0);
                SIGNAL_BUFFER_FLAG_OVERFLOW<=DATA_BUS_INPUT(1);
                SIGNAL_BUFFER_FLAG_ZERO<=DATA_BUS_INPUT(2);
                SIGNAL_BUFFER_FLAG_NEGATIVE<=DATA_BUS_INPUT(3);
                SIGNAL_BUFFER_FLAG_IRQ_DISABLE<=DATA_BUS_INPUT(4);  
            end if;
            if ENABLE_OUTPUT_TO_DATA_BUS = '1' then
                DATA_BUS_OUTPUT(0)<=SIGNAL_BUFFER_FLAG_CARRY;
                DATA_BUS_OUTPUT(1)<=SIGNAL_BUFFER_FLAG_OVERFLOW;
                DATA_BUS_OUTPUT(2)<=SIGNAL_BUFFER_FLAG_ZERO;
                DATA_BUS_OUTPUT(3)<=SIGNAL_BUFFER_FLAG_NEGATIVE;
                DATA_BUS_OUTPUT(4)<=SIGNAL_BUFFER_FLAG_IRQ_DISABLE;
                for i in 5 to DATA_BUS_LENGTH-1 loop
                    DATA_BUS_OUTPUT(i)<='0';
                end loop;
            else 
                DATA_BUS_OUTPUT<=std_logic_vector(to_unsigned(0,DATA_BUS_LENGTH));
            end if;
        end if;
    end process;
    
    SIGNAL_OUT_FLAG_CARRY<=SIGNAL_BUFFER_FLAG_CARRY;
    SIGNAL_OUT_FLAG_OVERFLOW<=SIGNAL_BUFFER_FLAG_OVERFLOW; 
    SIGNAL_OUT_FLAG_ZERO<=SIGNAL_BUFFER_FLAG_ZERO;    
    SIGNAL_OUT_FLAG_NEGATIVE<=SIGNAL_BUFFER_FLAG_NEGATIVE; 
    SIGNAL_OUT_FLAG_IRQ_DISABLE<=SIGNAL_BUFFER_FLAG_IRQ_DISABLE; 
        
end ProcessorStatusRegisterArchitecture;