puts "Attempting gets with process long"
Process.run(command: "/usr/bin/tshark",
  args: Process.parse_arguments("-i wlp1s0 -f \"udp port 67 or port 68\"")
  ) do |process|
  until process.terminated?
    line = process.output.gets
    if line 
      puts line
    else 
      puts "Empty Line"
    end
  end
end

# puts "Attempting gets with process short"
# reader, writer = IO.pipe
# Process.run(command: "/usr/bin/tshark",
#   args: Process.parse_arguments("-i wlp1s0")
# #   output: writer
#   ) do |process|
#   until process.terminated?
#     line = process.output.gets
#     if line 
#       puts line
#     else 
#       puts "Empty Line"
#     end
#   end
# end

puts "Program Ended"