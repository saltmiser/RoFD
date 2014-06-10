
datadir = './data/'

class DataPointFromFile
  def initialize(text_file_line)
    @data_array = text_file_line.split
  end
  def get_columns
    @data_array
  end
  def to_s
    "Data Point with " + get_columns.count.to_s + " columns"
  end 
end
  

datapoints = []

File.open(datadir + 'LHIP 240.txt') do |infile|
  skiplines = 0
  while line = infile.gets
    if skiplines < 7
      skiplines = skiplines + 1
    else 
      datapoints << DataPointFromFile.new(line)
    end
  end
end

puts datapoints[0]
puts "Total rows in data file: " + datapoints.count.to_s


