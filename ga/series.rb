require 'securerandom'
require 'fileutils'

# This is our DNA
class Series
  attr_reader :filename, :entries, :lineage
  attr_accessor :dps, :normalized_dps, :normalized_sum

  def initialize(opts = {})
    @entries = []
    @dps = 0
    @lineage = []

    if opts[:filename]
      @filename = opts[:filename]
      read_from_file
    elsif opts[:series1] and opts[:series2]
      combine_series(opts[:series1], opts[:series2])
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

  def mutate(opts = {})
    mutation = [:insert_entry, :delete_entry, :insert_condition, :delete_condition, :mutate_condition, :swap_actions].sample
    @lineage << mutation.to_s
    self.send(mutation.to_s)
    clean!
  end
  
  def insert_entry
    entry = Entry.new
    @entries.insert(random(0,@entries.size), entry)
  end

  def delete_entry
    @entries.delete_at(random(0,@entries.size-1))
  end

  def insert_condition
    entry = @entries.sample
    entry.add_random_condition
  end

  def delete_condition
    entry = @entries.select{|x| !x.conditions_empty?}.sample
    entry.delete_random_condition unless entry.nil?
  end

  def mutate_condition
    entry = @entries.select{|x| !x.conditions_empty?}.sample
    entry.mutate_random_condition unless entry.nil?
  end

  def swap_actions
    index = random(0, @entries.size-2)
    @entries[index], @entries[index+1] = @entries[index+1], @entries[index]
  end

  def survive
    @lineage << @filename
  end

  def write_to_file(opts = {})
    dir = opts[:dir] ||= "."
    #unless @filename 
      filename = opts[:filename] ||= SecureRandom.hex(10) + ".txt"
      #filename = opts[:filename] ||= (self.object_id.to_s.rjust(20,"0") + ".txt")

      @filename = File.join(dir, filename)
    #end

    if File.dirname(@filename) != dir
      @filename = File.join(dir, File.basename(@filename))
    end

    File.open(@filename, 'w') do |f|
      f.puts "# DPS = " + @dps.to_s
      unless @lineage.empty?
        f.print "# Lineage:"
        @lineage.each {|x| f.print " " + x}
        f.puts ""
      end
      @entries.each do |x|
        f.puts x.to_s
      end
    end
  end

  def to_s
    string = "# DPS = " + @dps.to_s + "\n"
    unless @lineage.empty?
      string += "# Lineage:"
      @lineage.each {|x| string+= " " + x}
      string += "\n"
    end
    string += @entries.inject("") do |s, entry|
      s += entry.to_s + "\n"
    end
    return string
  end

  def clean!
    # Delete all "return" lines if they don't have conditions.
    @entries.delete_if do |entry|
      entry.to_sym == :return and entry.conditions_empty?
    end

    # Delete all non-unique action lines that don't have conditions
    @entries.uniq_by_comparator! do |entry1, entry2|
      entry1.to_sym == entry2.to_sym and entry1.conditions_empty? and entry2.to_sym != :hammer_of_wrath
      # Note that its possible for hammer of wrath to become active after an avenging wrath, because
      # avenging wrath is off the GCD. This is the only ability this applies to
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
    clean!
  end

  def combine_series(series1, series2)
    left, right = [series1.entries, series2.entries].sample(2)
    @entries = []

    left.first(random(1,left.size-1)).each do |entry|
      @entries << Marshal.load(Marshal.dump(entry))
    end

    right.last(random(1,right.size-1)).each do |entry|
      @entries << Marshal.load(Marshal.dump(entry))
    end
    clean!
    @dps = 0
    @lineage << series1.filename
    @lineage << series2.filename
  end

  def combine_series2(series1, series2)
    common_series = Series.common_dna(series1, series2)
    @entries = []
    left_entries = Marshal.load(Marshal.dump(series1.entries))
    right_entries = Marshal.load(Marshal.dump(series2.entries))
    common_series.each do |action|
      # Pick which series gets priority for this iteration
      priority = coin_flip(series1.dps, series2.dps) # true is series1, false is series2
      
      until (entry = left_entries.shift).to_sym == action
        @entries << entry if priority
      end
      @entries << entry if priority

      until (entry = right_entries.shift).to_sym == action
        @entries << entry unless priority
      end
      @entries << entry unless priority
    end
    # One last flip to see who gets the last segment
    priority = coin_flip(series1.dps, series2.dps)
    while entry = left_entries.shift
      @entries << entry if priority
    end
    while entry = right_entries.shift
      @entries << entry unless priority
    end

    clean!
    @dps = 0
    @lineage << series1.filename
    @lineage << series2.filename
  end

  def self.common_dna(series1, series2)
    @@cache = Hash.new
    self.lcs(series1.entries, series2.entries)
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
