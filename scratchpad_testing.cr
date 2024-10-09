require "process"
require "socket"
require "kemal"
require "json"

channel = Channel(String).new
SOCKETS = [] of HTTP::WebSocket

# puts "Hello World Fiber attempt"
# spawn do
#   Process.run(command: "bash") do |s|
#     i = s.input
#     o = s.output
#     i.puts "echo Hello"
#     puts o.gets
#     i.puts "echo World!"
#     puts o.gets
#     i.puts "exit"
#   end
# end

# puts "Which tshark fiber attempt"
# tshark = ""
# spawn do 
#   Process.run(command: "bash") do |s|
#     i = s.input
#     o = s.output
#     i.puts "which tshark"
#     tshark = o.gets
#     puts tshark
#     i.puts "exit"
#   end
# end

# puts "tshark attempt"
# Process.run(command: "/usr/bin/tshark") do |s|
#     i = s.input
#     o = s.output
#     i.puts "-i 2 -f \"udp port 67 or port 68\""
#     10.times do
#       puts o.gets
#     end
#     s.close
# end

# puts "another tshark attempt"
# puts Process.new(
#   command: "/usr/bin/tshark",
#   args: Process.parse_arguments("-i 2 -f \"udp port 67 or port 68\""),
#   shell: true,
#   output: Process::Redirect::Pipe
#   )

# puts "tshark fiber attempt"
# spawn do
#   Process.run(command: "sudo") do |s|
#     i = s.input
#     o = s.output
#     i.puts "tshark -i wlp1s0 -f \"udp port 67 or port 68\""
#     10.times do 
#       channel.send(o.gets)
#     end
#   end
# end
##This one works but has tshark recording in full and I'd prefer to not do that. 
# puts Process.parse_arguments("-i wlp1s0 -f \"udp port 67 or port 68\"")
# spawn do
#   Process.run(command: "/usr/bin/tshark"
#   # args: Process.parse_arguments("-i wlp1s0 -f \"udp port 67 or port 68\"")
#   ) do |s|
#     i = s.input
#     o = s.output
#     e = s.error
#     # o.gets.try { |value| channel.send(value)}
#     # 
#     # SOCKETS.each { |socket| socket.send }
#     while true
#       o.gets.try{ |value| #puts value #}
#         if value.includes?("DHCP ACK")
#           puts value
#           puts value.split(" ", remove_empty: true).to_s
#           SOCKETS.each { |socket| socket.send value}
#           SOCKETS.each { |socket| socket.send value.split(" ", remove_empty: true)[4]}
#         end
#       }
#       # e.gets.try{ |value| puts "Error: ", value}  
#     end
#     # 10.times do
#     #   channel.send(o.gets)
#     # end
#     # s.close
#   end
# end

# puts "dual pipe tshark"
# dhcp = spawn do
#   reader, writer = IO.pipe
#   Process.run "/usr/bin/tshark -i wlp1s0 -f \"udp port 67 or port 68\"", shell: true, output: writer do |process|
#     until process.terminated?
#       line = reader.gets
#       if line 
#         puts line
#       else 
#         puts "Empty Line"
#       end
#     end
#   end
# end

# puts "Attempting to get tshark for only dhcp instead of full recording"
# dhcp = spawn do
#   dhcpProc = Process.run(command: "/usr/bin/tshark -i wlp1s0 --log-level debug -f \"udp port 67 or port 68\"",
#   # args: ["-i", "wlp1s0", "-f", "udp port 67 or port 68"]
#   shell: true,
#   output: Process::Redirect::Pipe#,
#   # error: Process::Redirect::Inherit
#   ) do |s|
#     # puts s.info
#     puts s.inspect
#     i = s.input
#     o = s.output
#     # e = s.error
#     # o.gets.try { |value| channel.send(value)}
#     # 
#     # # SOCKETS.each { |socket| socket.send }
#     while true
#       # puts o.closed?.to_s
#       # puts o.info
#       # puts o.gets_to_end
#       # puts "before gets"
#       # # o.gets.try{ |value| puts "Output: ", value }
#       # puts "before flush"
#       # # o.flush
#       # puts "after flush"
#     #     if value.includes?("DHCP ACK")
#     #       # puts value
#     #       puts value.split(" ", remove_empty: true).to_s
#     #       SOCKETS.each { |socket| 
#     #         socket.send value
#     #         socket.send value.split(" ", remove_empty: true)[4]  
#     #       }
#     #     end
#     #   }
#       # e.gets.try{ |value| puts "Error: ", value} 
#     end
#     # 10.times do
#     #   channel.send(o.gets)
#     # end
#     # s.close
#   end
#   # puts dhcpProc.exists?.to_s
# end

# puts "Attempting to get tshark for only dhcp instead of full recording"
# dhcp = spawn do
#   dhcpProc = Process.new(command: "/usr/bin/tshark -i wlp1s0 -f \"udp port 67 or port 68\"",
#   # args: ["-i", "wlp1s0", "-f", "udp port 67 or port 68"]
#   shell: true,
#   output: Process::Redirect::Pipe,
#   error: Process::Redirect::Pipe
#   ) #do |s|
#     # i = dhcpProc.input
#     o = dhcpProc.output
#     e = dhcpProc.error


