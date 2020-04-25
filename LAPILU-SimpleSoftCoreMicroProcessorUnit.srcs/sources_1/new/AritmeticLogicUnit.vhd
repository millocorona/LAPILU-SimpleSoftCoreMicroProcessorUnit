----------------------------------------------------------------------------------
-- Company: Escuela Superior de Computo
-- Engineer: Emilio Corona Lopez
-- 
-- Create Date: 03/20/2020 01:20:54 PM
-- Design Name: LAPILU-SimpleSoftcoreMicroProcessorUnit
-- Module Name: AritmeticLogicUnit
-- Project Name:LAPILU-SimpleSoftcoreMicroProcessorUnit 
-- Target Devices: NEXYS-A7, NEXYS-4 DDR
-- Tool Versions: Vivado 2019.2
-- Description: N-bits Aritmetic logic unit with 13 operations; 
--
--      SUM                                                0001 
--      SUBSTRACTION                                       0010
--      INCREMENT BY 1                                     0011  
--      BITWISE OR                                         0100 
--      BITWISE AND                                        0101
--      BITWISE NOT                                        0110
--      BITWISE XOR                                        0111
--      ROTATE THROUGH CARRY TO LEFT                       1000
--      ROTATE THROUGH CARRY TO RIGHT                      1001
--      DECREMENT BY 1                                     1010  
--      TRANSFER                                           OTHERS
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
use work.LAPILU_Aritmetic_Components_PKG.ALL;

entity AritmeticLogicUnit is
    generic (
        LENGTH                 : integer := 8
    );
    port (
        OUT_ENABLE_TO_DATA_BUS   : in  std_logic;
        OUT_ENABLE_TO_ACUMULATOR : in  std_logic;
        OPERATION                : in  std_logic_vector (3 downto 0);
        A_OPERAND                : in  std_logic_vector (LENGTH-1 downto 0);
        B_OPERAND                : in  std_logic_vector (LENGTH-1 downto 0);
        CARRY_IN                 : in  std_logic;
        
        DATA_BUS_OUT             : out std_logic_vector (LENGTH-1 downto 0);
        ACUMULATOR_OUT           : out std_logic_vector (LENGTH-1 downto 0);
        CARRY_OUT                : out std_logic;
        OVERFLOW                 : out std_logic;
        RESULT_IS_NEGATIVE       : out std_logic;
        RESULT_IS_ZERO           : out std_logic
    ); 
end AritmeticLogicUnit;

architecture AritmeticLogicUnitArchitecture of AritmeticLogicUnit is 

    signal ADDER_B_OPERAND            : std_logic_vector (LENGTH-1 downto 0);
    signal ADDER_CARRY_IN             : std_logic;
    
    signal ADDER_CARRY_OUT            : std_logic;
    signal ADDER_RESULT               : std_logic_vector (LENGTH-1 downto 0);
    signal ADDER_OVERFLOW             : std_logic;
    
    signal OR_RESULT                  : std_logic_vector (LENGTH-1 downto 0);
    signal AND_RESULT                 : std_logic_vector (LENGTH-1 downto 0);
    signal NOT_RESULT                 : std_logic_vector (LENGTH-1 downto 0);
    signal XOR_RESULT                 : std_logic_vector (LENGTH-1 downto 0);
    signal RCL_RESULT                 : std_logic_vector (LENGTH-1 downto 0);
    signal RCR_RESULT                 : std_logic_vector (LENGTH-1 downto 0);
    
    signal RESULT              : std_logic_vector (LENGTH-1 downto 0);
