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

require_relative "abilities/ability.rb"
Dir["abilities/*.rb"].each {|file| require_relative file}

require_relative "trinkets/trinket.rb"
Dir["trinkets/*.rb"].each {|file| require_relative file}

include Containers

srand Time.now.to_i

mob = Mob.new

player = Player.new(mob)

# TODO add configuration option to break up mastery damage by CS and TV
ConfigParser.parse("config.txt", player, mob)

def run_sim(player, mob)
  Runner.instance.run(player, mob) do 
    if player.heroism.usable?
      player.heroism.use
    end
    
    if player.guardian_of_ancient_kings.usable?
      player.guardian_of_ancient_kings.use
    end

    if player.zealotry.usable?
      player.zealotry.use
    end

    # Cast at 6 seconds or less of inquisition if we have full holy power
    if player.has_holy_power(3) and player.inquisition.buff_remaining <= 0
      player.inquisition.use
      next
    end

    unless player.avenging_wrath.on_cooldown?
      player.use_trinkets
      player.avenging_wrath.use
    end

    # Cast Crusader Strike if we dont have 3 HP
    if player.crusader_strike.usable? and player.holy_power < 3
      player.crusader_strike.use
      next
    end
    
    # Cast at 6 seconds or less of inquisition if we have full holy power
    if player.has_holy_power(3) and player.inquisition.buff_remaining < 6
      player.inquisition.use
      next
    end

    # Cast TV if we can
    if player.has_holy_power(3)
      player.use_trinkets
      player.templars_verdict.use
      next
    end

    if player.hammer_of_wrath.usable?
      player.hammer_of_wrath.use
      next
    end

    if player.exorcism.art_of_war_proc?
      player.exorcism.use
      next
    end

    if player.judgement.usable?
      player.judgement.use
      next
    end

    if player.holy_wrath.usable?
      player.holy_wrath.use
      next
    end

    if player.consecration.usable?
      player.consecration.use
      next
    end
  end
end

def reset_sim(player, mob)
  player.reset_bonuses
  player.reset
  mob.reset
  Statistics.instance.reset
  Runner.instance.reset
end

#run_sim(player, mob)

#temp = Reporting.new(Statistics.instance, Runner.current_time)
#temp.generate_report

#exit

print "Calculating Base DPS... ".ljust(30)
reset_sim(player, mob)
run_sim(player, mob)
baseline_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts baseline_dps.round.to_s

reset_sim(player, mob)
print "Calculating AP DPS... ".ljust(30)
player.bonus_ap = 100
run_sim(player, mob)
ap_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts ap_dps.round.to_s

reset_sim(player, mob)
print "Calculating Str DPS... ".ljust(30)
player.bonus_str = 100
run_sim(player, mob)
str_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts str_dps.round.to_s

#reset_sim(player, mob)
#print "Caulcating Hit DPS... ".ljust(30)
#player.bonus_hit = 100
#run_sim(player, mob)
#hit_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
#puts hit_dps.round.to_s
#
#reset_sim(player, mob)
#print "Calculating Exp DPS... ".ljust(30)
#player.bonus_exp = 100
#run_sim(player, mob)
#exp_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
#puts exp_dps.round.to_s

reset_sim(player, mob)
print "Calculating Mastery DPS... ".ljust(30)
player.bonus_mastery = 100
run_sim(player, mob)
mastery_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts mastery_dps.round.to_s

reset_sim(player, mob)
print "Calculating Crit DPS... ".ljust(30)
player.bonus_crit = 100
run_sim(player, mob)
crit_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts crit_dps.round.to_s

reset_sim(player, mob)
print "Calculating Haste DPS... ".ljust(30)
player.bonus_haste = 100
run_sim(player, mob)
haste_dps = Statistics.instance.total_damage / (Runner.instance.current_time / 1000)
puts haste_dps.round.to_s

