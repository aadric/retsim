# This is our chromosome
class Entry
  def initialize(action, conditions = [])
    @action = action
    @conditions = conditions
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
