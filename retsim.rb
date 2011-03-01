require_relative "combatconstants"
require_relative "player"
require_relative "lib/algorithms"
require_relative "event"
require_relative "mob"
require_relative "statistics"
require_relative "runner"

Dir["abilities/*.rb"].each {|file| require_relative file}

include Containers

srand Time.now.to_i

# TODO put in config
hours = 20 

# returns a number in [min,max]
# if passed with no arguments, returns a floating point in [0,1)
def random(min=0, max=0)
  if(min==0 && max==0)
    rand
  else
    min + rand(1+max-min)
  end
end

# in miliseconds

# when to show * on progress bar
tick = Runner.instance.fights / 80



def convert_value(value)
  return true if value =~ /^true$/i
  return false if value =~ /^false$/i

  return value.to_i if value =~ /^\d+$/
  return value.to_f if value =~ /^\d*\.\d+$/
  return value[1..-1].to_sym if value =~ /^:\w+$/
  return value.to_sym if value =~ /^\w+$/
  return nil
end

def config_parser(filename, player, mob) 
  obj = nil
  File.foreach(filename) do |line|
    line.strip!
    if(line[0] != "#" and line =~ /\S/)
      # Strip trailing comments
      line.sub!(/#.*$/, "")

      if line =~ /.*=.*/ and !obj.nil?
        i = line.index('=')
        operator = line[0..i-1].strip
        value = line[i+1..-1].strip
        value = convert_value(value)
        obj.send(operator+"=", value)
      else 
        obj = player if line == "++ PLAYER ++"
        obj = mob if line == "++ MOB ++"
      end
    end
  end
end


mob = Mob.new
mob.level = 88

player = Player.new(mob)


config_parser("config.txt", player, mob)

Runner.instance.run(player, mob) do 
  # Always refresh holy power if not up
  if player.has_holy_power and !player.inquisition
    player.cast_inquisition
    next
  end

  # Cast at 6 seconds or less of inquisition if we have full holy power
  if player.holy_power == 3 and player.inquisition_remaining <= 6
    player.cast_inquisition
    next
  end

  # Cast TV is we have a proc
  if player.has_holy_power(3)
    player.templars_verdict.use
    next
  end
  # Cast TV if we have 3 real HP
#  if player.holy_power == 3
#    player.templars_verdict.use(current_time) 
#    return
#  end

  # Cast Crusader Strike if we dont have 3 HP
  if player.crusader_strike.cooldown_remaining == 0
    player.crusader_strike.use
    next
  end

  if !player.hammer_of_wrath.on_cooldown and (player.avenging_wrath or mob.flavor_country?)
    player.hammer_of_wrath.use
    next
  end

  if player.exorcism.art_of_war_proc
    player.exorcism.use
    next
  end

  unless player.holy_wrath.on_cooldown
    player.holy_wrath.use
    next
  end
end

puts ""
player.output_stats
puts ""
Statistics.instance.output_table(Runner.instance.current_time)
