# This is our chromosome
class Entry
  def initialize(opts = {})
    if opts[:string]
      create_from_string(opts[:string])
    else
      create_random_entry
    end
  end

  def create_from_string(str)
    action, conditions = *str.split(" if ")
    @action = Action.new(:string => action)
    @conditions = []
    return if conditions.nil?
    conditions = conditions.split(" and ")
    conditions.each do |condition|
      @conditions << Condition.new(:string => condition) 
    end
  end

  def create_random_entry
    @action = Action.new
    @conditions = []
    if coin_flip
      @conditions << Condition.new
      while random <= 0.1
        @conditions << Condition.new
      end
    end
  end

  def add_random_condition
    @conditions << Condition.new
  end

  def delete_random_condition
    @conditions.delete(@conditions.sample)
  end

  def mutate_random_condition
    @conditions.sample.mutate
  end

  def conditions_empty?
    @conditions.empty?
  end

  def to_s
    s = @action.to_s
    unless @conditions.empty?
      s += " if "
      conditions = @conditions.map {|x| x.to_s}
      s += conditions.inject {|conditions, condition| conditions + " and " + condition}
    end
    return s
  end

  def to_sym
    @action.to_sym
  end
end
