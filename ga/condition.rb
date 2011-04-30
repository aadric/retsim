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
  CONDITIONS << ["mob", "flavor_country?"]

  def initialize(opts = {})
    @enabled = true

    if opts[:string]
      create_from_string(opts[:string])
    else
      create_random_condition
    end
  end

  def create_from_string(str)
    obj_and_method, operator, value = *str.partition(/[<>]/).map {|x| x.strip}
    
    @type = operator.empty? ? :negation : :comparator

    @obj, @method = *obj_and_method.split(".")
    if(@method.nil?)
      @method = @obj
      @obj = ""
    end

    if @type == :comparator
      @operator = operator
      @value = value.to_f
      @min = find_min
      @max = find_max
    else
      @negation = @obj[0]=="!" ? "!" : ""
      @obj = @obj.delete("!")
    end
  end

  def find_min
    obj = @obj.delete("!")
    arr = CONDITIONS.select {|x| x[0] == obj}
    return arr[0][2][:min]
  end

  def find_max
    obj = @obj.delete("!")
    arr = CONDITIONS.select {|x| x[0] == obj}
    return arr[0][2][:max]
  end

  def create_random_condition
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

  def mutate
    case @type
      when :comparator
        value = @value.to_f
        @value = [value/2,value*2,value-0.1,value+0.1].sample
      when :negation
        @negation = @negation=="!" ? "" : "!"
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

  private
    
    def random_value
      random(@min*10,@max*10) / 10.to_f
    end
end
