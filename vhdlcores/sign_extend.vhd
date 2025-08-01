----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.05.2020 19:42:58
-- Design Name: 
-- Module Name: sign_extend - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sign_extend is
    generic(in_width : integer := 14); 
    Port ( data_in : in STD_LOGIC_VECTOR (in_width-1 downto 0);
           data_out : out STD_LOGIC_VECTOR (15 downto 0));
end sign_extend;

architecture Behavioral of sign_extend is

begin
    data_out(in_width-1 downto 0)<=data_in(in_width-1 downto 0);
    data_out(15 downto in_width)<= (others => data_in(in_width-1));
end Behavioral;
