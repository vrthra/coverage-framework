#!/usr/bin/env ruby

cur = File.dirname(__FILE__)
cp = ENV['CLASSPATH'] || ''

['javancss', 'ccl', 'jhbasic'].each do |c|
   cp += ":#{cur}/../lib/jncss/#{c}.jar"
end
complex = {}
complex.default = 0
methods = {}
methods.default = 0
%x[java -classpath #{cp} javancss.Main -recursive -function #{ARGV[0]}].each_line do |l|
  l.chomp!.strip!
  case l
  when /^ *[0-9]+/
    ll = l.split(/\s+/)
    name = ll[4]
    loc = ll[1].to_i
    cplx = ll[2].to_i
    name = name.gsub!(/\(.*\)/,'')
    methods[name] += loc
    complex[name] = cplx if complex[name] < cplx
  end
end
puts " loc,complexity"
methods.keys.sort.each do |m|
  puts "#{m},#{methods[m]},#{complex[m]}"
end

