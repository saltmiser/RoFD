
datadir = './data/'

column_config_hash = {:TIME => 0, :TORQUE => 1, :POSITION => 2, :OTHERPOS => 3, :VELOCITY_DEGpSEC => 4}


class DataPointFromFile
  def initialize(text_file_line, column_config_hash)
    @data_array = text_file_line.split
    @column_config = column_config_hash
  end
  def get_columns
    @data_array
  end
  def to_s
    "Data Point with " + get_columns.count.to_s + " columns"
  end
  def get(whichColumn)
    @data_array[whichColumn]
  end
end
  

datapoints = []

File.open(datadir + 'LHIP 240.txt') do |infile|
  skiplines = 0
  while line = infile.gets
    if skiplines < 7
      skiplines = skiplines + 1
    else 
      datapoints << DataPointFromFile.new(line, column_config_hash)
    end
  end
end

puts datapoints[0]
puts "Total rows in data file: " + datapoints.count.to_s
datapoints

