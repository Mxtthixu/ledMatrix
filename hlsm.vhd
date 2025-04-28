LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY hlsm IS
    PORT (
        a_rst     : IN  STD_LOGIC;
        clock_4   : IN  STD_LOGIC;
        mx_LE     : OUT STD_LOGIC;
        mx_OE     : OUT STD_LOGIC;
        mx_clock  : OUT STD_LOGIC;
        mx_CBA    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        rom_add_t : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
        rom_add_b : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
    );
END hlsm;

ARCHITECTURE arch OF hlsm IS

    TYPE statetype IS (ATT, CH, FL);
    SIGNAL state, next_state     : statetype;
    SIGNAL lines, lines_next     : UNSIGNED(2 DOWNTO 0);
    SIGNAL pixel, pixel_next     : UNSIGNED(4 DOWNTO 0);
    SIGNAL ROMadd, ROMadd_next   : UNSIGNED(7 DOWNTO 0);
    SIGNAL cnt, cnt_next         : INTEGER RANGE 0 TO 13;

BEGIN

-------------------------------------------------------------------------
-- REGISTERS
-------------------------------------------------------------------------
    registers_process : PROCESS(a_rst, clock_4)
    BEGIN
        IF a_rst = '1' THEN
            state   <= ATT;
            lines   <= (others => '0');
            pixel   <= (others => '0');
            ROMadd  <= (others => '0');
            cnt     <= 0;
        ELSIF rising_edge(clock_4) THEN
            state   <= next_state;
            lines   <= lines_next;
            pixel   <= pixel_next;
            ROMadd  <= ROMadd_next;
            cnt     <= cnt_next;
        END IF;
    END PROCESS;

-------------------------------------------------------------------------
-- NEXT STATE LOGIC
-------------------------------------------------------------------------
    next_state_process : PROCESS(state, pixel, cnt, a_rst)
    BEGIN
        IF (pixel = 31) AND (cnt = 3) AND (state = CH) THEN
            next_state <= FL;
        ELSIF (cnt >= 13) AND (state = FL) THEN
            next_state <= CH;
        ELSIF (a_rst = '1') THEN
            next_state <= ATT;
        ELSIF (a_rst = '0') AND (state = ATT) THEN
            next_state <= CH;
        ELSIF (state = CH) AND (pixel /= 31) AND (cnt /= 3) THEN
            next_state <= CH;
        ELSIF (cnt < 13) AND (state = FL) THEN
            next_state <= FL;
		  ELSE next_state <= state;
        END IF;
    END PROCESS;

-------------------------------------------------------------------------
-- CNT LOGIC
-------------------------------------------------------------------------
    cnt_next_process : PROCESS(cnt, state)
    BEGIN
        IF ((cnt = 3 AND state = CH) OR (cnt = 13 AND state = FL) OR (state = ATT)) THEN
            cnt_next <= 0;
        ELSE
            cnt_next <= cnt + 1;
        END IF;
    END PROCESS;

-------------------------------------------------------------------------
-- LINES LOGIC
-------------------------------------------------------------------------
    lines_next_process : PROCESS(state, cnt, lines)
    BEGIN
        IF state = ATT THEN
            lines_next <= (others => '0');
		  ELSIF state = CH THEN
				lines_next <= lines;
        ELSIF (state = FL) AND (cnt = 3) THEN
				IF (lines < 7) THEN
					lines_next <= lines + 1;
				ELSE
					lines_next <= (others => '0');
				END IF;
        ELSE
            lines_next <= lines;
        END IF;
    END PROCESS;

-------------------------------------------------------------------------
-- PIXEL LOGIC
-------------------------------------------------------------------------
    pixel_next_process : PROCESS(state, pixel, cnt)
    BEGIN
        IF (state = ATT) OR ((cnt = 2) AND (state = FL)) THEN
            pixel_next <= (others => '0');
        ELSIF (state = CH) AND (pixel < 31) AND (cnt = 3) THEN
            pixel_next <= pixel + 1;
        ELSE
            pixel_next <= pixel;
        END IF;
    END PROCESS;

-------------------------------------------------------------------------
-- ROM ADDRESS LOGIC
-------------------------------------------------------------------------
    ROMadd_next_process : PROCESS(state, cnt, pixel, ROMadd)
    BEGIN
        IF (state = ATT) OR ((state = FL) AND (ROMadd = 255) AND (cnt = 3)) THEN
            ROMadd_next <= (others => '0');
        ELSIF ((state = CH) AND (pixel < 31) AND (cnt = 3)) OR
              ((state = FL) AND (ROMadd < 255) AND (cnt = 3)) THEN
            ROMadd_next <= ROMadd + 1;
        ELSE
            ROMadd_next <= ROMadd;
        END IF;
    END PROCESS;

-------------------------------------------------------------------------
-- OUTPUTS
-------------------------------------------------------------------------
    mx_clock_process : PROCESS(state, cnt)
    BEGIN
        IF (state = ATT) OR (state = FL) THEN
            mx_clock <= '1';
        ELSIF (state = CH) AND (cnt < 2) THEN
            mx_clock <= '1';
        ELSE
            mx_clock <= '0';
        END IF;
    END PROCESS;

    mx_LE_process : PROCESS(state, cnt)
    BEGIN
        IF ((state = ATT) OR (state = CH)) THEN
            mx_LE <= '0';
        ELSIF ((state = FL) AND (cnt > 3) AND (cnt < 8)) THEN
            mx_LE <= '1';
        ELSE
            mx_LE <= '0';
        END IF;
    END PROCESS;

    mx_OE_process : PROCESS(state, cnt)
    BEGIN
        IF ((state = ATT) OR (state = FL)) THEN
            mx_OE <= '1';
        ELSE
            mx_OE <= '0';
        END IF;
    END PROCESS;

-------------------------------------------------------------------------
-- CBA + ROM ADDRESSES
-------------------------------------------------------------------------
    mx_CBA <= STD_LOGIC_VECTOR(lines);

    rom_add_t <= '0' & STD_LOGIC_VECTOR(ROMadd);
    rom_add_b <= '1' & STD_LOGIC_VECTOR(ROMadd);

END arch;

