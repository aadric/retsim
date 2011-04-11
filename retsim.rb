# gotta be a way to get rid of all this garbage
require_relative "combatconstants"
require_relative "player"
require_relative "lib/algorithms"
require_relative "event"
require_relative "mob"
require_relative "statistics"
require_relative "runner"
require_relative "reporting/reporting"
require_relative "utils"
require_relative "config_parser"
require_relative "simulation.rb"
require_relative "priorities.rb"
require_relative "logger.rb"

require_relative "abilities/ability.rb"
Dir["abilities/*.rb"].each {|file| require_relative file}

require_relative "procs/proc.rb"
Dir["procs/*.rb"].each {|file| require_relative file}

include Containers

srand Time.now.to_i

def calculate_ideal_delay
  delay = 0.0
  while delay <= 2.01
    sim = Simulation.new("config.txt", {}, PriorityWithDelay.new(delay)).run
    temp = Reporting.new(sim)
    temp.generate_report
    puts delay.round_to(2).to_s + " = " + sim.dps.round.to_s
    delay += 0.1
  end
end

def calculate_weights(sim_factory)
  increment = 200

  delay = 0.5
  print "Calculating Base DPS... ".ljust(30)
  baseline_sim = sim_factory.new_sim.run
  puts baseline_sim.dps.round.to_s

  temp = Reporting.new(baseline_sim)
  temp.generate_report

  print "Calculating AP DPS... ".ljust(30)
  sim_ap = sim_factory.new_sim.run do |sim|
    sim.player.augmentations[:attack_power] = increment
  end
  puts "1 (DPS = " + sim_ap.dps.round.to_s+")"
  ap_diff = sim_ap.dps - baseline_sim.dps.to_f

  print "Calculating Crit DPS... ".ljust(30)
  sim = sim_factory.new_sim.run do |sim|
    sim.player.augmentations[:crit_rating] = increment
  end
  puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)

  print "Calculating Haste DPS... ".ljust(30)
  sim = sim_factory.new_sim.run do |sim|
    sim.player.augmentations[:haste_rating] = increment
  end
  puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)

  #print "Calculating Hit DPS... ".ljust(30)
  #sim = Simulation.new("config.txt", {:hit_rating => increment}, PriorityWithDelay.new(delay)).run
  #puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)

  #print "Calculating Exp DPS... ".ljust(30)
  #sim = Simulation.new("config.txt", {:expertise_rating => increment}, PriorityWithDelay.new(delay)).run
  #puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)

  print "Calculating Mastery DPS... ".ljust(30)
  sim = sim_factory.new_sim.run do |sim|
    sim.player.augmentations[:mastery_rating] = increment
  end
  puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)

  print "Calculating Str DPS... ".ljust(30)
  sim = sim_factory.new_sim.run do |sim|
    sim.player.augmentations[:strength] = increment
  end
  puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(4)
end

def calculate_comparison
  sim1 = Simulation.new.run do |sim|
    sim.run_mode = :time
  end

  sim2 = Simulation.new.run do |sim|
    sim.priorities.word_of_glory = true
    sim.player.talent_blazing_light = 1
    sim.run_mode = :time
  end

  Reporting.new(sim1, :sim2 => sim2).generate_report
  Reporting.new(sim2, :file_name => "report2.html").generate_report

  puts sim1.dps.to_s
  puts sim2.dps.to_s
  puts ((sim2.dps - sim1.dps) / sim1.dps.to_f).to_s
end

class SimFactory
  def self.new_sim
    sim2 = Simulation.new do |sim|
      sim.priorities.word_of_glory = true
      sim.player.talent_blazing_light = 1
      sim.run_mode = :time
    end
  end
end

#calculate_weights(SimFactory)
#calculate_ideal_delay
calculate_comparison
exit

delay = 0.5
baseline_sim = Simulation.new("config.txt", {}, PriorityWithDelay.new(delay)).run do |sim|
  sim.run_mode = :time
end
puts baseline_sim.dps.round.to_s

temp = Reporting.new(baseline_sim)
temp.generate_report

