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
        RESET                    : in  std_logic;
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
    signal ADDER_CARRY_PENULTIMATE_BIT: std_logic;
    
    signal ADDER_RESULT               : std_logic_vector (LENGTH-1 downto 0);
    signal LOGIC_RESULT               : std_logic_vector (LENGTH-1 downto 0);
    
    signal RESULT_BUFFER              : std_logic_vector (LENGTH-1 downto 0);
    signal CARRY_OUT_BUFFER           : std_logic;
    signal OVERFLOW_BUFFER            : std_logic;
    signal RESULT_IS_ZERO_BUFFER      : std_logic;
begin
    
    process(RESET) begin
        DATA_BUS_OUT<=std_logic_vector(to_unsigned(0,LENGTH));
        ACUMULATOR_OUT<=std_logic_vector(to_unsigned(0,LENGTH));

        RESULT_IS_NEGATIVE<='0';    
        RESULT_IS_ZERO<='1';
        CARRY_OUT<='0';
        OVERFLOW<='0'; 
        ADDER_B_OPERAND <= std_logic_vector(to_unsigned(0,LENGTH));
        ADDER_CARRY_IN   <= '0';
        ADDER_CARRY_OUT    <= '0';
        ADDER_CARRY_PENULTIMATE_BIT <= '0';
        
        ADDER_RESULT  <= std_logic_vector(to_unsigned(0,LENGTH));
        LOGIC_RESULT   <= std_logic_vector(to_unsigned(0,LENGTH));
       
        RESULT_BUFFER     <= std_logic_vector(to_unsigned(0,LENGTH));
        CARRY_OUT_BUFFER   <= '0';
        OVERFLOW_BUFFER     <= '0';
        RESULT_IS_ZERO_BUFFER <= '1';
    end process;
    
    NBitsFullAdder: 
        entity work.NBitsFullAdder
            generic map (
                LENGTH   => LENGTH
            )
            port map (
                A_OPERAND  => A_OPERAND,
                B_OPERAND  => ADDER_B_OPERAND,
                CARRY_IN   => ADDER_CARRY_IN,
                SUM        => ADDER_RESULT,
                CARRY_PENULTIMATE_BIT => ADDER_CARRY_PENULTIMATE_BIT,
                CARRY_OUT  => ADDER_CARRY_OUT
            );
    NBitsZeroIdentifier:
        entity work.NBitsZeroIdentifier
            generic map (
                LENGTH => LENGTH
            )
            port map (  
                FIRST_HALF => RESULT_BUFFER(LENGTH-1 downto LENGTH/2),
                SECOND_HALF => RESULT_BUFFER((LENGTH/2)-1 downto 0),
                IS_ZERO => RESULT_IS_ZERO_BUFFER
            );
    process (OPERATION) begin
        case OPERATION is
            when "0001" => --SUM
                ADDER_CARRY_IN<=CARRY_IN;
                ADDER_B_OPERAND<=B_OPERAND;
                RESULT_BUFFER<=ADDER_RESULT;
                CARRY_OUT_BUFFER<=ADDER_CARRY_OUT;              
                OVERFLOW_BUFFER <= not (((A_OPERAND(LENGTH-1) nor ADDER_B_OPERAND(LENGTH-1)) and ADDER_CARRY_PENULTIMATE_BIT) nor ((A_OPERAND(LENGTH-1) nand ADDER_B_OPERAND(LENGTH-1)) nor ADDER_CARRY_PENULTIMATE_BIT));
            when "0010" => --SUB
                ADDER_CARRY_IN<='1';
                ADDER_B_OPERAND<=not B_OPERAND;
                RESULT_BUFFER<=ADDER_RESULT;
                CARRY_OUT_BUFFER<=ADDER_CARRY_OUT;              
                OVERFLOW_BUFFER <= not (((A_OPERAND(LENGTH-1) nor ADDER_B_OPERAND(LENGTH-1)) and ADDER_CARRY_PENULTIMATE_BIT) nor ((A_OPERAND(LENGTH-1) nand ADDER_B_OPERAND(LENGTH-1)) nor ADDER_CARRY_PENULTIMATE_BIT));                
            when "0011" =>--INC
                --Operation
                ADDER_CARRY_IN<='1';
                ADDER_B_OPERAND<= STD_LOGIC_VECTOR(TO_UNSIGNED(0,LENGTH));
                RESULT_BUFFER<=ADDER_RESULT;
                CARRY_OUT_BUFFER<=ADDER_CARRY_OUT;              
                OVERFLOW_BUFFER <= not (((A_OPERAND(LENGTH-1) nor ADDER_B_OPERAND(LENGTH-1)) and ADDER_CARRY_PENULTIMATE_BIT) nor ((A_OPERAND(LENGTH-1) nand ADDER_B_OPERAND(LENGTH-1)) nor ADDER_CARRY_PENULTIMATE_BIT));            
            when "0100" => --OR
                LOGIC_RESULT<=A_OPERAND or B_OPERAND;
                RESULT_BUFFER<=LOGIC_RESULT;
                CARRY_OUT_BUFFER<='0';             
                OVERFLOW_BUFFER <='0';
            when "0101" => -- AND
                LOGIC_RESULT<=A_OPERAND and B_OPERAND;
                RESULT_BUFFER<=LOGIC_RESULT;
                CARRY_OUT_BUFFER<='0';             
                OVERFLOW_BUFFER <='0';     
            when "0110" => --NOT
                LOGIC_RESULT <= not A_OPERAND ;
                RESULT_BUFFER<=LOGIC_RESULT;
                CARRY_OUT_BUFFER<='0';             
                OVERFLOW_BUFFER <='0';
            when "0111" => --XOR
                LOGIC_RESULT<=A_OPERAND xor B_OPERAND;
                RESULT_BUFFER<=LOGIC_RESULT;
                CARRY_OUT_BUFFER<='0';             
                OVERFLOW_BUFFER <='0';                                     
            when "1000" => --RCL
                LOGIC_RESULT(0)<=CARRY_IN;
                for i in 1 to LENGTH-1 loop 
                    LOGIC_RESULT(i) <= A_OPERAND(i-1);  
                end loop;
                RESULT_BUFFER<=LOGIC_RESULT;
                CARRY_OUT_BUFFER<=A_OPERAND(LENGTH-1);             
                OVERFLOW_BUFFER <='0';                             
            when "1001" => --RCR
                LOGIC_RESULT(LENGTH-1)<=CARRY_IN;
                for i in 0 to LENGTH-2 loop 
                    LOGIC_RESULT(i) <= A_OPERAND(i+1);  
                end loop;
                RESULT_BUFFER<=LOGIC_RESULT;
                CARRY_OUT_BUFFER<=A_OPERAND(0);             
                OVERFLOW_BUFFER <='0'; 
            when "1010" => --DEC
                 --Operation
                ADDER_CARRY_IN<='1';
                ADDER_B_OPERAND<=not (STD_LOGIC_VECTOR(TO_UNSIGNED(0,LENGTH-1))&'1');
                RESULT_BUFFER<=ADDER_RESULT;
                CARRY_OUT_BUFFER<=ADDER_CARRY_OUT;              
                OVERFLOW_BUFFER <= not (((A_OPERAND(LENGTH-1) nor ADDER_B_OPERAND(LENGTH-1)) and ADDER_CARRY_PENULTIMATE_BIT) nor ((A_OPERAND(LENGTH-1) nand ADDER_B_OPERAND(LENGTH-1)) nor ADDER_CARRY_PENULTIMATE_BIT));                           
            when others => --TRANS
                RESULT_BUFFER<=A_OPERAND;
                CARRY_OUT_BUFFER<=CARRY_IN;             
                OVERFLOW_BUFFER <='0';          
        end case;
    end process;

    process (OUT_ENABLE_TO_DATA_BUS) begin
        if (OUT_ENABLE_TO_DATA_BUS = '1') then 
            DATA_BUS_OUT<=RESULT_BUFFER;
            RESULT_IS_NEGATIVE<=RESULT_BUFFER(LENGTH-1);    
            RESULT_IS_ZERO<=RESULT_IS_ZERO_BUFFER;
            CARRY_OUT<=CARRY_OUT_BUFFER;
            OVERFLOW<=OVERFLOW_BUFFER;
        else
            DATA_BUS_OUT<=std_logic_vector(to_unsigned(0,LENGTH));
            RESULT_IS_NEGATIVE<='0';    
            RESULT_IS_ZERO<='1';
            CARRY_OUT<='0';
            OVERFLOW<='0';        
        end if;        
    end process;
    
   process (OUT_ENABLE_TO_ACUMULATOR) begin
        if (OUT_ENABLE_TO_ACUMULATOR = '1') then 
            ACUMULATOR_OUT<=RESULT_BUFFER;
            RESULT_IS_NEGATIVE<=RESULT_BUFFER(LENGTH-1);    
            RESULT_IS_ZERO<=RESULT_IS_ZERO_BUFFER;
            CARRY_OUT<=CARRY_OUT_BUFFER;
            OVERFLOW<=OVERFLOW_BUFFER;
        else
            ACUMULATOR_OUT<=std_logic_vector(to_unsigned(0,LENGTH));
            RESULT_IS_NEGATIVE<='0';    
            RESULT_IS_ZERO<='1';
            CARRY_OUT<='0';
            OVERFLOW<='0'; 
        end if;        
    end process;

end AritmeticLogicUnitArchitecture;
