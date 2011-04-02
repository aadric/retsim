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

require_relative "abilities/ability.rb"
Dir["abilities/*.rb"].each {|file| require_relative file}

require_relative "procs/proc.rb"
Dir["procs/*.rb"].each {|file| require_relative file}

include Containers

srand Time.now.to_i

def calculate_ideal_delay
  delay = 0.0
  while delay < 1.5
    sim = Simulation.new("config.txt", {}, PriorityWithDelay.new(delay)).run
    temp = Reporting.new(sim)
    temp.generate_report
    puts delay.round_to(2).to_s + " = " + sim.dps.round.to_s
    delay += 0.1
  end
end

def calculate_weights
  increment = 200

  delay = 0.2
  print "Calculating Base DPS... ".ljust(30)
  baseline_sim = Simulation.new("config.txt", {}, PriorityWithDelay.new(delay)).run
  puts baseline_sim.dps.round.to_s

  temp = Reporting.new(baseline_sim)
  temp.generate_report

  print "Calculating AP DPS... ".ljust(30)
  sim_ap = Simulation.new("config.txt", {:attack_power => increment}, PriorityWithDelay.new(delay)).run
  puts "1"

  ap_diff = sim_ap.dps - baseline_sim.dps.to_f

  print "Calculating Str DPS... ".ljust(30)
  sim = Simulation.new("config.txt", {:strength => increment}, PriorityWithDelay.new(delay)).run
  puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)

  print "Calculating Hit DPS... ".ljust(30)
  sim = Simulation.new("config.txt", {:hit_rating => increment}, PriorityWithDelay.new(delay)).run
  puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)

  print "Calculating Exp DPS... ".ljust(30)
  sim = Simulation.new("config.txt", {:expertise_rating => increment}, PriorityWithDelay.new(delay)).run
  puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)

  print "Calculating Mastery DPS... ".ljust(30)
  sim = Simulation.new("config.txt", {:mastery_rating => increment}, PriorityWithDelay.new(delay)).run
  puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)

  print "Calculating Crit DPS... ".ljust(30)
  sim = Simulation.new("config.txt", {:crit_rating => increment}, PriorityWithDelay.new(delay)).run
  puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)

  print "Calculating Haste DPS... ".ljust(30)
  sim = Simulation.new("config.txt", {:haste_rating => increment}, PriorityWithDelay.new(delay)).run
  puts ((sim.dps-baseline_sim.dps) / ap_diff).round_to(2)
end

#calculate_weights
calculate_ideal_delay
