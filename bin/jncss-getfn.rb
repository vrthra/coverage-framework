#!/usr/bin/ruby

cur = File.dirname(__FILE__)
cp = ENV['CLASSPATH'] || ''

['javancss', 'ccl', 'jhbasic'].each do |c|
   cp += ":#{cur}/../lib/jncss/#{c}.jar"
end
methods = {}
methods.default = 0
%x[java -classpath #{cp} javancss.Main -recursive -function #{ARGV[1]}].each_line do |l|
  l.chomp!
  case l
  when /^ *[0-9]+/
    ll = l.split(/\s+/)
    name = ll[5]
    loc = ll[1].to_i
    name = name.gsub!(/\(.*\)/,'')
    methods[name] += loc
  end
end
methods.keys.sort.each do |m|
  puts "#{m},#{methods[m]}"
end

