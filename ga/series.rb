require 'securerandom'
require 'fileutils'

# This is our DNS
class Series
  attr_reader :filename, :entries
  attr_accessor :dps

  def initialize(opts = {})
    @entries = []
    @dps = 0

    if opts[:filename]
      @filename = opts[:filename]
      read_from_file
    else
      generate_random_series
    end
  end

  def <<(x)
    @entries << x
  end

  def each
    @entries.each do |entry|
      yield entry
    end
  end

  def write_to_file(opts = {})
    unless @filename
      dir = opts[:dir] ||= "./"
      filename = opts[:filename] ||= SecureRandom.hex(10) + ".txt"
      #filename = opts[:filename] ||= (self.object_id.to_s.rjust(20,"0") + ".txt")

      @filename = File.join(dir, filename)
    end

    File.open(@filename, 'w') do |f|
      f.puts "# DPS = " + @dps.to_s
      @entries.each do |x|
        f.puts x.to_s
      end
    end
  end

  def to_s
    puts "# DPS = " + @dps.to_s
    @entries.inject("") do |string, entry|
      string += entry.to_s + "\n"
    end
  end

  def clean!
    # Delete all "return" lines if they don't have conditions.
    @entries.delete_if do |entry|
      entry.to_sym == :return and entry.conditions_empty?
    end

    # Delete all non-unique action lines that don't have conditions
    @entries.uniq_by_comparator! do |entry1, entry2|
      entry1.to_sym == entry2.to_sym and entry1.conditions_empty? and entry2.conditions_empty?
    end
  end

  def generate_random_series
    random(10,40).times do
      entry = Entry.new
      @entries << entry
    end
    clean!
  end

  def read_from_file
    File.open(@filename, "r") do |infile|
      while line = infile.gets
        line.chomp!
        next if line.empty?
        if line[0]=="#"
          match = line.match(/# DPS = (\d+)/)
          if match and match[1]
            @dps = match[1].to_i
          end
          next
        end
        @entries << Entry.new(:string => line)
      end
    end
  end

  def self.common_dna(series1, series2)
    @@cache = Hash.new
    self.lcs2(series1.entries, series2.entries)
  end

  def self.lcs(series1, series2)
    return @@cache[[series1.size, series2.size]] unless @@cache[[series1.size, series2.size]].nil?
    return [] if series1.empty? or series2.empty?

    x, xs, y, ys = series1[0].to_sym, series1[1..-1], series2[0].to_sym, series2[1..-1]
    if x == y
      @@cache[[series1.size, series2.size]] = [x] + lcs(xs,ys)
    else
      @@cache[[series1.size, series2.size]] = [self.lcs(series1, ys), self.lcs(xs, series2)].max_by {|x| x.size}
    end
  end

end
