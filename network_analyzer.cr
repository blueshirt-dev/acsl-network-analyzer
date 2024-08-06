require "process"

Process.run(command: "bash") do |s|
    i = s.input
    o = s.output
    i.puts "echo Hello"
    puts o.gets
    i.puts "echo World!"
    puts o.gets
    i.puts "exit"
end

tshark=""

Process.run(command: "bash") do |s|
    i = s.input
    o = s.output
    i.puts "which tshark"
    tshark = o.gets
    puts tshark 
    i.puts "exit"
end

# Process.run(command: tshark) do |s|
#     i = s.input
#     o = s.output
# end
