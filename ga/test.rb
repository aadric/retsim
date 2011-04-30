require_relative("condition")
require_relative("action")
require_relative("entry")
require_relative("series")
require 'fileutils'

def selection_process(entries, opts = {})
  count = opts[:count] ||= 30
  ret = []
  entries = entries.sort {|a,b| b.dps <=> a.dps}

  # Always save the best result
  ret << entries.shift

  (count-1).times do
    total_dps = entries.inject(0) {|sum, x| sum + x.dps} 
    normalized_sum = 0
    entries.each do |x|
      x.normalized_dps = x.dps.to_f / total_dps
      x.normalized_sum = normalized_sum = normalized_sum + x.normalized_dps
    end
    val = rand
    entry = entries.select{|x| x.normalized_sum >= rand}.first
    entry.survive
    ret << entry
    entries.delete(entry)
  end
  ret
end


def alternative_method
  series = Series.new(:filename => File.join("ga", "tset.txt"))

  puts "Running Primary"
  primary_sim = Simulation.new.run do |sim|
    sim.run_mode = :time
    sim.priorities = PriorityFromString.new(sim, series.to_s)
  end

  while true
    mutant_series = Marshal.load(Marshal.dump(series))

    mutant_series.mutate
    puts "-"*80
    puts "New Mutant..."
    mutant_sim = Simulation.new.run do |sim|
      sim.run_mode = :time
      sim.priorities = PriorityFromString.new(sim, mutant_series.to_s)
    end

    run_count = 50

    while primary_sim.dps_range & mutant_sim.dps_range and (primary_sim.margin_of_error >= 20 or mutant_sim.margin_of_error >= 20)
      puts "-"*80
      puts "Running Primary (" + primary_sim.dps.round.to_s+")"
      primary_sim.run(:count => run_count)
      puts "Running Mutant"
      mutant_sim.run(:count => run_count)
      run_count += 50
    end
    puts "-"*80
    
    if(mutant_sim.dps > primary_sim.dps)
      primary_sim = mutant_sim
      series = mutant_series
      series.dps = primary_sim.dps
      series.write_to_file(:dir => File.join("ga","alt"))
      puts "Mutant Wins"
    else
      puts "Primary Wins"
    end

    puts "*"*80
  end

  puts series.to_s
end
      




#   dir = "gen" + origin_gen.to_s.rjust(2,"0") # 1 -> "gen01"
#   dir = Dir.new(File.join("ga", dir))
# 
#   files = dir.entries.select{|x| x =~ /\.txt$/}
#   files = files.map {|x| File.join(dir, x)}
# 
#   all_series = []
#   files.each do |filename|
#     series = Series.new(:filename => filename)
#     all_series << series 
#   end
# 
#   best_series = all_series.max_by{|x| x.dps}
#   puts "-"*50
#   puts best_series.filename + " = " + best_series.dps.to_s
#   average = all_series.inject(0){|memo,x| memo + x.dps}
#   puts "Average = " + (average.to_f / all_series.count).to_s
# 
#   return

def analyze_generation(gen_id, opts = {})
  rank = opts[:rank] ||= false

  dir = Dir.new(File.join("ga", "gen" + gen_id.to_s.rjust(3,"0")))

  files = dir.entries.select{|x| x =~ /\.txt$/}
  files = files.map {|x| File.join(dir, x)}

  all_series = []
  files.each do |filename|
   all_series << Series.new(:filename => filename)
  end

  average = all_series.inject(0){|memo,x| memo + x.dps} / all_series.count.to_f

  standard_deviation = all_series.inject(0) do |sum, item|
    sum += (item.dps - average) ** 2 
  end
  standard_deviation = (standard_deviation / (all_series.size-1)) ** 0.5

  best_series = all_series.max_by{|x| x.dps}
  puts "-"*50
  puts best_series.filename + " = " + best_series.dps.to_s
  puts "Average = " + average.round_to(2).to_s
  puts "Standard Dev = " + standard_deviation.round_to(2).to_s
  if rank
    all_series.sort!{|x,y| y.dps <=> x.dps}
    all_series.each do |x|
      print x.dps.to_s+" "
    end
    puts ""
  end
