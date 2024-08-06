# Network Traffic Analyzer

This project is for Gateway Community College's Advanced Cyber Systems Lab to be able to let any device connect to a separate Network and get a report of who their device connected to while they were using it. 

## Prerequisites

This requires hardware setup where there's a computer with two Network Interface Cards (NICs) that has all of the traffic on a network mirrored to one of the NICs. 

It also requires Crystal Lang and Wireshark to be installed on that machine. 

## Relevant Commands

```bash
crystal run network_analyzer.cr
```