class Inquisition < Ability

  def initialize(player, mob)
    super(player, mob)
    @player.extend(InquisitionBonus)
  end

  def use
    raise "Can't use inquisition without holy power" unless useable?

    if @player.divine_purpose.active?
      @player.divine_purpose.clear_buff
      duration = 12
    else
      duration = 4 * @player.holy_power
      duration *= 1 + 0.5 * @player.talent_inquiry_of_faith if @player.talent_inquiry_of_faith
      @player.holy_power = 0
    end

    buff_expires_in(duration) 

    @player.lock_gcd(:hasted => true)
  end

  def useable?
    @player.has_holy_power
  end

  module InquisitionBonus
    def magic_bonus_multiplier(magic_type = :holy)
      bonus = super(magic_type)
      bonus *= 1.3 if @inquisition.active? and magic_type == :holy
      bonus
    end
  end
end
