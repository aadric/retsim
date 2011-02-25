require_relative "combatconstants"
require_relative "player"
require_relative "lib/algorithms"
require_relative "event"
require_relative "mob"
require_relative "statistics"

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
duration = hours * 60 * 60 * 1000

# when to show * on progress bar
tick = duration / 80

current_time = 0

def priority(current_time, player, mob)
  if player.crusader_strike.cooldown_remaining(current_time) == 0
    player.crusader_strike.use(current_time)
    return
  end

  if player.exorcism.art_of_war_proc
    player.exorcism.use(current_time)
    return
  end
end

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

queue = PriorityQueue.instance

mob = Mob.new
mob.level = 88

player = Player.new(mob)


config_parser("config.txt", player, mob)



player.swing(current_time)
while current_time < duration
  unless queue.empty?
    event = queue.pop
    
    current_time = event.time
    
    if current_time > tick
      print "*"
      tick += duration / 80
    end

    event.execute
  end

  unless player.is_gcd_locked
    priority(current_time, player, mob)
  end
end

puts ""
player.output_stats
puts ""
Statistics.instance.output_table(duration)
