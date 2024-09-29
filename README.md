RV32I CORE

✅Digital Design:
- The RTL is implemented in SystemVerilog as a single-cycle core (with plans to upgrade to a pipelined architecture) for the RV32I instruction set.
- Supported instruction types include: R, S, I, J, and B.
- The core is divided into two main sub-modules:
1. Control Unit (Main Decoder + ALU Decoder)
2. Datapath (Register File + ALU + Immediate Extender + Program Counter Logic, etc.)
✅Physical Implementation:
- To get an initial sense of area overhead, I’m currently using Tower-Semiconductor’s 180nm technology (4 metal layers). Later, I plan to switch to a more advanced technology node with additional metal layers, depending on available MPW programs.
- Current area: 0.6mm² (to be optimized further).
✅EDA Tools:
- Verification: Xcelium
- Synthesis: Genus
- Physical Implementation: Innovus

🔴Next Steps:
- Implementing an SRAM L1 cache for instruction and data memory.
- Converting the design from non-pipelined to pipelined architecture.
- Adding hazard handling.
- Introducing a Memory Management Unit (MMU).
- Expanding the hardware to support additional instructions.
- Developing a superscalar processor.
- Doing Full Power, Performance, Area (PPA) optimization.
