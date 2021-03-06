library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pal_video is
	Port (
		clk8:				in  std_logic;
		x: 				out unsigned(8 downto 0);
		y:					out unsigned(7 downto 0);
		color:			in  std_logic_vector(5 downto 0);
		hsync:			out std_logic;
		vsync:			out std_logic;
		red:				out std_logic_vector(1 downto 0);
		green:			out std_logic_vector(1 downto 0);
		blue:				out std_logic_vector(1 downto 0));
end pal_video;

architecture Behavioral of pal_video is

	signal hcount:			unsigned(8 downto 0) := (others => '0');
	signal vcount:			unsigned(8 downto 0) := (others => '0');
	signal y9:				unsigned(8 downto 0);
	
	signal in_vbl:			std_logic;
	signal screen_sync:	std_logic;
	signal vbl_hsync:		std_logic;
	signal vbl_vsync:		std_logic;
	
	signal visible:		boolean;

begin

	process (clk8)
	begin
		if rising_edge(clk8) then
			if hcount=511 then
				hcount <= (others => '0');
				if vcount=311 then
					vcount <= (others=>'0');
				else
					vcount <= vcount + 1;
				end if;
			else
				hcount <= hcount + 1;
			end if;
		end if;
	end process;
	
	process (hcount)
	begin
		if hcount<37 then
			screen_sync <= '0';
		else
			screen_sync <= '1';
		end if;
	end process;
	
	in_vbl <= '1' when vcount<5 else '0';
	
	x					<= hcount-164;
	y9					<= vcount-64;
	y					<= y9(7 downto 0);
	--vblank			<= '1' when hcount=0 and vcount=0 else '0';
	--hblank			<= '1' when hcount=0 else '0';
	
	process (vcount,hcount)
	begin
		if vcount<2 then
			if hcount<240 or (hcount>=256 and hcount<496) then
				vbl_vsync <= '0';
				vbl_hsync <= '0';
			else
				vbl_vsync <= '1';
				vbl_hsync <= '0';
			end if;
		elsif vcount=2 then
			if hcount<240 or (hcount>=256 and hcount<272) then
				vbl_hsync <= '0';
				vbl_vsync <= '0';
			else
				vbl_hsync <= '1';
				vbl_vsync <= '0';
			end if;
		else
			if hcount<16 or (hcount>=256 and hcount<272) then
				vbl_hsync <= '0';
				vbl_vsync <= '0';
			else
				vbl_hsync <= '1';
				vbl_vsync <= '0';
			end if;
		end if;
	end process;

	hsync <= not screen_sync when in_vbl='0' else vbl_hsync;
	vsync <= not vbl_vsync when in_vbl='1' else '0';
	
	visible <= (hcount>=166 and hcount<422 and vcount>=64 and vcount<256);
	
	process (clk8)
	begin
		if rising_edge(clk8) then
			if visible then
				red	<= color(1 downto 0);
				green	<= color(3 downto 2);
				blue	<= color(5 downto 4);
			else
				red	<= (others=>'0');
				green	<= (others=>'0');
				blue	<= (others=>'0');
			end if;
		end if;
	end process;
	
end Behavioral;