begin
    
    NBitsFullAdder: 
        entity work.NBitsFullAdder
            generic map (
                LENGTH   => LENGTH
            )
            port map (
                A_OPERAND       => A_OPERAND,
                B_OPERAND       => ADDER_B_OPERAND,
                CARRY_IN        => ADDER_CARRY_IN,
                SUM             => ADDER_RESULT,
                OVERFLOW_FLAG   => ADDER_OVERFLOW,
                CARRY_OUT       => ADDER_CARRY_OUT
            );
              
            
    NBitsZeroIdentifier:
        entity work.NBitsZeroIdentifier
            generic map (
                LENGTH => LENGTH
            )
            port map (  
                FIRST_HALF  => RESULT(LENGTH-1 downto LENGTH/2),
                SECOND_HALF => RESULT((LENGTH/2)-1 downto 0),
                IS_ZERO     => RESULT_IS_ZERO
            );
    
    --OPERATIONS
    ADDER_B_OPERAND <= B_OPERAND                                           when OPERATION = "0001" else         --SUM
                       not B_OPERAND                                       when OPERATION = "0010" else         --SUB
                       std_logic_vector(to_unsigned(0,LENGTH))             when OPERATION = "0011" else         --INC
                       not (std_logic_vector(to_unsigned(0,LENGTH-1))&'1') when OPERATION = "1010" else         --DEC
                       std_logic_vector(to_unsigned(0,LENGTH));
                       
    ADDER_CARRY_IN  <= CARRY_IN  when OPERATION = "0001" else     --SUM
                       CARRY_IN  when OPERATION = "0010" else     --SUB 
                       '1'       when OPERATION = "0011" else     --INC
                       '1'       when OPERATION = "1010" else     --DEC          
                       '0';
                              
    OR_RESULT       <= A_OPERAND or B_OPERAND;
    AND_RESULT      <= A_OPERAND and B_OPERAND;
    NOT_RESULT      <= not A_OPERAND;
    XOR_RESULT      <= A_OPERAND xor B_OPERAND;
    
    RCL_RESULT(0)<=CARRY_IN;
    RCL_CALCULATOR:
        for i in 1 to LENGTH-1 generate 
            RCL_RESULT(i) <= A_OPERAND(i-1);  
        end generate;
    
    RCR_CALCULATOR:
        for i in 0 to LENGTH-2 generate 
            RCR_RESULT(i) <= A_OPERAND(i+1);  
        end generate;
    RCR_RESULT(LENGTH-1)<=CARRY_IN;

    --RESULT OF OPERATION
    
    RESULT <=    ADDER_RESULT when OPERATION = "0001" else          --SUM
                 ADDER_RESULT when OPERATION = "0010" else          --SUB
                 ADDER_RESULT when OPERATION = "0011" else          --INC
                 OR_RESULT    when OPERATION = "0100" else          --OR
                 AND_RESULT   when OPERATION = "0101" else          --AND
                 NOT_RESULT   when OPERATION = "0110" else          --NOT
                 XOR_RESULT   when OPERATION = "0111" else          --XOR
                 RCL_RESULT   when OPERATION = "1000" else          --RCL
                 RCR_RESULT   when OPERATION = "1001" else          --RCR
                 ADDER_RESULT when OPERATION = "1010" else          --DEC
                 A_OPERAND;                                         --TRANS                
    
    --FLAGS OUTPUTS

    CARRY_OUT <= ADDER_CARRY_OUT        when OPERATION = "0001" else         --SUM
                 ADDER_CARRY_OUT        when OPERATION = "0010" else         --SUB
                 ADDER_CARRY_OUT        when OPERATION = "0011" else         --INC
                 '0'                    when OPERATION = "0100" else         --OR
                 '0'                    when OPERATION = "0101" else         --AND
                 '0'                    when OPERATION = "0110" else         --NOT
                 '0'                    when OPERATION = "0111" else         --XOR
                 A_OPERAND(LENGTH-1)    when OPERATION = "1000" else         --RCL
                 A_OPERAND(0)           when OPERATION = "1001" else         --RCL
                 ADDER_CARRY_OUT        when OPERATION = "1010" else         --DEC
                 CARRY_IN;                                                   --TRANS
                 
    OVERFLOW  <= ADDER_OVERFLOW when OPERATION = "0001" else          --SUM
                 ADDER_OVERFLOW when OPERATION = "0010" else          --SUB
                 ADDER_OVERFLOW when OPERATION = "0011" else          --INC
                 '0'            when OPERATION = "0100" else          --OR
                 '0'            when OPERATION = "0101" else          --AND
                 '0'            when OPERATION = "0110" else          --NOT
                 '0'            when OPERATION = "0111" else          --XOR
                 '0'            when OPERATION = "1000" else          --RCL
                 '0'            when OPERATION = "1001" else          --RCR
                 ADDER_OVERFLOW when OPERATION = "1010" else          --DEC
                 '0';                                                 --TRANS
                 
    RESULT_IS_NEGATIVE<=RESULT(LENGTH-1);
    
    --OUTPUTS TO OTHER MODULES 
    DATA_BUS_OUT<=RESULT when OUT_ENABLE_TO_DATA_BUS = '1';
                 
    ACUMULATOR_OUT<=RESULT when OUT_ENABLE_TO_ACUMULATOR = '1';

end AritmeticLogicUnitArchitecture;
