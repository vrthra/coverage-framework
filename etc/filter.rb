def filter(mutants)
  begin
    x = []
    puts mutants.size()
    mutants.each do |m|
      puts ">>>> Line: #{m.getLineNumber()}"
      puts ">>>> Method: #{m.getMethod()}"
      puts ">>>> Class: #{m.getClassName()}"
      x << m
    end
    mutants.clear()
    x.each do |y|
      mutants << y
    end
  return mutants
  rescue Exception => e
    puts e
  end
end
