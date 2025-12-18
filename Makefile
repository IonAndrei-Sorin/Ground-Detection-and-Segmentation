# Tools
GHDL = ghdl
GHDL_FLAGS = --std=08

# Source files
SRC = src/ground_types_pkg.vhd src/groundSegmentation.vhd
TB  = tb/tb_groundSegmentation.vhd

TB_ENTITY = tb_groundSegmentation

# Targets
all: sim

# Simulation without waveform
sim: clean
	$(GHDL) -a $(GHDL_FLAGS) $(SRC)
	$(GHDL) -a $(GHDL_FLAGS) $(TB)
	$(GHDL) -e $(GHDL_FLAGS) $(TB_ENTITY)
	$(GHDL) -r $(GHDL_FLAGS) $(TB_ENTITY)

# Simulation without waveform
sim-wave: clean
	$(GHDL) -a $(GHDL_FLAGS) $(SRC)
	$(GHDL) -a $(GHDL_FLAGS) $(TB)
	$(GHDL) -e $(GHDL_FLAGS) $(TB_ENTITY)
	$(GHDL) -r $(GHDL_FLAGS) $(TB_ENTITY) --wave=waves.ghw

# Clean up generated files
clean:
	rm -f work-obj93.cf
	rm -f *.cf
	rm -f *.ghw
