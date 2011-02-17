require "singleton"

class Statistics
  include Singleton

  def initialize
    @hash = Hash.new do |hash,key|
      hash[key] = Hash.new do |hash2, key2|
        hash2[key2] = Hash.new(0)
      end
    end
    
    # :spell_name
    #    :miss
    #      :min, :max, :damage, :count
    #    :hit
    #      :min, :max, :damage, :count
    #    :crit
    #      :min, :max, :damage, :count
    #    :dot
    #      :min, :max, :damage, :count
  end

  def total_damage
    @hash.inject(0) do |sum,(k,v)|
      sum + v.inject(0) do |sum2,(k2,v2)|
        sum2 + v2[:damage]
      end
    end
  end
  
  def log_damage_event(spell, type, damage=0)
    @hash[spell][type][:count] += 1
    @hash[spell][type][:min] = damage if damage < @hash[spell][type][:min] || @hash[spell][type][:min]==0
    @hash[spell][type][:max] = damage if damage > @hash[spell][type][:max]
    @hash[spell][type][:damage] += damage
  end
  
  def output_table(duration)
#    File.open("log.txt", 'w') do |f|
    f = STDOUT
    begin
      f.puts "Duration " + (duration/100).to_s + " seconds"
      f.puts "DPS " + (total_damage/(duration/100)).to_s
      f.puts
      @hash.each do |key, value|
        f.puts key.to_s.gsub(/_/,' ').gsub(/\b([a-z])/){$1.capitalize}.ljust(15)
        f.puts "total swings = " + total_count(value).to_s
        value.each do |key2, value2|
          f.puts "  " + key2.to_s.gsub(/_/,' ').gsub(/\b([a=z])/){$1.capitalize}
          value2.each do |key3, value3|
            f.puts "    " + key3.to_s.ljust(10) + " = " + value3.to_s
          end
          f.puts "    " + "Average".ljust(10) + " = " + (value2[:damage].to_f / value2[:count]).round.to_s
        end
      end
    end
  end

  def total_count(hash)
    hash.inject(0) do |sum, (k,v)|
      sum + v[:count] 
    end
  end
  
  def total_damage_for_spell(hash)
    hash.inject(0) do |sum, (k,v)|
      sum + v[:damage]
    end
  end

end

