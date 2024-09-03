require "process"
require "socket"
require "kemal"

channel = Channel(String|Nil).new

puts "tshark fiber attempt"
spawn do
  Process.run(command: "/usr/bin/tshark") do |s|
    i = s.input
    o = s.output
    i.puts "-i 2 -f \"udp port 67 or port 68\""
    10.times do
      channel.send(o.gets)
    end
    s.close
  end
end

puts "tshark fiber channel receive"
10.times do 
  puts channel.receive()
end