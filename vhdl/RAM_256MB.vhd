LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.Numeric_Std.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY RAM_256MB IS
	PORT
	(
	
      ddr3_dq       : inout std_logic_vector(15 downto 0);
      ddr3_dqs_p    : inout std_logic_vector(1 downto 0);
      ddr3_dqs_n    : inout std_logic_vector(1 downto 0);   
           
      ddr3_addr     : out   std_logic_vector(13 downto 0);
      ddr3_ba       : out   std_logic_vector(2 downto 0);
      ddr3_ras_n    : out   std_logic;
      ddr3_cas_n    : out   std_logic;
      ddr3_we_n     : out   std_logic;
      ddr3_reset_n  : out   std_logic;
      ddr3_ck_p     : out   std_logic_vector(0 downto 0);
      ddr3_ck_n     : out   std_logic_vector(0 downto 0);
      ddr3_cke      : out   std_logic_vector(0 downto 0);
      ddr3_dm       : out   std_logic_vector(1 downto 0);
      ddr3_odt      : out   std_logic_vector(0 downto 0);
      
	
		address		: IN STD_LOGIC_VECTOR (27 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		clk177		: IN STD_LOGIC  := '1';
		clk200		: IN STD_LOGIC  := '1';
		dataIn		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		read_n      : in std_logic;
		write_n		: IN STD_LOGIC ;
		dataOut		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ready       : out std_logic
		
		
	);
END RAM_256MB;


ARCHITECTURE SYN OF RAM_256MB IS

    attribute DONT_TOUCH : string;
   
    type tipo_estado is (init, boot, idle1, idle2, write1, write2, write3, write4, write5, write6, read1, read2, read3, read4, read5, read6);
    signal estado: tipo_estado := init;
    signal siguienteEstado: tipo_estado;
    signal clk50: std_logic;
    signal contador : std_logic_vector(31 downto 0);
    signal contador2 : std_logic_vector(8 downto 0);
    signal contador3 : std_logic_vector(8 downto 0);
    signal contadorMissing : std_logic_vector (3 downto 0);
    signal error    : std_logic:='0';
    --attribute dont_touch of error : signal is "TRUE";

    signal init_calib_complete : std_logic;
    signal app_addr                  :     std_logic_vector(27 downto 0);
    attribute dont_touch of app_addr : signal is "TRUE";
    signal app_cmd                   :     std_logic_vector(2 downto 0);
    --attribute dont_touch of app_cmd : signal is "TRUE";
    signal app_en                    :     std_logic;
    --attribute dont_touch of app_en : signal is "TRUE";
    signal app_wdf_data              :     std_logic_vector(127 downto 0);
    attribute dont_touch of app_wdf_data : signal is "TRUE";
    signal app_wdf_end               :     std_logic;
    --attribute dont_touch of app_wdf_end : signal is "TRUE";
    signal app_wdf_mask         :     std_logic_vector(15 downto 0);
    --attribute dont_touch of app_wdf_mask : signal is "TRUE";
    signal app_wdf_wren              :     std_logic;
    --attribute dont_touch of app_wdf_wren : signal is "TRUE";
    signal app_rd_data               :    std_logic_vector(127 downto 0);
    attribute dont_touch of app_rd_data : signal is "TRUE";
    signal app_rd_data_end           :    std_logic;
    --attribute dont_touch of app_rd_data_end : signal is "TRUE";
    signal app_rd_data_valid         :    std_logic;
    --attribute dont_touch of app_rd_data_valid : signal is "TRUE";
    signal app_rdy                   :    std_logic;
    --attribute dont_touch of app_rdy : signal is "TRUE";
    signal app_wdf_rdy               :    std_logic;
    --attribute dont_touch of app_wdf_rdy : signal is "TRUE";
    signal app_ref_req              :     std_logic;
    signal app_sr_active             :    std_logic;
    --attribute dont_touch of app_sr_active : signal is "TRUE";
    signal app_ref_ack               :    std_logic;
    --attribute dont_touch of app_ref_ack : signal is "TRUE";
    signal app_zq_ack                :    std_logic;
    --attribute dont_touch of app_zq_ack : signal is "TRUE";
    signal ui_clk                    :    std_logic;
    --attribute dont_touch of ui_clk : signal is "TRUE";
    signal ui_clk_sync_rst           :    std_logic;
    --attribute dont_touch of ui_clk_sync_rst : signal is "TRUE";

    -- System Clock Ports
    signal device_temp                      :  std_logic_vector(11 downto 0);
    --attribute dont_touch of device_temp : signal is "TRUE";
    --signal clk177                     :   std_logic;
    --signal clk200                     :   std_logic;
    --attribute dont_touch of clk200 : signal is "TRUE";   
    signal nibble                       : std_logic_vector (3 downto 0);
    signal ex_estado                    : std_logic_vector (3 downto 0);
    attribute dont_touch of ex_estado : signal is "TRUE";
    signal data2                        :std_logic_vector(15 downto 0):=(others => '1');
    signal addressLatch                 :std_logic_vector (3 downto 0):=(others => '1');
    signal read_n_latch                 : std_logic := '1';
    signal write_n_latch                 : std_logic := '1';
    signal nose                         :std_logic;
    attribute dont_touch of nose : signal is "TRUE";
    
	component mig_7series_0
  port (

      ddr3_dq       : inout std_logic_vector(15 downto 0);
      ddr3_dqs_p    : inout std_logic_vector(1 downto 0);
      ddr3_dqs_n    : inout std_logic_vector(1 downto 0);
      ddr3_addr     : out   std_logic_vector(13 downto 0);
      ddr3_ba       : out   std_logic_vector(2 downto 0);
      ddr3_ras_n    : out   std_logic;
      ddr3_cas_n    : out   std_logic;
      ddr3_we_n     : out   std_logic;
      ddr3_reset_n  : out   std_logic;
      ddr3_ck_p     : out   std_logic_vector(0 downto 0);
      ddr3_ck_n     : out   std_logic_vector(0 downto 0);
      ddr3_cke      : out   std_logic_vector(0 downto 0);
      ddr3_dm       : out   std_logic_vector(1 downto 0);
      ddr3_odt      : out   std_logic_vector(0 downto 0);
      app_addr                  : in    std_logic_vector(27 downto 0);
      app_cmd                   : in    std_logic_vector(2 downto 0);
      app_en                    : in    std_logic;
      app_wdf_data              : in    std_logic_vector(127 downto 0);
      app_wdf_end               : in    std_logic;
      app_wdf_mask         : in    std_logic_vector(15 downto 0);
      app_wdf_wren              : in    std_logic;
      app_rd_data               : out   std_logic_vector(127 downto 0);
      app_rd_data_end           : out   std_logic;
      app_rd_data_valid         : out   std_logic;
      app_rdy                   : out   std_logic;
      app_wdf_rdy               : out   std_logic;
      app_sr_req                : in    std_logic;
      app_ref_req               : in    std_logic;
      app_zq_req                : in    std_logic;
      app_sr_active             : out   std_logic;
      app_ref_ack               : out   std_logic;
      app_zq_ack                : out   std_logic;
      ui_clk                    : out   std_logic;
      ui_clk_sync_rst           : out   std_logic;
      init_calib_complete       : out   std_logic;
      -- System Clock Ports
      sys_clk_i                      : in    std_logic;
      clk_ref_i                                : in    std_logic;
      device_temp                      : out std_logic_vector(11 downto 0);
      sys_rst                     : in    std_logic

  );
    end component;    


    function getMask (
        nibble    : in std_logic_vector(3 downto 0))
        return std_logic_vector is
    
        variable result : std_logic_vector(15 downto 0);
    
    begin
        result := x"ffff";
        case nibble is
            when "0000" =>
                result(0) := '0';
            when "0001" =>
                result(1) := '0';
            when "0010" =>
                result(2) := '0';
            when "0011" =>
                result(3) := '0';
            when "0100" =>
                result(4) := '0';
            when "0101" =>
                result(5) := '0';
            when "0110" =>
                result(6) := '0';
            when "0111" =>
                result(7) := '0';
            when "1000" =>
                result(8) := '0';
            when "1001" =>
                result(9) := '0';
            when "1010" =>
                result(10) := '0';
            when "1011" =>
                result(11) := '0';
            when "1100" =>
                result(12) := '0';
            when "1101" =>
                result(13) := '0';
            when "1110" =>
                result(14) := '0';
            when "1111" =>
                result(15) := '0';
            when others =>
                null;
        end case;   
        
        return result;
         
    end function getMask;  
      
    function getByte (
        nibble    : in std_logic_vector(3 downto 0);
        data7    : in std_logic_vector(127 downto 0))
        return std_logic_vector is
    
    begin
        case nibble is
            when "0000" =>
                return data7(7 downto 0);
            when "0001" =>
                return data7(15 downto 8);
            when "0010" =>
                return data7(23 downto 16);
            when "0011" =>
                return data7(31 downto 24);
            when "0100" =>
                return data7(39 downto 32);
            when "0101" =>
                return data7(47 downto 40);
            when "0110" =>
                return data7(55 downto 48);
            when "0111" =>
                return data7(63 downto 56);
            when "1000" =>
                return data7(71 downto 64);
            when "1001" =>
                return data7(79 downto 72);
            when "1010" =>
                return data7(87 downto 80);
            when "1011" =>
                return data7(95 downto 88);
            when "1100" =>
                return data7(103 downto 96);
            when "1101" =>
                return data7(111 downto 104);
            when "1110" =>
                return data7(119 downto 112);
            when "1111" =>
                return data7(127 downto 120);
            when others =>
                return "XXXXXXXX";
        end case;   
         
    end function getByte; 
    
    
    function getAddress (
        addressRaw    : in std_logic_vector(27 downto 0))
        return std_logic_vector is
    
        variable result : std_logic_vector(27 downto 0):=(others => '0');
    
      begin
        result(26 downto 3) := addressRaw(27 downto 4);
        return result;
         
    end function getAddress;  


BEGIN

    --ex_init_calib_complete <= init_calib_complete;
    data2(15 downto 8) <= not dataIn;
    data2(7 downto 0) <= not dataIn;
    nibble <= address(3 downto 0);
    
  ddr3 : mig_7series_0

    port map (
       -- Memory interface ports
       ddr3_addr                      => ddr3_addr,
       ddr3_ba                        => ddr3_ba,
       ddr3_cas_n                     => ddr3_cas_n,
       ddr3_ck_n                      => ddr3_ck_n,
       ddr3_ck_p                      => ddr3_ck_p,
       ddr3_cke                       => ddr3_cke,
       ddr3_ras_n                     => ddr3_ras_n,
       ddr3_reset_n                   => ddr3_reset_n,
       ddr3_we_n                      => ddr3_we_n,
       ddr3_dq                        => ddr3_dq,
       ddr3_dqs_n                     => ddr3_dqs_n,
       ddr3_dqs_p                     => ddr3_dqs_p,
       init_calib_complete            => init_calib_complete,
       ddr3_dm                        => ddr3_dm,
       ddr3_odt                       => ddr3_odt,
       -- Application interface ports
       app_addr                       => app_addr,
       app_cmd                        => app_cmd,
       app_en                         => app_en,
       app_wdf_data                   => app_wdf_data,
       app_wdf_end                    => app_wdf_end,
       app_wdf_wren                   => app_wdf_wren,
       app_rd_data                    => app_rd_data,
       app_rd_data_end                => app_rd_data_end,
       app_rd_data_valid              => app_rd_data_valid,
       app_rdy                        => app_rdy,
       app_wdf_rdy                    => app_wdf_rdy,
       app_sr_req                     => '0',
       app_ref_req                    => '0',
       app_zq_req                     => '0',
       app_sr_active                  => app_sr_active,
       app_ref_ack                    => app_ref_ack,
       app_zq_ack                     => app_zq_ack,
       ui_clk                         => ui_clk,
       ui_clk_sync_rst                => ui_clk_sync_rst,
       app_wdf_mask                   => app_wdf_mask,
       -- System Clock Ports
       sys_clk_i                       => clk177,
       clk_ref_i                       => clk200,
	  device_temp                      => device_temp,
      sys_rst                        => '1'

    );
    

    
--    depuracion: process(clk177, estado) is
--    begin
--        app_rdy <= '1';
--        --app_rd_data <= x"ffeeddccbbaa99887766554433221100";
--        app_rd_data <= x"0f0e0d0c0b0a09080706050403020100";
--        if rising_edge(clk177) then
--            case estado is
--                when read6 =>
--                    contador3 <= contador3 + 1;
--                    if contador3 > 50 then
--                        app_rd_data_valid <= '1';
--                    end if;
--                when others =>
--                    app_rd_data_valid <= '0';
--                    contador3 <= (others => '0');
--            end case;            
--        end if;
    
--    end process depuracion;
    
    

    ramProcess: process(clk177, dataIn, data2, address) is
    begin

        
        if rising_edge(clk177) then
            read_n_latch <= read_n;
            write_n_latch <= write_n;
            case estado is
                when init =>
                    app_cmd <= "001";
                    app_en <= '0';
                    
                    app_wdf_end <='0';
                    app_wdf_wren <='0';
                    
                    ready <= '0';
                    
                    contador <= (others=>'0');
                    contador2 <= (others=>'0');
                
                    estado <= boot;
                    ex_estado <= "0001";

                when boot =>
                    if app_rdy = '1' then
                        ready <= '1';
                        estado <= idle1;
                        ex_estado <= "0010";
                    end if;
                    
                when idle1 =>
                    if read_n_latch = '1' and write_n_latch = '1' then
                        estado <= idle2;
                        ex_estado <= "0011";                    
                    end if;
                
                when idle2 =>
                    addressLatch <= address(3 downto 0);
                    app_addr <= getAddress(address);
                    app_wdf_data(127 downto 112) <= not data2;
                    app_wdf_data(111 downto 96) <= not data2;
                    app_wdf_data(95 downto 80) <= not data2;
                    app_wdf_data(79 downto 64) <= not data2;
                    app_wdf_data(63 downto 48) <= not data2;
                    app_wdf_data(47 downto 32) <= not data2;
                    app_wdf_data(31 downto 16) <= not data2;
                    app_wdf_data(15 downto 0) <= not data2;
                    app_wdf_mask <= getMask(address(3 downto 0));
                    if read_n_latch = '0' then
                        estado <= read1;
                        ex_estado <= "1000";
                    elsif write_n_latch = '0' then
                        estado <= write1;
                        ex_estado <= "0100";
                    end if;                    
                    
                when write1 => --espera a que el controlador esté disponible 
                    if app_rdy = '1' then
                        estado <= write2;
                        ex_estado <= "0101";
                    end if;
                when write2 => --espera a que el controlador esté disponible 
                    if app_rdy = '1' then
                        estado <= write3;
                        ex_estado <= "0101";
                    end if;
                    
                when write3 => --escribe. mantiene el comando hasta que app_rdy esté a 1 
                    app_en <= '1'; --enable request
                    app_cmd <= "000"; --write
                    app_wdf_wren <= '1';
                    app_wdf_end <= '1';
                    contadorMissing <= (others => '0');
                    estado <= write4;
                    ex_estado <= "0110";
                when write4 => --escribe. mantiene el comando hasta que app_rdy esté a 1
                    if app_rdy = '0' then
                        contadorMissing <= contadorMissing +1;
                    end if;
                    estado <= write5;
                    ex_estado <= "0111";
                when write5 => --escribe. mantiene el comando hasta que app_rdy esté a 1
                    if app_rdy = '0' then
                        contadorMissing <= contadorMissing +1;
                    end if;
                    app_wdf_wren <= '0';
                    app_wdf_end <= '0';
                    
                    if contadorMissing /= "0000" or app_rdy = '0' then
                        estado <= write6;
                        ex_estado <= "1111";                    
                    else
                        app_en <= '0'; --end of request
                        estado <= idle1;
                        ex_estado <= "0010";
                    end if;
                                            
                when write6 => 
                    if app_rdy = '1' then
                        contadorMissing <= contadorMissing - 1;
                        if contadorMissing = "0001" then
                            app_en <= '0'; --end of request
                            estado <= idle1;
                            ex_estado <= "0010";
                        end if;
                    end if;
        
                when read1 => --lee. mantiene el comando hasta que app_rdy esté a 1 
                    if app_rdy = '1' then
                        app_en <= '1'; --enable request
                        app_cmd <= "001";
                        estado <= read2;
                        ex_estado <= "1001";
                    end if;     
                                 
                when read2 => --lee. mantiene el comando hasta que app_rdy esté a 1
                    if app_rdy = '1' then
                        --app_en <= '0'; --end of request
                        estado <= read3;
                        ex_estado <= "1010";
                    end if;
                    
                when read3 => --lee. mantiene el comando hasta que app_rdy esté a 1
                    if app_rdy = '1' then
                        app_en <= '0'; --end of request
                        estado <= read6;
                        ex_estado <= "1011";
                    end if;
                    
                when read6 => --espera a que termine la lectura
                    if app_rd_data_valid = '1' then
                        dataOut <= getByte(addressLatch, app_rd_data);
                        contador <= contador + 1;
                        estado <= idle1;
                        ex_estado <= "0010";
                    end if;
                

                when others =>
                    null;
            end case;
        
        end if;
    end process ramProcess;





END SYN;


