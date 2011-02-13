require_relative "combatconstants"
require_relative "player"
require_relative "lib/algorithms"
require_relative "event"
require_relative "mob"

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
duration = hours * 360000

# when to show * on progress bar
tick = duration / 80

current_time = 0

def priority(current_time, char, mob)

end

queue = PriorityQueue.instance

mob = Mob.new
mob.level = 88

player = Player.new
player.weapon_speed = 3.6
player.weapon_dmg_low_end = 1795
player.weapon_dmg_high_end = 2693
duration = -1
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
    priority(current_time, char, mob)
  end

  # autoattack
  unless player.is_on_swing_cooldown
    player.swing(current_time, mob)
  end
end

