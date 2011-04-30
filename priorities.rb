class Priority
  def initialize(sim, opts = {})
    @sim = sim
  end
  
  def method_missing(method, *args, &block)
    if @sim.player.respond_to?(method.to_s)
      @sim.player.send(method.to_s, *args)
    else
      super
    end
  end

  def runner
    @sim.runner
  end

  def mob
    @sim.mob
  end
end

class PriorityFromString < Priority
  def initialize(sim, priority_string)
    super(sim)
    @priority_string = priority_string
  end

  def execute
    eval(@priority_string)
  end
end

class PriorityFromFile < Priority
  def initialize(sim, filename)
    super(sim)
    @priority_string = IO.read(filename)
  end

  def execute
    eval(@priority_string)
  end
end

class PriorityFromGA < Priority
  
  def execute
    guardian_of_ancient_kings.attempt if inquisition.buff_remaining < 0.1
    inquisition.attempt if inquisition.buff_remaining < 0.1
    crusader_strike.attempt if holy_power < 3.0
    exorcism.attempt
    guardian_of_ancient_kings.attempt
    use_trinkets if holy_power > 2.0 and !mob.flavor_country? and mob.flavor_country? and !divine_purpose.active? and zealotry.cooldown_remaining < 84.2
    avenging_wrath.attempt if holy_power > 2.0
    use_trinkets if divine_purpose.active? and zealotry.buff_remaining > 19.7
    heroism.attempt if zealotry.cooldown_remaining < 0.1 and holy_power > 2.0
    avenging_wrath.attempt if heroism.cooldown_remaining > 387.4 and heroism.buff_remaining > 13.9
    avenging_wrath.attempt
    zealotry.attempt if holy_power > 2.0
    use_trinkets
    hammer_of_wrath.attempt if avenging_wrath.buff_remaining < 12.0
    heroism.attempt if !divine_purpose.active?
    templars_verdict.attempt if divine_purpose.active?
    templars_verdict.attempt if holy_power > 2.1
    return if crusader_strike.cooldown_remaining < 0.4
    hammer_of_wrath.attempt
    return if crusader_strike.cooldown_remaining < 0.6
    judgement.attempt
    holy_wrath.attempt
    consecration.attempt
    zealotry.attempt
  end
end


class PriorityWithT11Inq < Priority

  def initialize(sim, opts = {})
    super(sim)
    @delay = opts[:delay] ||= 0.5
    @consecrate = opts[:consecrate].nil? ? true : opts[:consecrate]
  end

  # This is called when the player is not GCD locked
  # This method is responsible for exiting once a GCD is used
  def execute
    if inquisition.buff_remaining == 0
      guardian_of_ancient_kings.attempt
      inquisition.attempt
    end

    # Cast Crusader Strike if we dont have 3 HP
    if holy_power < 3
      crusader_strike.attempt
    end

    # If I have less than 3 seconds of Inquisition left, refresh regardless
    # of current level of holy power
    if inquisition.buff_remaining < 3
      guardian_of_ancient_kings.attempt
      inquisition.attempt
    end

    # Cast TV if we can
    if has_holy_power(3)
      use_trinkets
      avenging_wrath.attempt 
      if(zealotry.usable?)
        zealotry.attempt
        heroism.attempt
      end
      templars_verdict.attempt
    end

    # If Crusader Strike will be up shortly, just wait for it
    return if crusader_strike.cooldown_remaining <= 0.1

    exorcism.attempt
    hammer_of_wrath.attempt 

    # If Crusader Strike will be up shortly, just wait for it
    return if crusader_strike.cooldown_remaining <= @delay

    judgement.attempt 
    holy_wrath.attempt
    consecration.attempt if @consecrate
  end
end
