# Trigger Crystal: 


### Capture All Dhcp Traffic

```bash
sudo tshark -i {interface} -f "udp port 67 or port 68"
```

### Capture When Router Gives Dhcp Offer And Ack
```bash
sudo tshark -i {interface} -n -Y "ip.addr=={router ip}" -f "udp port 67 or port 68"
```

### Capture Host Dhcp Traffic Before Ip Address Given

```bash
sudo tshark -i {interface} -n -Y "ip.addr==0.0.0.0" -f "udp port 67 or port 68"
```
Clients that don't have an IP yet are 0.0.0.0.

# Crystal Launch Capture And Filter:

### Capture In Pcap (Filtered) *Can Only Use Capture Filters* :

```bash
sudo tshark -f "host 0.0.0.0" -n -i {interface} -w {filename}_capture.pcap
```

### Filter From Captured Pcap & Save To New File:

```bash
sudo tshark -r {filename}_capture.pcap -Y "tcp.port == 80 || udp.port == 80" -w {filename}_port_filter.pcap
```

### Convert Captured Pcap To Json: 

```bash
sudo tshark -2 -R {your filter} -r {input filename} -T json > {output filename}
```

### Capture In Json:

```bash
sudo tshark -T json -n -Y "ip.addr=={offered_IP}" -i {interface} > {filename}.JSON
```