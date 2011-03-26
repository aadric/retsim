require "singleton"

class Statistics
  attr_reader :hash
  attr_accessor :fights

  include Singleton

  def initialize
    @fights = []

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

  def reset
    initialize
  end

  def total_damage
    @hash.inject(0) do |sum,(k,v)|
      sum + v.inject(0) do |sum2,(k2,v2)|
        sum2 + v2[:damage]
      end
    end
  end
  
  def log_damage(spell, type, damage=0)
    @hash[spell][type][:count] += 1
    @hash[spell][type][:min] = damage if damage < @hash[spell][type][:min] || @hash[spell][type][:min]==0
    @hash[spell][type][:max] = damage if damage > @hash[spell][type][:max]
    @hash[spell][type][:damage] += damage
  end
  
  def total_count(hash)
    hash.inject(0) do |sum, (k,v)|
      sum + v[:count] 
    end
  end


end

