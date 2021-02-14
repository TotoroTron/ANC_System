# ANC_System

NJIT Senior Design Project - Fall 2020 1st Place Finish
Team 9 - FPGA-based ANC System

We investigate active noise control solutions that are capable of attenuating a broad band of frequencies. The core objective of our project is to design and demonstrate an FPGA-based ANC system to attenuate undesired low frequency noise in HVAC air-ducts. Although ANC systems have been made before, we sought to develop a cost-effective FPGA-based version by creating hardware-efficient digital filters in VHDL.

Our ANC System is modelled using a typical Feedforward Filtered-X LMS configuration. The LMS algorithms and filters for the secondary and acoustic feedback paths are of order N=128 with a step size of mu=0.015625. The LMS algorithm and filter for the primary path are of order N=384 with the same step size and leakage factor. The sampling frequency is 10Khz. Resource Usage: 6089 LUT, 1936 FF, 48 BRAM, 120 DSP.

Against a 150Hz + 225Hz noise source propagating through PVC pipe (3 inch diameter, 48 inch length) our ANC system is capable of learning and attenuating the noise at the opening of the PVC pipe from 85dBA to 67dBA after 40 seconds of adapting. Additional testing is due to find the band of frequencies for which our system is effective.
