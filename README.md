# ANC_System

NJIT Senior Design Project - Fall 2020
Team 9 - FPGA-based ANC System

We investigate active noise control solutions that are capable of attenuating a broad band of frequencies. The core objective of our project is to design and demonstrate an FPGA-based ANC system to attenuate undesired low frequency noise in HVAC air-ducts. Although ANC systems have been made before, we sought to develop a cost-effective FPGA-based version by creating hardware-efficient digital filters in VHDL.

Our ANC System is modelled using a typical Feedforward Filtered-X LMS configuration. The LMS algorithms and filters for the secondary and acoustic feedback paths are of order N=128 with a step size of mu=0.25 and leakage factor of a=0.999998927116394. The LMS algorithms and filters for the primary path are of order N=384 with the same step size and leakage factor. The sampling frequency is 10Khz. Resource Usage: 14158 LUT, 29671 FF, 32 BRAM, 220 DSP. Currently, the filter weights are stored in BRAMs, but the sample buffers are still stored in multiplexed flip flops. We plan to redesign this so that the sample buffer is also stored in BRAM to further alleviate the FF and LUT usage.

Against a 150Hz + 225Hz noise source propagating through PVC pipe (3 inch diameter, 48 inch length) our ANC system is capable of learning and attenuating the noise at the opening of the PVC pipe from 85dBA to 67dBA after 40 seconds of adapting. Additional testing is due to find the band of frequencies for which our system is effective.
