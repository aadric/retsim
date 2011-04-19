class Action
  ACTIONS = :inquisition, :crusader_strike, :guardian_of_ancient_kings, :use_trinkets, :avenging_wrath,
            :heroism, :zealotry, :templars_verdict, :exorcism, :hammer_of_wrath, :judgement, :holy_wrath,
            :consecration, :return
  def initialize
    @key = ACTIONS.random
  end

  def to_s
    s = @key.to_s
    s += ".attempt" unless [:return, :use_trinkets].include?(@key)
    s
  end

  def to_sym
    @key
  end
end
