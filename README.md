RV32I CORE

✅Digital Design:
- The RTL is implemented in SystemVerilog as a 5 stage pipeline (Fetch, Decode, Execute, Memory, Writeback)
- Contains a Hazard Unit to handle data hazards and control hazards
- Supported instruction types include: R, S, I, J, and B.

✅EDA Tools:
- Verification: Xcelium
- Synthesis: Genus
- Physical Implementation: Innovus

🔴Next Steps:
- Implementing an SRAM L1 cache for instruction and data memory.
- Introducing a Memory Management Unit (MMU).
- Expanding the hardware to support additional instructions.
- Developing a superscalar processor.
- Full physical implementation.
- Doing Full Power, Performance, Area (PPA) optimization.
