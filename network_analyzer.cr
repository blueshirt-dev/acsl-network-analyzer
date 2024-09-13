require "process"
require "socket"
require "kemal"

channel = Channel(String).new
SOCKETS = [] of HTTP::WebSocket

#This one works but has tshark recording in full and I'd prefer to not do that. 
dhcp = spawn do
  Process.run(command: "/usr/bin/tshark"
  # args: Process.parse_arguments("-i wlp1s0 -f \"udp port 67 or port 68\"")
  ) do |process|
    i = process.input
    o = process.output
    e = process.error
    until process.terminated?
      o.gets.try{ |value| #puts value #}
        if value.includes?("DHCP ACK")
          # puts value
          puts value.split(" ", remove_empty: true)[4].to_s
          SOCKETS.each { |socket|
            socket.send value 
            socket.send value.split(" ", remove_empty: true)[4]
          }
        end
      }
      # e.gets.try{ |value| puts "Error: ", value}  
    end
  end
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
    SOCKETS.each { |socket| 
      socket.send message
      socket.send dhcp.dead?.to_s
      # socket.send dhcpProc.exits?.to_s
    }
  end

  # Remove clients from the list when it's closed
  socket.on_close do
    SOCKETS.delete socket
  end
end

Kemal.run
# end