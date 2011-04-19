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
