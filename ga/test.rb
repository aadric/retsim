require_relative("condition")
require_relative("action")
require_relative("entry")
require_relative("series")
require 'fileutils'



filename = File.join("ga", "gen02", "d57192aeb9cb0482c1bb.txt")
series = Series.new(:filename => filename)

filename = File.join("ga", "gen02", "fd1a15d6ee6bed4a9fe4.txt")
series2 = Series.new(:filename => filename)

arr = Series.common_dna(series, series2)

puts arr.to_s

exit


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