end


def generate_random_series(opts = {})
  id = opts[:id] ||= 1
  count = opts[:count] ||= 25

  dir = File.join("ga", "gen" + id.to_s.rjust(3,"0"))
  FileUtils.rm_rf(dir)
  FileUtils.mkdir_p(dir)

  count.times do
    series = Series.new
    sim = Simulation.new.run do |sim|
      sim.run_mode = :time
      sim.priorities = PriorityFromString.new(sim, series.to_s)
    end
    series.dps = sim.dps
    series.write_to_file(:dir => dir)
  end
end

def run_this(origin_gen)
  dir = Dir.new(File.join("ga", "gen" + origin_gen.to_s.rjust(3,"0")))
  files = dir.entries.select {|x| x =~ /\.txt$/}
  files = files.map {|x| File.join(dir, x)}

  gen01_series = []
  total_dps = 0
  files.each do |filename|
    series = Series.new(:filename => filename)
    if series.entries.empty?
      puts "BAD FILE = " + filename
    end
    gen01_series << series
  end

  survivors = selection_process(gen01_series, :count => 25)

  target_gen = "gen" + (origin_gen+1).to_s.rjust(3,"0")

  dir = File.join("ga",target_gen) 
  FileUtils.rm_rf(dir)

  FileUtils.mkdir_p(dir)

  75.times do |i|
    x,y = survivors.sample(2)

    series = Series.new(:series1 => x, :series2 => y)

    series.mutate if random < 0.15

    sim = Simulation.new.run do |sim|
      sim.run_mode = :time
      sim.priorities = PriorityFromString.new(sim, series.to_s)
    end

    series.dps = sim.dps
    series.write_to_file(:dir => dir)
    #puts (i+1).to_s.rjust(2,"0") + ": " + series.filename + " => " + series.dps.to_s
  end

  survivors.each do |series|
    series.write_to_file(:dir => dir)
  end
end


# 
# gen01_series.each do |series|
#   series.normalized_dps = series.dps.to_f / total_dps
# end
# 
# gen01_series.sort! {|a,b| b.normalized_dps <=> a.normalized_dps }
# 
# normalized_sum = 0
# gen01_series.each do |series|
#   normalized_sum += series.normalized_dps
#   puts series.filename + " => " + series.normalized_dps.to_s + " => " + normalized_sum.to_s
# end
# 
# exit
# 
# filename = File.join("ga", "gen01", "21f7b3dad64f34ad4027.txt")
# series1 = Series.new(:filename => filename)
#  
# filename = File.join("ga", "gen01", "6a1a5bbdfd48d8e1cbbc.txt")
# series2 = Series.new(:filename => filename)
#  
# series3 = Series.new(:series1 => series1, :series2 => series2)
#  
# puts series3.to_s
# exit


def run_evolution
  dir = File.join("ga","gen02") 
  FileUtils.rm_rf(dir)
  FileUtils.mkdir(dir)

  100.times do
    series = Series.new
    sim = Simulation.new.run do |sim|
      sim.run_mode = :time
      sim.priorities = PriorityFromString.new(sim, series.to_s)
    end
    series.dps = sim.dps
    series.write_to_file(:dir => dir)
    puts series.filename + " => " + sim.dps.to_s
  end

end




def common_chromosomes(left, right)
  return [] if left.empty? or right.empty?

  x, xs, y, ys = left[0..0], left[1..-1], right[0..0], right[1..-1]
  puts "-"*50
  puts x.to_s
  puts y.to_s
  if x == y
    return x + common_chromosomes(xs, ys)
  else
    return [common_chromosomes(left, ys), common_chromosomes(xs, right)].max_by {|x| x.size}
  end
end
