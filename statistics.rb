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
  
  def log_damage(spell, type, damage=0)
    @hash[spell][type][:count] += 1
    @hash[spell][type][:min] = damage if damage < @hash[spell][type][:min] || @hash[spell][type][:min]==0
    @hash[spell][type][:max] = damage if damage > @hash[spell][type][:max]
    @hash[spell][type][:damage] += damage
  end
  
  def output_table(duration)
    File.open("report.html", 'w') do |f|
      f.puts "Duration " + (duration/1000).to_s + " seconds<br/>"
      f.puts "DPS " + (total_damage/(duration/1000)).to_s + "<br/>"
      f.puts
      @hash.each do |key, value|
        f.puts key.to_s.gsub(/_/,' ').gsub(/\b([a-z])/){$1.capitalize}.ljust(15) + "<br/>"
        f.puts "<table><tr>"
        f.puts "<th>&nbsp</th>"
        f.puts "<th>count</th><th>%</th><th>min</th><th>max</th><th>damage</th><th>average</th></tr>"
        total_count = 0
        total_dmg = 0
        value.each do |key2, value2|
          f.puts "<tr>"
          f.puts "<td>" + key2.to_s.gsub(/_/,' ').gsub(/\b([a=z])/){$1.capitalize} + "</td>"
          f.puts "<td>" + value2[:count].to_s + "</td>"
          f.puts "<td>" + '%.3f' % (value2[:count].to_f / total_count(value)) + "</td>"
          f.puts "<td>" + value2[:min].to_s + "</td>"
          f.puts "<td>" + value2[:max].to_s + "</td>"
          f.puts "<td>" + value2[:damage].to_s + "</td>"
          f.puts "<td>" + (value2[:damage].to_f / value2[:count]).round.to_s + "</td>"
          f.puts "</tr>"
          total_count += value2[:count]
          total_dmg += value2[:damage]
        end
        if total_count > 0 and total_dmg > 0
          f.puts "<tr><td>total</td><td>"+total_count.to_s+"</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>"
          f.puts "<td>" + total_dmg.to_s + "</td><td>" + (total_dmg / total_count).to_s + "</td</tr>"
        end
        f.puts "</table>"
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

