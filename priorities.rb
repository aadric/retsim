class Priority
  attr_reader :player
  
  def sim=(sim)
    @sim = sim
    @player = @sim.player
  end
end

class PriorityWithT11Inq < Priority

  def initialize(opts = {})
    @delay = opts[:delay] ||= 0.5
    @hammer_of_wrath_first = opts[:how_first] ||= false
    @exo_first = opts[:exo_first] ||= false
  end

  # This is called when the player is not GCD locked
  # This method is responsible for exiting once a GCD is used
  def execute
    if player.has_holy_power and player.inquisition.buff_remaining == 0
      player.guardian_of_ancient_kings.use if player.guardian_of_ancient_kings.usable?
      return player.inquisition.use
    end

    # Cast Crusader Strike if we dont have 3 HP
    if player.crusader_strike.usable? and player.holy_power < 3
      return player.crusader_strike.use
    end

    # If I have less than 3 seconds of Inquisition left, refresh regardless
    # of current level of holy power
    if player.has_holy_power and player.inquisition.buff_remaining < 3
      player.guardian_of_ancient_kings.use if player.guardian_of_ancient_kings.usable?
      return player.inquisition.use
    end
  

    # Cast TV if we can
    if player.has_holy_power(3)
      player.use_trinkets
      player.avenging_wrath.use if player.avenging_wrath.usable?
      if(player.zealotry.usable?)
        player.zealotry.use
        player.heroism.use if player.heroism.usable?
      end
      return player.templars_verdict.use
    end

    # If Crusader Strike will be up shortly, just wait for it
    return if player.crusader_strike.cooldown_remaining <= 0.1

    return player.exorcism.use if player.exorcism.art_of_war_proc? and @exo_first

    return player.hammer_of_wrath.use if player.hammer_of_wrath.usable?

    return player.exorcism.use if player.exorcism.art_of_war_proc?

    # If Crusader Strike will be up shortly, just wait for it
    return if player.crusader_strike.cooldown_remaining <= @delay

    return player.judgement.use if player.judgement.usable?

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
