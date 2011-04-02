require 'cgi'

class Reporting

  COLORS = %w(FF0000 00FF00 0000FF FFFF00 FF00FF 00FFFF 
              C00000 00C000 0000C0 C0C000 C000C0 00C0C0 
              A00000 00A000 0000A0 A0A000 A000A0 00A0A0 
              E00000 00E000 0000E0 E0E000 E000E0 00E0E0)

  def initialize(sim)
    @sim = sim
    @duration = @sim.runner.current_time
  end

  def generate_report
    File.open("report.html", 'w') do |f|
      f.puts IO.read("reporting/header.html")
      f.puts "<p>"
      f.puts "Duration " + (@duration/1000/60).round.to_s + " minutes<br/>"
      f.puts "DPS " + (@sim.stats.total_damage/(@duration/1000)).round.to_s + "<br/>"
      f.puts "Average Fight Length " + (@sim.stats.fights.inject(&:+).to_f / @sim.stats.fights.size / 60).to_s + "<br/>"
      f.puts "</p>"
      f.puts output_table
      f.puts "<img id=\"pie_breakdown\" src=\""+generate_pie_graph_link+"\"/>"
      f.puts IO.read("reporting/footer.html")
    end
  end


  def generate_pie_graph_link
    params = Array.new

    params << "chs=650x300"
    params << "cht=p"
    params << "chf=bg,s,FFFFFF"
   
    i = 0
    data_points = Array.new
    # create objects for data
    @sim.stats.hash.each do |ability, outcomes_hash|
      data_point = DataPoint.new
      data_point.name = ability.to_s.gsub(/_/,' ').gsub(/\b([a-z])/){$1.capitalize}
      total_damage = 0
      outcomes_hash.each do |outcome, stats_hash| 
        total_damage += stats_hash[:damage]
      end
      data_point.value = total_damage
      #data_point.color = COLORS[i]
      i = i + 1
      data_points << data_point
    end

    data_points.sort! do |x,y|
      y.value <=> x.value
    end

    data_points.each_with_index do |obj, index|
      obj.color = COLORS[index]
    end

    params << "chco=" + data_points.collect(&:color).join("|")
    params << "chd=t:" + data_points.collect(&:value).join(",")
    #params << "chl=" + data_points.collect(&:name).join("|")
    labels = data_points.map do |obj|
      label = obj.name + " (" + (obj.value.to_f / @sim.stats.total_damage * 100).round.to_s + "%)"
      CGI.escape(label)
    end
    params << "chl=" + labels.join("|")
    params << "chds=0," + data_points.collect(&:value).max.to_s
    params << "chma=0,0,20,20"

    return "http://chart.googleapis.com/chart?" + params.join("&")
  end

  def output_table
    s = ""
    @sim.stats.hash.each do |key, value|
      s += "<table class=\"ability_breakdown\" cellspacing=\"0\"><tr>"
      s += "<th class=\"nobg\">" + key.to_s.gsub(/_/,' ').gsub(/\b([a-z])/){$1.capitalize}.ljust(15) + "</th>"
      s += "<th>count</th><th>%</th><th>min</th><th>max</th><th>damage</th><th>average</th></tr>"
      total_count = 0
      total_dmg = 0
      value.each do |key2, value2|
        s += "<tr>"
        s += "<th class=\"spec\">" + key2.to_s.gsub(/_/,' ').gsub(/\b([a=z])/){$1.capitalize} + "</th>"
        s += "<td>" + value2[:count].to_s + "</td>"
        s += "<td>" + '%.3f' % (value2[:count].to_f / @sim.stats.total_count(value)) + "</td>"
        s += "<td>" + value2[:min].to_s + "</td>"
        s += "<td>" + value2[:max].to_s + "</td>"
        s += "<td>" + value2[:damage].to_s + "</td>"
        s += "<td>" + (value2[:damage].to_f / value2[:count]).round.to_s + "</td>"
        s += "</tr>"
        total_count += value2[:count]
        total_dmg += value2[:damage]
      end
      if total_count > 0 and total_dmg > 0
        s += "<tr class=\"total_row\"><th class=\"spec\">total</th><td>"+total_count.to_s+"</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>"
        s += "<td>" + total_dmg.to_s + "</td><td>" + (total_dmg / total_count).to_s + "</td</tr>"
      end
      s += "</table>"
    end
    return s
  end

  class DataPoint
    attr_accessor :name, :value, :color
  end
end
