#!/usr/bin/env ruby

cur = File.dirname(__FILE__)
cp = ENV['CLASSPATH'] || ''

['javancss', 'ccl', 'jhbasic'].each do |c|
   cp += ":#{cur}/../lib/jncss/#{c}.jar"
end

fn = {}
fn.default = 0

classes = {}
classes.default = 0
%x[java -classpath #{cp} javancss.Main -recursive -object #{ARGV[1]}].each_line do |l|
  l.chomp!.strip!
  case l
  when /^ *[0-9]+/
    ll = l.split(/\s+/)
    name = ll[5]
    loc = ll[1].to_i
    f = ll[2].to_i
    classes[name] += loc
    fn[name] = f
  end
end
puts " loc,functions"
classes.keys.sort.each do |m|
  puts "#{m},#{classes[m]},#{fn[m]}"
end

