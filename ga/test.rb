require_relative("condition")
require_relative("action")
require_relative("entry")
require_relative("series")

series = Series.new
random(10,40).times do
  action = Action.new
  conditions = []
  if coin_flip
    conditions << Condition.new
    while random <= 0.1
      conditions << Condition.new
    end
  end
  entry = Entry.new(action, conditions)
  series << entry
end

series.write_to_file
  
exit

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
