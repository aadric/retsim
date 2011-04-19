# This is our DNS
class Series
  attr_accessor :dps
  def initialize
    @entries = []
    @dps = 0
  end

  def <<(x)
    @entries << x
  end

  def write_to_file(opts = {})
    dir = opts[:dir] ||= ".\\"
    filename = opts[:filename] ||= (self.object_id.to_s.rjust(20,"0") + ".txt")

    File.open(filename, 'w') do |f|
      @entries.each do |x|
        f.puts x.to_s
      end
    end
  end

  def to_s
    @entries.inject("") do |string, entry|
      string += entry.to_s + "\n"
    end
  end
    
end
