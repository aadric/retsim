class Exorcism

  attr_accessor :art_of_war_proc

  def initialize(player, mob)
    @player = player
    @mob = mob
  end


  def use(current_time)
    # assume we only cast this when a proc is up
    @art_of_war_proc = false
    # TODO clear event that would clear this proc since we just used it

    dmg = random(2591, 2891)
    dmg += @player.calculate_attack_power * 0.34
    dmg *= @player.magic_bonus_multiplier
    talent_multiplier = 1
    talent_multiplier += 0.10 * @player.talent_blazing_light if @player.talent_blazing_light
    talent_multiplier += 1 # assume art of war proc

    dmg *= talent_multiplier




  end

  def proc_art_of_war(current_time)
    @art_of_war_proc = true
    # TODO add event to clear proc if it isn't used in time
  end

end
