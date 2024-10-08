require "process"
require "socket"
require "kemal"

terminate = Channel(String).new
SOCKETS = [] of HTTP::WebSocket

#This one works but has tshark recording in full and I'd prefer to not do that. 
dhcp = spawn(name: "dhcpAlertFiber") do
  Process.run(command: "/usr/bin/tshark"
  # args:\tProcess.parse_arguments("-i wlp1s0 -f \"udp port 67 or port 68\"")
  ) do |dhcpAlertProcess|
    i = dhcpAlertProcess.input
    o = dhcpAlertProcess.output
    e = dhcpAlertProcess.error
    until dhcpAlertProcess.terminated?
      o.gets.try{ |value| #puts value #}
        if value.includes?("DHCP ACK")
          # puts value
          deviceIP = value.split(" ", remove_empty: true)[4].to_s
          puts deviceIP
          recordDevice(deviceIP, terminate)
          sendSocketMessage("Added Device: #{deviceIP}")
        end
      }
      # e.gets.try{ |value| puts "Error:\t", value}  
    end
  end
  puts "dhcpAlertProcess Terminated"
end

def recordDevice(deviceIP, terminationChannel)
  recordDevice = spawn(name: "recordDevice#{deviceIP}") do
    sendSocketMessage("Recording for #{deviceIP} started")
    Process.run(command: "/usr/bin/tshark",
    args: Process.parse_arguments("-f \"host #{deviceIP}\" -n -i wlp1s0 -w ./recordings/#{deviceIP}_capture.pcap")
    ) do |recordDeviceProcess|
      i = recordDeviceProcess.input
      o = recordDeviceProcess.output
      e = recordDeviceProcess.error
      until recordDeviceProcess.terminated?
        select
        when terminationChannel.receive?
          sendSocketMessage("Termination signal received. Attempting termination of #{deviceIP} recording")
          # recordDeviceProcess.signal(Signal::KILL)
          recordDeviceProcess.terminate(graceful: false)
        else
          # puts "Recording for #{deviceIP}"
          sendSocketMessage("#{deviceIP} recording :\t#{Time.utc}")
        end
        sleep 10.seconds
      end
    end
    # puts "recordDeviceProcess#{deviceIP} Terminated"
    sendSocketMessage("Recording for #{deviceIP} terminated.")
    # puts "Calling filters"
    filterCapturedTraffic(deviceIP)
  end
end

def filterCapturedTraffic(deviceIP)
  spawn(name: "tsharkFiltersFiber") do
    # puts "filtering for #{deviceIP}"
    sendSocketMessage("Filtering captured output for #{deviceIP}")
    filteringForIPs(deviceIP)
    # puts "filter one done"
  end
end

def filteringForIPs(deviceIP)
  Process.run(command: "/usr/bin/bash",
    args: Process.parse_arguments(" -c \"tshark -r ./recordings/#{deviceIP}_capture.pcap -2 -R ip -eip.src -eip.dst -eframe.protocols -T json > ./recordings/#{deviceIP}_ips.json \"")) 
  
  json = File.open("./recordings/#{deviceIP}_ips.json") do |file|
    JSON.parse(file)
  end
  
  json[0]["_source"]["layers"]["ip.src"][0]
  
  ipset = Set(String).new()
  
  json.as_a.each do |idx|
    srcIP = idx["_source"]["layers"]["ip.src"][0].as_s
    destIP = idx["_source"]["layers"]["ip.dst"][0].as_s
    ipset.add(srcIP)
    ipset.add(destIP)
  end

  sendSocketMessage("IPs talked with:\t#{ipset.size}")  
  
  ipsArray = ipset.to_a
  counter = 100
  responses = Array(JSON::Any).new
  while ipsArray.size > 0
    sendSocketMessage("Asking ip-api service for details on IPs visited in batches of 100")
    response = HTTP::Client.post("http://ip-api.com/batch",
      headers: HTTP::Headers{"User-Agent" => "ACSL_Network_Traffic_Analyzer"},
      body:   ipsArray.shift(counter).to_json)
    jsonResponse = JSON.parse(response.body)
    jsonResponse.as_a.each do |idx|
      responses.push(idx)
    end
    sleep 15.seconds
  end
  
  responses.each do |idx|
    status = idx["status"]
    if status == "fail"
      message = idx["message"]
      unknwonIP = idx["query"]
    sendSocketMessage("Failure of #{unknwonIP}:\t#{message}")
    else
      country = idx["country"]
      region = idx["regionName"]
      city = idx["city"]
      isp = idx["isp"]
      org = idx["org"]
      ip = idx["query"]
    sendSocketMessage("Info for #{ip}\n\tCountry:\t#{country}\n\tRegion:\t#{region}\n\tCity:\t#{city}\n\tISP:\t#{isp}\n\tOrg:\t#{org}")
    
    end
  end
  sendSocketMessage("Filter one complete")
end

def sendSocketMessage(message)
  puts message
  SOCKETS.each { |socket|
    socket.send message
  }
end

puts "Kemal testing"
# spawn do
logging false
serve_static false

get "/" do
  render "public/index.ecr"
end

ws "/chat" do |socket|
  # Add the client to SOCKETS list
  SOCKETS << socket

  # Broadcast each message to all clients
  socket.on_message do |message|
    sendSocketMessage(message)
    sendSocketMessage("DHCP recording dead status:\t#{dhcp.dead?.to_s}")
    if message.downcase.includes?("stop")
      socket.send "Attempting Termination"
      terminate.close
    end
  end

  # Remove clients from the list when it's closed
  socket.on_close do
    SOCKETS.delete socket
  end
end

Kemal.run
# end