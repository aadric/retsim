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

class Float
  def prob_round
    orig = (self * 10).round / 10.to_f
    val = orig.truncate
    val +=1 if rand < orig - orig.truncate
    val 
  end
end

class Fixnum
  def segment(count)
    temp = []
    x = self.divmod(count)
    count.times do |i|
      val = x[0]
      val += 1 if i < x[1]
      temp << val
    end
    temp.reverse
  end
end

class String
  # From Rails
  # Turns "right_eye_of_rajh_346" to "RightEyeOfRajh346"
  def camelize
    self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
end

# TODO add configuration option to break up mastery damage by CS and TV
config_parser("config.txt", player, mob)

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

  # Always refresh holy power if not up
  if player.has_holy_power and !player.inquisition.active?
    player.inquisition.use
    next
  end

  # Cast at 6 seconds or less of inquisition if we have full holy power
  if player.holy_power == 3 and player.inquisition.buff_remaining <= 6
    player.inquisition.use
    next
  end

  unless player.avenging_wrath.on_cooldown?
    #player.avenging_wrath.use
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
  if player.crusader_strike.usable?
    player.crusader_strike.use
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

puts ""
player.output_stats
puts ""
Statistics.instance.output_table(Runner.instance.current_time)
