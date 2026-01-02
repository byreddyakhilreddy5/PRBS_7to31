# PRBS Generator Documentation

## Overview

Pseudo-Random Binary Sequence (PRBS) generators are essential components in digital communication systems for testing, synchronization, and data scrambling applications. A PRBS generator produces a deterministic sequence that appears random but can be reproduced using a known seed and polynomial. The PRBS generator described in this specification produces 8-bit parallel outputs that interface with a serializer module, which converts the parallel data into a serial stream. The serializer operates at four times the clock frequency of the PRBS generator and samples data on both rising and falling edges of its clock, effectively achieving an 8:1 serialization ratio.

## Functionality

### PRBS Generator Algorithm

In order to understand the PRBS generator operation, the following parameters are needed:
1. Clock signal (clock)
2. Reset signal (reset_n)
3. Enable signal (enable)
4. PRBS type selection (prbs_type)
5. Seed value (prbs_seed[30:0])
6. Load seed (load)
7. Parallel output (prbs_out[7:0])

The PRBS generator produces an 8-bit parallel output on each clock cycle of the PRBS clock domain. The generator implements a linear feedback shift register (LFSR) based on polynomial selection. First the seed will be loaded by toggling the load from LOW to HIGH, then, when enabled, the generator continuously produces pseudo-random sequences starting from the initial seed value. 

On each clock cycle when enable is HIGH, the generator produces 8 bits by:
1. Reading the MSB of the LFSR (the tap bit for the selected PRBS type)
2. Shifting the LFSR and computing the feedback bit based on the PRBS polynomial
3. Repeating this process 8 times to generate 8 output bits
4. The MSB of the generated 8-bit pattern corresponds to the first bit read, and the LSB corresponds to the eighth bit read

The first output after loading the seed is the first 8-bit PRBS pattern generated from that seed value, not simply the MSB 8 bits of the seed itself. Each subsequent output is the next 8-bit pattern in the PRBS sequence.

### Interface with Serializer

The PRBS generator provides 8-bit parallel outputs that are consumed by a serializer module. The serializer operates with the following characteristics:

- **Clock Frequency Ratio**: The serializer clock frequency is 4 times the PRBS generator clock frequency
- **Sampling Method**: The serializer samples data on both rising and falling edges of its clock
- **Serialization Ratio**: The serializer sends 8 bits serially for each 8-bit parallel input from the PRBS generator
- **Data Transfer**: Every PRBS clock cycle, 8 new bits are generated and made available to the serializer. The serializer processes these 8 bits and outputs 8 bits serially over 4 of its clock cycles (2 bits per clock cycle, one on each edge)

### Clock Domain Relationship

The relationship between the PRBS generator clock and serializer clock can be expressed as:

f<sub>serializer</sub> = 4 &times; f<sub>prbs</sub>

Where:
- f<sub>serializer</sub> : Serializer clock frequency
- f<sub>prbs</sub> : PRBS generator clock frequency

Since the serializer samples on both edges, it effectively operates at 2 &times; f<sub>serializer</sub> = 8 &times; f<sub>prbs</sub>, allowing it to output 8 serial bits per PRBS clock cycle from the 8-bit parallel input.

### FSM-Controlled Process

When reset_n is LOW, the PRBS generator should be initialized to a known state. The internal state machine orchestrates the PRBS generation process, managing seed initialization, LFSR operation, and output generation when reset_n is HIGH and enable is asserted.

### Reset and Initialization

- When reset_n is LOW, the PRBS generator should initialize its internal state, reset is active low asynchronous
- The seed value (prbs_seed[30:0]) should be loaded into the LFSR when load transitions from LOW to HIGH
- First prbs_seed is given, wait for some time and then load signal is toggled from LOW to HIGH and only after seed is loaded, enable will be given.
- When enable is LOW, PRBS generation should pause, maintaining the current state
- When enable is HIGH, PRBS generation should proceed normally

### Output Generation

- The PRBS generator should produce a new 8-bit output (prbs_out[7:0]) on each positive edge of the PRBS clock when enable is HIGH
- The output should remain stable between clock edges to allow proper sampling by the serializer
- The 8-bit output represents the parallel data that will be serialized by the downstream serializer module

