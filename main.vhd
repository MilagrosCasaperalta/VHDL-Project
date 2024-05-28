library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type S is (S_rst, S_attesa, S_lettura, S_mem, S_out,S_dummy);
    signal curr_state : S;
    signal mem_addr : std_logic_vector(15 downto 0) := "0000000000000000";
    signal mux_sel : std_logic_vector(1 downto 0):= "00";
    signal reg_z0 : std_logic_vector(7 downto 0) := "00000000";
    signal reg_z1 : std_logic_vector(7 downto 0) := "00000000";
    signal reg_z2 : std_logic_vector(7 downto 0) := "00000000";
    signal reg_z3 : std_logic_vector(7 downto 0) := "00000000";
    signal counter : INTEGER := 0;

begin
    state_function : process(i_clk, i_rst, i_start)
   
    begin
    -- caso per resettare tutti i segnali
        if (i_rst = '1') then
            curr_state <= S_rst;
    -- start = 1, andiamo in lettura dell'indirizzo
        elsif(i_rst = '0' and i_clk'event and i_clk='1') then
            if(i_start = '1') then
                curr_state <= S_lettura;
    -- nel momento in cui scatta start = 0, allora fermiamo la lettura e chiediamo in memoria
            elsif (i_start = '0') then
                case curr_state is
                    when S_lettura =>
                        curr_state <= S_mem;
                    when S_mem =>        -- stato messo per aspettare la lettura da memoria
                        curr_state <= s_dummy;
                    when s_dummy =>
                        curr_state <= s_out;  
                    when s_out =>
                        curr_state <= s_attesa;
                    when others =>
                end case;
            end if;
        end if;  
    end process;
   
    fsm_process : process(curr_state, reg_z0, reg_z1, reg_z2, reg_z3, counter, mem_addr)
   
    begin
       
        case curr_state is
        when s_rst =>
            o_mem_we <= '0';
            o_mem_en <= '0';
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            reg_z0 <= "00000000";
            reg_z1 <= "00000000";
            reg_z2 <= "00000000";
            reg_z3 <= "00000000";
            o_done <= '0';
        when s_attesa =>
            o_done <= '0';
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            o_mem_addr <= "0000000000000000";
            o_mem_we <= '0';
            o_mem_en <= '0';
        when s_lettura =>
        when s_mem =>
            o_mem_we <= '0';
            o_mem_en <= '1';
            o_mem_addr <= mem_addr;
        when s_dummy =>
        when s_out =>
            case mux_sel is
                when "00" =>
                    reg_z0 <= i_mem_data;
                when "01" =>
                    reg_z1 <= i_mem_data;
                when "10" =>
                    reg_z2 <= i_mem_data;
                when "11" =>
                    reg_z3 <= i_mem_data;
                when others =>
                                                       
            end case;
            o_done <= '1';
            o_z0 <= reg_z0;
            o_z1 <= reg_z1;
            o_z2 <= reg_z2;
            o_z3 <= reg_z3;
         when others =>
            o_done <= '0';
            o_z0 <= "00000000";
            o_z1 <= "00000000";
            o_z2 <= "00000000";
            o_z3 <= "00000000";
            o_mem_addr <= "0000000000000000";
            o_mem_we <= '0';
            o_mem_en <= '0';
         end case;
   
    end process;
   
   
    read_process : process(i_w, curr_state, i_clk, mux_sel, mem_addr, i_start)
   -- variable counter : integer range 0 to 2 := 0;

    begin
 
    if(curr_state = s_rst) then
        mem_addr <= "0000000000000000";
        mux_sel <= "00";
    end if;
   
    if(i_clk'event and i_clk='1' and i_start = '1') then
   
        if(counter = 2) then
                mem_addr(15 downto 1) <= mem_addr(14 downto 0);
                mem_addr(0) <= i_w;
            else
                mux_sel(1) <= mux_sel(0);
                mux_sel(0) <= i_w;
                counter <= counter + 1;
        end if;
   
    end if;
   
    if(i_clk'event and i_clk='1' and curr_state = s_mem) then
        counter <= 0;
   
    end if;
    if(i_clk'event and i_clk='1' and curr_state = s_mem) then
        mem_addr <= "0000000000000000";
    end if;
   
    end process;
   
end architecture;
