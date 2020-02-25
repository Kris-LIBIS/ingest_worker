#!/usr/local/bin/ruby
$stdout.sync = true
name = ENV['NAME']
begin
  puts "#{name} - Started"
  loop do
    i = rand(100)
    puts "#{name} - draw: #{i}"
    s = 2
    puts "#{name} - sleeping for #{s} seconds ..."
    sleep s
    exit 1 if i > 90
  end
ensure
  puts "#{name} - Stopped"
end
