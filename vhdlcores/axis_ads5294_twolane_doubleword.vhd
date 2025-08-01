
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity axi_ads5294_twolane_doubleword is
    generic(NUMBER_OF_LANES : integer := 1); 
    Port (  bit_clock: in STD_LOGIC;
            din_a_p : in STD_LOGIC_VECTOR (NUMBER_OF_LANES-1 downto 0);
            din_a_n : in STD_LOGIC_VECTOR (NUMBER_OF_LANES-1 downto 0);
            din_b_p : in STD_LOGIC_VECTOR (NUMBER_OF_LANES-1 downto 0);
            din_b_n : in STD_LOGIC_VECTOR (NUMBER_OF_LANES-1 downto 0);
            frame_clock_p: in STD_LOGIC;
            frame_clock_n: in STD_LOGIC;
            sample_clk: in STD_LOGIC;
            half_clk: in STD_LOGIC;
            bit_slip: in STD_LOGIC;        
           data_out : out STD_LOGIC_VECTOR (13 downto 0);           
           serdes_rst : in STD_LOGIC);
end axi_ads5294_twolane_doubleword;

architecture Behavioral of axi_ads5294_twolane_doubleword is

signal din_a_ibuf_s,din_b_ibuf_s: std_logic_vector(NUMBER_OF_LANES-1 downto 0);
signal din_a_idelay_s,din_b_idelay_s: std_logic_vector(NUMBER_OF_LANES-1 downto 0);
signal data_a_shift1_s, data_a_shift2_s, data_b_shift1_s, data_b_shift2_s: std_logic_vector(NUMBER_OF_LANES-1 downto 0);

signal frame_clock_ibuf_s, bit_slip_i, bit_clock_inv: std_logic;

signal data_first, data_second, data_int: std_logic_vector(13 downto 0);
signal data_both: std_logic_vector(27 downto 0);

signal matched: std_logic;

type state_type is (idle, active, checking, waiting);
signal state: state_type := idle;
signal counter: integer := 0;
constant waitcount: integer := 28;

