require "process"
require "socket"
require "kemal"

channel = Channel(String).new
terminate = Channel(String).new
SOCKETS = [] of HTTP::WebSocket

#This one works but has tshark recording in full and I'd prefer to not do that. 
dhcp = spawn(name: "dhcpAlertFiber") do
  Process.run(command: "/usr/bin/tshark"
  # args: Process.parse_arguments("-i wlp1s0 -f \"udp port 67 or port 68\"")
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
      # e.gets.try{ |value| puts "Error: ", value}  
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
          puts "Termination signal received Attempting termination of #{deviceIP} recording"
          # recordDeviceProcess.signal(Signal::KILL)
          recordDeviceProcess.terminate(graceful: false)
        else
          puts "Recording for #{deviceIP}"
          sendSocketMessage("#{deviceIP} recording : #{Time.utc}")
        end
        sleep 1.minute
      end
    end
    puts "recordDeviceProcess#{deviceIP} Terminated"
    sendSocketMessage("Recording for #{deviceIP} terminated.")
  end
end

def sendSocketMessage(message)
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
    sendSocketMessage("DHCP recording dead status: #{dhcp.dead?.to_s}")
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