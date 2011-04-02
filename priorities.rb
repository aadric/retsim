class Priority
  attr_reader :player
  
  def sim=(sim)
    @sim = sim
    @player = @sim.player
  end
end

class PriorityWithDelay < Priority
  def initialize(delay)
    @delay = delay
  end

  # This is called when the player is not GCD locked
  # This method is responsible for exiting once a GCD is used
  def execute
    if player.has_holy_power(3) and player.inquisition.buff_remaining <= 0
      if player.guardian_of_ancient_kings.usable?
        player.guardian_of_ancient_kings.use
      end
      return player.inquisition.use
    end

    # Cast Crusader Strike if we dont have 3 HP
    if player.crusader_strike.usable? and player.holy_power < 3
      if(player.holy_power == 0 and player.zealotry.usable?)
        player.zealotry.use
        player.heroism.use if player.heroism.usable?
      end
      return player.crusader_strike.use
    end

    # Cast at 6 seconds or less of inquisition if we have full holy power
    if player.has_holy_power(3) and player.inquisition.buff_remaining < 6
      if player.guardian_of_ancient_kings.usable?
        player.guardian_of_ancient_kings.use
      end
      return player.inquisition.use
    end

    # Cast TV if we can
    if player.has_holy_power(3)
      player.use_trinkets
      player.avenging_wrath.use if player.avenging_wrath.usable?
      return player.templars_verdict.use
    end

    if player.hammer_of_wrath.usable?
      return player.hammer_of_wrath.use
    end

    if player.exorcism.art_of_war_proc?
      return player.exorcism.use
    end

    # If Crusader Strike will be up shortly, just wait for it
    if(player.holy_power < 3 and player.crusader_strike.cooldown_remaining <= @delay)
      return
    end

    if player.judgement.usable?
      return player.judgement.use
    end

    if player.holy_wrath.usable?
      return player.holy_wrath.use
    end

    if player.consecration.usable?
      return player.consecration.use
    end
  end
end

class PriorityWithoutDelay < Priority
  # This is called when the player is not GCD locked
  # This method is responsible for exiting once a GCD is used
  def execute
    if player.has_holy_power(3) and player.inquisition.buff_remaining <= 0
      if player.guardian_of_ancient_kings.usable?
        player.guardian_of_ancient_kings.use
      end
      return player.inquisition.use
    end

    # Cast Crusader Strike if we dont have 3 HP
    if player.crusader_strike.usable? and player.holy_power < 3
      if(player.holy_power == 0)
        player.zealotry.use if player.zealotry.usable?
        player.heroism.use if player.heroism.usable?
      end
      return player.crusader_strike.use
    end

    # Cast at 6 seconds or less of inquisition if we have full holy power
    if player.has_holy_power(3) and player.inquisition.buff_remaining < 6
      if player.guardian_of_ancient_kings.usable?
        player.guardian_of_ancient_kings.use
      end
      return player.inquisition.use
    end

    # Cast TV if we can
    if player.has_holy_power(3)
      player.use_trinkets
      player.avenging_wrath.use if player.avenging_wrath.usable?
      return player.templars_verdict.use
    end

    if player.hammer_of_wrath.usable?
      return player.hammer_of_wrath.use
    end

    if player.exorcism.art_of_war_proc?
      return player.exorcism.use
    end

    if player.judgement.usable?
      return player.judgement.use
    end

    if player.holy_wrath.usable?
      return player.holy_wrath.use
    end

    if player.consecration.usable?
      return player.consecration.use
    end
  end
end
