class ConfigParser

  # Converts string value to real data type
  def self.convert_value(value)
    return true if value =~ /^true$/i
    return false if value =~ /^false$/i

    return value.to_i if value =~ /^\d+$/
    return value.to_f if value =~ /^\d*\.\d+$/
    return value[1..-1].to_sym if value =~ /^:\w+$/
    return value.to_sym if value =~ /^\w+$/
    return nil
  end

  # Parse a config file and apply values to player and mob
  def self.parse(filename, sim) 
    obj = nil
    File.foreach(filename) do |line|
      line.strip!
      if(line[0] != "#" and line =~ /\S/)
        # Strip trailing comments
        line.sub!(/#.*$/, "")

        if line =~ /.*=.*/ and !obj.nil?
          i = line.index('=')
          operator = line[0..i-1].strip
          value = line[i+1..-1].strip
          value = self.convert_value(value)
          obj.send(operator+"=", value)
        else 
          obj = sim.player if line == "++ PLAYER ++"
          obj = sim.mob if line == "++ MOB ++"
        end
      end
    end
  end

end
