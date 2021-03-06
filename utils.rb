class String
  # From Rails
  # Turns "right_eye_of_rajh_346" to "RightEyeOfRajh346"
  def camelize
    self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
end

class Range
  def intersection(other)  
    raise ArgumentError, 'value must be a Range' unless other.kind_of?(Range)  
  
    min, max = first, exclude_end? ? max : last  
    other_min, other_max = other.first, other.exclude_end? ? other.max : other.last  
  
    new_min = self === other_min ? other_min : other === min ? min : nil  
    new_max = self === other_max ? other_max : other === max ? max : nil  
  
    new_min && new_max ? new_min..new_max : nil  
  end  
  
  alias_method :&, :intersection  
end

class Float
  # Probablistic rounding
  # 3.4 is 3 60% of the time and 4 40% of the time.
  def prob_round
    orig = (self * 10).round / 10.to_f
    val = orig.truncate
    val +=1 if rand < orig - orig.truncate
    val 
  end

  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end
end

class Fixnum
  # TODO do we need this?
  def segment(count)
    temp = []
    x = self.divmod(count)
    count.times do |i|
      val = x[0]
      val += 1 if i < x[1]
      temp << val
    end
    temp.reverse
  end
end

class Array
  def random
    sample
  end

  def uniq_by_comparator
    ret = []

    self.each do |var|
      if ret.select { |x| yield x,var }.empty?
        ret << var
      end
    end
    ret
  end

  def uniq_by_comparator!(&block)
    ret = uniq_by_comparator(&block)
    replace ret
  end
end

# returns a number in [min,max]
# if passed with no arguments, returns a floating point in [0,1)
def random(min=0, max=0)
  if(min==0 && max==0)
    rand
  else
    min + rand(1+max-min)
  end
end

# Coin flip, optionally weighted
def coin_flip(v1=1, v2=1)
  raise "Poor argument to coin_flip" if v1<=0 or v2<=0
  weight = v1.to_f / (v1 + v2)
  return random < weight
end
