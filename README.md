Basys3 Digital Clock (VHDL)

This project contains a modular, synthesizable digital clock designed for the Digilent Basys 3 (Artix-7 xc7a35t) and Vivado 2024.2.

Features
- Timekeeping with BCD digits: HH:MM:SS.T (tenths)
- 0.1 s tick (10 Hz base tick)
- Modes controlled by push buttons `b1` (mode) and `b2` (action)
- Set hours/minutes, reset seconds/tenths, toggle display between HH:MM and SS, blinking digits during adjustment
- Modular VHDL design and a behavioral testbench for simulation

Files added
- src/clock_divider.vhd  -- Generates 10 Hz tick and slower enables
- src/bcd_counter.vhd    -- Generic BCD digit counter with load/increment/reset
- src/time_manager.vhd   -- Top timekeeping logic (HH:MM:SS.T) using BCD counters
- src/adjust_fsm.vhd     -- Mode FSM handling b1/b2 actions and blinking control
- src/blinker.vhd        -- Generates blink signal (0.7s on / 0.3s off)
- src/seg7_driver.vhd    -- Multiplexed 4-digit 7-seg driver for Basys3 (common anode)
- src/top.vhd            -- Top-level pin mapping and instantiation
- constraints/basys3_template.xdc -- Template XDC mapping for Basys3
- tb/time_tb.vhd         -- Behavioral testbench

How to simulate
1. Open Vivado 2024.2, create a project and add the `src` and `tb` files.
2. Set `tb/time_tb.vhd` as the simulation top.
3. Run behavioral simulation; testbench toggles clock and buttons to exercise modes.

Detailed steps (Vivado 2024.2)

1. Launch Vivado and create a new RTL project. When prompted, set the project type to "RTL Project" and do NOT specify sources at creation, or add sources after.
2. Add all files from the `src` directory as RTL sources and add the `tb/time_tb.vhd` as a simulation source.
3. In the Flow Navigator select "Run Simulation -> Run Behavioral Simulation". Vivado will elaborate and run the testbench. Use the waveform view to inspect signals such as `seg`, `an`, `led`, and internal signals if you add them to the testbench.
4. To synthesize for the Basys3 board, add the `constraints/basys3_template.xdc` to the project, set the part to `xc7a35ticsg324-1L` (or match your board's part), then run "Run Synthesis" and "Run Implementation" and generate bitstream.
5. Before programming the FPGA, review the I/O pin locations in the XDC and alter them to match your Basys3 board revision.

Quick simulation tips
- If the testbench simulation stops early, extend the simulation run time in the testbench `stim_proc` or run the simulator for a longer time from the Vivado GUI.
- To observe blink behavior faster during debugging you can temporarily change the blinker thresholds (0.7/0.3) to smaller counts in `blinker.vhd`.

Follow-ups / Improvements
- Add debouncing for push buttons (currently FSM assumes clean pulses). A small filter/debounce module using the 10Hz tick is recommended.
- Implement alarm comparison logic and an audible buzzer/LED pattern.
- Add support for displaying seconds or toggling between HH:MM and SS on the 7-seg driver.

Notes
- The alarm feature files include optional signals in the time manager and FSM; simple LED indicator is provided.
- This is a starting point: you may need to adapt pin names in the XDC to match your board revision.
