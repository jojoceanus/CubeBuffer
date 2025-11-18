# CubeBuffer

CubeBufer is a 3D data management infrastructure for AI accelerators, supporting flexible multi-dimensional data block access and efficient parallel read/write operations.

## Features

- Three-dimensional address space: Data is logically organized by the three-level coordinates S(SRAM)/B(BANK)/G(GROUP).
- High-bandwidth read/write: The B/G dimensions correspond to BANK/GROUP respectively, enabling multi-channel parallel read/write.
- Flexible access modes: Supports Window+Cell-based dual sliding window access and hardware padding operations.
- Multi-precision support: Compatible with 4/8/16-bit data formats to meet different precision computing requirements.
- Configurable structure: `BANK_NUM` (8–20, corresponding to B dimension), `GROUP_NUM` (1–15, corresponding to G dimension).
- Instruction control: Can be controlled by instructions generated from an application layer data descriptor.

## Application Scenarios

Caching feature maps, weights, or intermediate activations in AI accelerators such as CNN/Transformer. It reduces off-chip memory access and improves computing speed.

## Usage

Instantiate the top-level module `databuffer`, configure parameters, and issue instructions as follows:

verilog

```verilog
databuffer #( 
	 .BANK_NUM(17), 
	 .GROUP_NUM(10) 
) u_buffer (...);
```

## Supplementary Notes

- In most application scenarios, the SRAM level only requires a parallelism of 1, so the S parallelism is currently fixed at 1.
- For simulation, the behavioral model SRAM_nohold is used (with a flexible interface for easy verification). For synthesis, replace it with the SRAM instance from the target process library.
