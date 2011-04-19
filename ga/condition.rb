class Condition

  CONDITIONS = []
  CONDITIONS << ["inquisition", "buff_remaining", {:type => :comparator, :max => 40}]
  CONDITIONS << ["","holy_power", {:type => :comparator, :max => 3}] 
  CONDITIONS << ["guardian_of_ancient_kings", "cooldown_remaining", {:type => :comparator, :max => 300}]
  CONDITIONS << ["guardian_of_ancient_kings", "buff_remaining", {:type => :comparator, :max => 30}]
  CONDITIONS << ["heroism", "cooldown_remaining", {:type => :comparator, :max => 600}]
  CONDITIONS << ["heroism", "buff_remaining", {:type => :comparator, :max => 45}]
  CONDITIONS << ["crusader_strike", "cooldown_remaining", {:type => :comparator, :max => 4}]
  CONDITIONS << ["zealotry", "cooldown_remaining", {:type => :comparator, :max => 120}]
  CONDITIONS << ["zealotry", "buff_remaining", {:type => :comparator, :max => 20}]
  CONDITIONS << ["divine_purpose", "active?"]
  CONDITIONS << ["runner", "time_left", {:type => :comparator, :max => Runner::FIGHT_LENGTH}]
  CONDITIONS << ["avenging_wrath", "cooldown_remaining", {:type => :comparator, :max => 180}]
  CONDITIONS << ["avenging_wrath", "buff_remaining", {:type => :comparator, :max => 20}]
  CONDITIONS << ["mob", "flavour_country?"]

  def initialize
    @obj, @method, opts = *CONDITIONS.random

    opts ||= {}

    @type = opts[:type] ||= :negation

    raise "bad type" unless [:negation, :comparator].include?(@type)

    if @type == :comparator
      @min = opts[:min] ||= 0
      @max = opts[:max] ||= 99999
      @value = random_value
      @operator = coin_flip ? "<" : ">"
    else
      @negation = coin_flip ? "!" : ""
    end
  end

  def to_s
    s = @method
    s = @obj + "." + s unless @obj.empty?
    if @type == :comparator
      s += " " + @operator + " " + @value.to_s
    else
      s = @negation + s 
    end
  end

  def to_sym
    s = @method
    s = @obj + "_" + s unless @obj.empty?
    s.to_sym
  end

  def scramble
    if @type == :comparator
      @value = random_value
      @operator = coin_flip ? "<" : ">"
    else
      @negation = coin_flip ? "!" : ""
    end
  end

  def mutate
    if @type == :comparator
      if coin_flip
        @operator = @operator=="<" ? ">" : "<"
      else
        @value = random_value
      end
    else
      @negation = @negation=="!" ? "" : "!"
    end
  end

  private
    
    def random_value
      random(@min*10,@max*10) / 10.to_f
    end
end