begin

    bit_clock_inv <= not bit_clock;
    
    matched <= '1' when ((data_first = "11111111111111") and (data_second = "00000000000000")) else '0'; 

      process(sample_clk,state,bit_slip)
      begin
      if falling_edge(sample_clk) then
        if(serdes_rst='1') then
            bit_slip_i <= '0';
            state <= idle; 
        else
            case state is
                when idle =>
                    if(bit_slip='1') then
                        bit_slip_i <= '1';
                        state <= active;
                        counter <= 0;
                    else 
                        state <= idle;
                    end if;
                when active =>
                    bit_slip_i <= '0';
                    counter <= counter + 1;
                    if (counter=waitcount) then
                        state <= checking;
                    else
                        state <= active;
                    end if; 
                when checking =>
                    if (matched='1') then
                        state <= waiting;
                    else
                        state <= idle;
                    end if;
                when waiting =>
                    if(bit_slip='0') then
                        state <= idle;
                    else 
                        state <= waiting;
                    end if;
                when others =>
                    state <= idle; 
            end case;
        end if;
      end if;
      end process;

    g_io: for i in 0 to (NUMBER_OF_LANES-1) generate        
        i_ibuf_a: IBUFDS        
        port map (
            I => din_a_p(i),
            IB => din_a_n(i),
            O => din_a_ibuf_s(i)
        );
        i_ibuf_b: IBUFDS        
        port map (
            I => din_b_p(i),
            IB => din_b_n(i),
            O => din_b_ibuf_s(i)
        );            
      end generate g_io;

    frame_clock_ibuf_a: IBUFDS        
        port map (
            I => frame_clock_p,
            IB => frame_clock_n,
            O => frame_clock_ibuf_s
        );
                        
    g_data: for i in 0 to (NUMBER_OF_LANES-1) generate
        i_idelay_a : IDELAYE2 
        generic map (
            CINVCTRL_SEL => "FALSE",
            DELAY_SRC => "IDATAIN",
            HIGH_PERFORMANCE_MODE => "FALSE",
            IDELAY_TYPE => "FIXED",
            IDELAY_VALUE => 0,
            REFCLK_FREQUENCY => 200.0,
            PIPE_SEL => "FALSE",
            SIGNAL_PATTERN => "DATA")
        port map (
            CE => '0',
            INC => '0',
            DATAIN => '0',
            LDPIPEEN => '0',
            CINVCTRL => '0',
            REGRST => '0',
            C => '0',
            IDATAIN => din_a_ibuf_s(i),
            DATAOUT => din_a_idelay_s(i),
            LD => '0',
            CNTVALUEIN => "00000"       
        );
        i_idelay_b : IDELAYE2 
        generic map (
            CINVCTRL_SEL => "FALSE",
            DELAY_SRC => "IDATAIN",
            HIGH_PERFORMANCE_MODE => "FALSE",
            IDELAY_TYPE => "FIXED",
            IDELAY_VALUE => 0,
            REFCLK_FREQUENCY => 200.0,
            PIPE_SEL => "FALSE",
            SIGNAL_PATTERN => "DATA")
        port map (
            CE => '0',
            INC => '0',
            DATAIN => '0',
            LDPIPEEN => '0',
            CINVCTRL => '0',
            REGRST => '0',
            C => '0',
            IDATAIN => din_b_ibuf_s(i),
            DATAOUT => din_b_idelay_s(i),
            LD => '0',
            CNTVALUEIN => "00000"        
        );
        i_iserdes_a1: ISERDESE2
        generic map (
            DATA_RATE => "DDR",
            DATA_WIDTH => 14,
            DYN_CLKDIV_INV_EN => "FALSE",
            DYN_CLK_INV_EN => "FALSE",
            INTERFACE_TYPE => "NETWORKING",
            IOBDELAY => "NONE",
            NUM_CE => 2,
            OFB_USED => "FALSE",
            SERDES_MODE => "MASTER"
        )
        port map (
            Q1 => data_second(0),
            Q2 => data_second(1),
            Q3 => data_second(2),
            Q4 => data_second(3),
            Q5 => data_second(4),
            Q6 => data_second(5),
            Q7 => data_second(6),
            Q8 => data_first(0),
            SHIFTOUT1 => data_a_shift1_s(i),
            SHIFTOUT2 => data_a_shift2_s(i),
            BITSLIP => bit_slip_i,
            CE1 => '1',
            CE2 => '1',        
            CLK => bit_clock,
            CLKB => bit_clock_inv,
            CLKDIV => half_clk,                        
            CLKDIVP => '0',
            DDLY => din_a_idelay_s(i),        
            D => '0',
            RST => serdes_rst,
            SHIFTIN1 => '0',
            SHIFTIN2 => '0',            
            DYNCLKDIVSEL => '0',
            DYNCLKSEL => '0',
            OFB => '0',
            OCLK => '0',
            OCLKB => '0'      
        );
        i_iserdes_a2: ISERDESE2
        generic map (
            DATA_RATE => "DDR",
            DATA_WIDTH => 14,
            DYN_CLKDIV_INV_EN => "FALSE",
            DYN_CLK_INV_EN => "FALSE",
            INTERFACE_TYPE => "NETWORKING",
            IOBDELAY => "NONE",
            NUM_CE => 2,
            OFB_USED => "FALSE",
            SERDES_MODE => "SLAVE"
        )
        port map (
            Q3 => data_first(1),
            Q4 => data_first(2),
            Q5 => data_first(3),
            Q6 => data_first(4),
            Q7 => data_first(5),
            Q8 => data_first(6),
            BITSLIP => bit_slip_i,
            CE1 => '1',
            CE2 => '1',        
            CLK => bit_clock,
            CLKB => bit_clock_inv,
            CLKDIV => half_clk,                        
            CLKDIVP => '0',
            DDLY => '0',        
            D => '0',
            RST => serdes_rst,
            SHIFTIN1 => data_a_shift1_s(i),
            SHIFTIN2 => data_a_shift2_s(i),            
            DYNCLKDIVSEL => '0',
            DYNCLKSEL => '0',
            OFB => '0',
            OCLK => '0',
            OCLKB => '0'      
        );
        i_iserdes_b1: ISERDESE2
        generic map (
            DATA_RATE => "DDR",
            DATA_WIDTH => 14,
            DYN_CLKDIV_INV_EN => "FALSE",
            DYN_CLK_INV_EN => "FALSE",
            INTERFACE_TYPE => "NETWORKING",
            IOBDELAY => "NONE",
            NUM_CE => 2,
            OFB_USED => "FALSE",
            SERDES_MODE => "MASTER"
        )
        port map (
            Q1 => data_second(7),
            Q2 => data_second(8),
            Q3 => data_second(9),
            Q4 => data_second(10),
            Q5 => data_second(11),
            Q6 => data_second(12),
            Q7 => data_second(13),
            Q8 => data_first(7),
            SHIFTOUT1 => data_b_shift1_s(i),
            SHIFTOUT2 => data_b_shift2_s(i),
            BITSLIP => bit_slip_i,
            CE1 => '1',
            CE2 => '1',        
            CLK => bit_clock,
            CLKB => bit_clock_inv,
            CLKDIV => half_clk,                        
            CLKDIVP => '0',
            DDLY => din_b_idelay_s(i),        
            D => '0',
            RST => serdes_rst,
            SHIFTIN1 => '0',
            SHIFTIN2 => '0',            
            DYNCLKDIVSEL => '0',
            DYNCLKSEL => '0',
            OFB => '0',
            OCLK => '0',
            OCLKB => '0'      
        );
        i_iserdes_b2: ISERDESE2
        generic map (
            DATA_RATE => "DDR",
            DATA_WIDTH => 14,
            DYN_CLKDIV_INV_EN => "FALSE",
            DYN_CLK_INV_EN => "FALSE",
            INTERFACE_TYPE => "NETWORKING",
            IOBDELAY => "NONE",
            NUM_CE => 2,
            OFB_USED => "FALSE",
            SERDES_MODE => "SLAVE"
        )
        port map (
            Q3 => data_first(8),
            Q4 => data_first(9),
            Q5 => data_first(10),
            Q6 => data_first(11),
            Q7 => data_first(12),
            Q8 => data_first(13),
            BITSLIP => bit_slip_i,
            CE1 => '1',
            CE2 => '1',        
            CLK => bit_clock,
            CLKB => bit_clock_inv,
            CLKDIV => half_clk,                        
            CLKDIVP => '0',
            DDLY => '0',        
            D => '0',
            RST => serdes_rst,
            SHIFTIN1 => data_b_shift1_s(i),
            SHIFTIN2 => data_b_shift2_s(i),            
            DYNCLKDIVSEL => '0',
            DYNCLKSEL => '0',
            OFB => '0',
            OCLK => '0',
            OCLKB => '0'      
        );
      end generate g_data;


      process(sample_clk,frame_clock_ibuf_s,data_first,data_second)
      begin
      if falling_edge(sample_clk) then
        if (half_clk='1') then
            data_int <= data_first;
        else
            data_int <= data_second;
        end if;
      end if;
      end process;

    data_out <= data_int;


end Behavioral;					