#     o.read_timeout=(5.seconds)
#     e.read_timeout=(5.seconds)
#     # o.gets.try { |value| channel.send(value)}
#     # 
#     # # SOCKETS.each { |socket| socket.send }
#     while true
#       # puts "Output: "
#       # puts o.closed?.to_s
#       # puts o.info
#       # # puts o.gets_to_end
#       # puts o.inspect
#       # puts o.to_s

#       # puts "Error: "
#       # puts e.closed?.to_s
#       # puts e.info
#       # # puts e.gets_to_end
#       # puts e.inspect
#       # puts e.to_s
#       begin 
#         # puts e.peek.to_s
#         # puts o.peek.to_s
#         o.gets.try{ |value| puts "Output: ", value }
#         e.gets.try{ |value| puts "Error: ", value} 
#       rescue
#         puts "Nothing to read"
#       end
#     #     if value.includes?("DHCP ACK")
#     #       # puts value
#     #       puts value.split(" ", remove_empty: true).to_s
#     #       SOCKETS.each { |socket| 
#     #         socket.send value
#     #         socket.send value.split(" ", remove_empty: true)[4]  
#     #       }
#     #     end
#     #   }

#     end
#     # 10.times do
#     #   channel.send(o.gets)
#     # end
#     # s.close
#   # end
#   # puts dhcpProc.exists?.to_s
# end

# puts "Different output method attempt"
# dhcp = spawn do
#   stdout = IO::Memory.new
#   process = Process.new(command: "/usr/bin/tshark -i wlp1s0 -f \"udp port 67 or port 68\"", output: stdout)
#   status = process.wait
#   10.times do
#     output = stdout.to_s
#   end 
# end

# puts "different tshark attempt"
# command = "sudo tshark -i wlp1s0 -f \"udp port 67 or port 68\""
# io = IO::Memory.new
# Process.run(command, shell: true, output: io)
# output = io.to_s
# puts output

# puts "ping run_cmd attempt"
# def run_cmd(cmd, args)
#   stdout = IO::Memory.new
#   stderr = IO::Memory.new
#   status = Process.run(cmd, args: args, output: stdout, error: stderr)
#   if status.success?
#     {status.exit_code, stdout.to_s}
#   else
#     {status.exit_code, stderr.to_s}
#   end
# end

# cmd = "ping"
# hostname = "10.11.40.1"
# args = ["-c 2", hostname]
# status, output = run_cmd(cmd, args)
# puts "ping: #{hostname}: Name or service not known" unless status == 0

# puts "?output to file attempt?"
# File.open("app_name.log", "a") do |file|
#   Process.new("/usr/bin/tshark", output: file)
# end

# puts "ping fiber attempt"
# spawn do
#   Process.run(command: "/usr/bin/ping") do |s|
#     i = s.input
#     o = s.output
#     i.puts "-c 2 10.11.40.1"
#     10.times do 
#       channel.send(o.gets)
#     end
#   end
# end

# puts "tshark fiber channel receive"
# 10.times do 
#   puts channel.receive()
# end

# puts "ping fiber channel receive"
# 10.times do 
#   puts channel.receive()
# end


# puts "tshark fiber and read output"
# spawn do
#   STDOUT.printf("[%s] Starting\n", "tshark -i wlp1s0 -f \"udp port 67 or port 68\"")
#   out_read, out_write = IO.pipe
#   err_read, err_write = IO.pipe
#   proc = Process.new(
#     command: "tshark -i wlp1s0 -f \"udp port 67 or port 68\"",
#     input: Process::Redirect::Close,
#     output: out_write,
#     error: err_write
#   )

#   while !out_read.closed?
#     STDOUT.printf("[%s][stdout] %s", "tshark -i wlp1s0 -f \"udp port 67 or port 68\"", out_read.gets(chomp: false))
#     # STDERR.printf("[%s][stderr] %s", command_name, err_read.gets(chomp: false))
#   end
# end

# puts "Kemal testing"
# # spawn do
# logging false
# serve_static false

# get "/" do
#   render "public/index.ecr"
# end

# ws "/chat" do |socket|
#   # Add the client to SOCKETS list
#   SOCKETS << socket

#   # Broadcast each message to all clients
#   socket.on_message do |message|
#     SOCKETS.each { |socket| 
#       socket.send message
#       socket.send dhcp.dead?.to_s
#       # socket.send dhcpProc.exits?.to_s
#     }
#   end

#   # Remove clients from the list when it's closed
#   socket.on_close do
#     SOCKETS.delete socket
#   end
# end

# Kemal.run
# end
# 
# 
json = File.open("./recordings/10.11.40.237_ips.json") do |file|
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

ipset.to_json

json = File.open("./ip-api.json") do |file|
  JSON.parse(file)
end

json[0]["_source"]["layers"]["ip.src"][0]

json.as_a.each do |idx|
  srcIP = idx
end
