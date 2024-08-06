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

# Process.run(command: "/usr/bin/tshark") do |s|
#     i = s.input
#     o = s.output
#     i.puts "-i 2 -f \"udp port 67 or port 68\""
#     puts o.gets
# end

Process.run(command: "sudo") do |s|
    i = s.input
    o = s.output
    i.puts "tshark -i wlp1s0 -f \"udp port 67 or port 68\""
    puts o.gets
end

command = "tshark -i wlp1s0 -f \"udp port 67 or port 68\""
io = IO::Memory.new
Process.run(command, shell: true, output: io)
output = io.to_s

def run_cmd(cmd, args)
    stdout = IO::Memory.new
    stderr = IO::Memory.new
    status = Process.run(cmd, args: args, output: stdout, error: stderr)
    if status.success?
      {status.exit_code, stdout.to_s}
    else
      {status.exit_code, stderr.to_s}
    end
  end
  

  cmd = "ping"
  hostname = "10.11.40.1"
  args = ["-c 2", hostname]
  status, output = run_cmd(cmd, args)
  puts "ping: #{hostname}: Name or service not known" unless status == 0


  File.open("app_name.log", "a") do |file|
    Process.new("/usr/bin/tshark", output: file)
  end
  