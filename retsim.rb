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

require_relative "abilities/ability.rb"
Dir["abilities/*.rb"].each {|file| require_relative file}

require_relative "procs/proc.rb"
Dir["procs/*.rb"].each {|file| require_relative file}

include Containers

srand Time.now.to_i

class Priority1
  def next_attack

  end
end

sim1 = sim2 = nil

t1 = Thread.new {
  sim1 = Simulation.new("config.txt", {}, Priority1)
  sim1.run
}

t2 = Thread.new {
  sim2 = Simulation.new("config.txt", {}, Priority1)
  sim2.run
}

t1.join
t2.join

temp = Reporting.new(sim1)
temp.generate_report
exit
#def reset_sim(player, mob)
#  player.reset_bonuses
#  player.reset
#  mob.reset
#  Statistics.instance.reset
#  Runner.instance.reset
#end

#run_sim(player, mob)


#exit

increment = 200

print "Calculating Base DPS... ".ljust(30)
reset_sim(player, mob)
run_sim(player, mob)
baseline_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts baseline_dps.round.to_s

temp = Reporting.new(Statistics.instance, Runner.current_time)
temp.generate_report
reset_sim(player, mob)

#exit

print "Calculating AP DPS... ".ljust(30)
player.bonus_ap = increment
run_sim(player, mob)
ap_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts "1"

ap_diff = ap_dps - baseline_dps

reset_sim(player, mob)
print "Calculating Str DPS... ".ljust(30)
player.bonus_str = increment
run_sim(player, mob)
str_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts ((str_dps-baseline_dps) / ap_diff).round_to(2)

#reset_sim(player, mob)
#print "Caulcating Hit DPS... ".ljust(30)
#player.bonus_hit = increment
#run_sim(player, mob)
#hit_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
#puts hit_dps.round.to_s
#
#reset_sim(player, mob)
#print "Calculating Exp DPS... ".ljust(30)
#player.bonus_exp = increment
#run_sim(player, mob)
#exp_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
#puts exp_dps.round.to_s

reset_sim(player, mob)
print "Calculating Mastery DPS... ".ljust(30)
player.bonus_mastery = increment
run_sim(player, mob)
mastery_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts ((mastery_dps - baseline_dps) / ap_diff).round_to(2)

reset_sim(player, mob)
print "Calculating Crit DPS... ".ljust(30)
player.bonus_crit = increment
run_sim(player, mob)
crit_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts ((crit_dps - baseline_dps) / ap_diff).round_to(2)

reset_sim(player, mob)
print "Calculating Haste DPS... ".ljust(30)
player.bonus_haste = increment
run_sim(player, mob)
haste_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts ((haste_dps - baseline_dps) / ap_diff).round_to(2)

