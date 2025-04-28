LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ledMatrix IS
    PORT (
        clk_50    : IN  STD_LOGIC; -- horloge principale FPGA
        rst_btn : IN  STD_LOGIC;

        R1, G1, B1       : OUT STD_LOGIC;
        R2, G2, B2       : OUT STD_LOGIC;
        CLK, LAT, OE     : OUT STD_LOGIC;
		  mx_cba           : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ledMatrix;

ARCHITECTURE rtl OF ledMatrix IS

	COMPONENT hlsm PORT (
		a_rst : IN STD_LOGIC;
		clock_4 : IN STD_LOGIC;
		mx_LE : OUT STD_LOGIC;
		mx_OE : OUT STD_LOGIC;
		mx_clock : OUT STD_LOGIC;
		mx_CBA : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		rom_add_t : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		rom_add_b : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
	END COMPONENT;

	COMPONENT redROM PORT (
		address_a		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock : IN STD_LOGIC;
		q_a : OUT STD_LOGIC;
		q_b : OUT STD_LOGIC
	); END COMPONENT;
	
	COMPONENT greenROM PORT (
		address_a		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock : IN STD_LOGIC;
		q_a : OUT STD_LOGIC;
		q_b : OUT STD_LOGIC
	); END COMPONENT;

	COMPONENT blueROM PORT (
		address_a		: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		clock : IN STD_LOGIC;
		q_a : OUT STD_LOGIC;
		q_b : OUT STD_LOGIC
	); END COMPONENT;


	COMPONENT pll PORT (
		inclk0 : IN STD_LOGIC;
		areset : IN STD_LOGIC;
		c0     : OUT STD_LOGIC;
		locked : OUT STD_LOGIC
	); 
	END COMPONENT;


	SIGNAL clock_4    : STD_LOGIC;
	SIGNAL rom_add_t  : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL rom_add_b  : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL locked     : STD_LOGIC;

BEGIN

    inst_pll : pll
        PORT MAP (
            inclk0 => clk_50,  -- IN
				areset => rst_btn,  -- IN
            c0     => clock_4,  --OUT
				locked => locked  --OUT
        );

    inst_hlsm : hlsm
        PORT MAP (
            a_rst     => rst_btn and (not locked),  -- IN
            clock_4   => clock_4,  --IN
            mx_LE     => LAT,  --OUT
            mx_OE     => OE,  --OUT
            mx_clock  => CLK,  --OUT
            mx_CBA    => mx_cba,  --OUT
            rom_add_t => rom_add_t,  --OUT
            rom_add_b => rom_add_b  --OUT
        );
		  
	 inst_redrom : redROM
        PORT MAP (
            address_a => rom_add_t,  -- IN
            address_b => rom_add_b,  -- IN
            clock     => clock_4,  -- IN
				q_a       => R1,  --OUT
				q_b       => R2  --OUT
        );
		  
    inst_greenrom : greenROM
        PORT MAP (
            address_a => rom_add_t,  -- IN
            address_b => rom_add_b,  -- IN
            clock     => clock_4,  -- IN
				q_a       => G1,  --OUT
				q_b       => G2  --OUT
        );

	 inst_bluerom : blueROM
        PORT MAP (
            address_a => rom_add_t,  -- IN
            address_b => rom_add_b,  -- IN
            clock     => clock_4,  -- IN
				q_a       => B1,  --OUT
				q_b       => B2  --OUT
        );


END rtl;
