
module DataFile
  # Configuration Hash sample.  The programmer will need to provide 
  # meta-data for DataFileOfPoints objects.  
  DEMO_COLUMN_CONFIG_HASHES = 
    {:ONLY_ONE_SO_FAR => 
      {:TIME => 0, 
       :TORQUE => 1, 
       :POSITION => 2, 
       :OTHERPOS => 3, 
       :VELOCITY_DEGpSEC => 4},
    }
  COLUMN_NOUN = "channels"

  # A DataPointFromFile is simply a record.  A record initially remembers 
  # the raw data with which it was instantiated, and it also remembers 
  # a column_config_hash, which will identify units or labels for each entry
  # in a record.  
  #
  # Moving on, a powerful method named get_hash_of_record blends the two
  # instantiated datums together in order to provide one hash which maps 
  # units to values.
  class DataPointFromFile
    def initialize(text_file_line, column_config_hash)
      @data_array = text_file_line.split
      @column_config = column_config_hash
    end
    def get_hash_of_record
      returned_map = @column_config.clone()
      returned_map.each_key { |k| 
        returned_map[k] = @data_array[returned_map[k]]
      }
      return returned_map
    end
    def get_value(column_hash_name)
      return @data_array[@column_config[column_hash_name]]
    end
    def to_s(*args)
      str_build = "Data Point Values: "
      str_len_before = str_build.length
      args.each { |arg|
        str_build += "\n\tKey #{arg}, Value #{self.get_value(arg)}"
      }
      if str_len_before == str_build.length
        return "Data Point has #{@data_array.count} #{COLUMN_NOUN}" 
      end
      return str_build
    end
    def [](column_hash_name)
      return get_value(column_hash_name)
    end
    def get_column_config()
      return @column_config
    end
  end

  # A DataFileOfPoints is an Array of DataPointFromFile objects.  
  # Upon object instantiation, the referenced data file is parsed and
  # the DataPointFromFile objects are instantiated.   
  class DataFileOfPoints
    include Enumerable
    def initialize(directory, file_name, column_config_hash)
      @file_path = directory + file_name
      @data_points = []
      @column_config = column_config_hash
      self.read_file()
    end
    def read_file()
      File.open(@file_path) do |infile|
        skiplines = 0
        while line = infile.gets
          if skiplines < 6
            skiplines += 1
          else 
            @data_points << DataPointFromFile.new(line, @column_config)
          end
        end
      end
    end
    def <<(val)
      @data_points << val
    end
    def each(&block)
      @data_points.each(&block)
    end
    def count()
      return @data_points.count()
    end
    def to_s()
      return "Data File with " + self.count.to_s + " records."
    end 
    def [](array_index)
      return @data_points[array_index]
    end
    # These next two functions will cause the DataFileOfPoints class to 
    # behave like an Array -- we will be able to append and iterate over
    # the object using standard Ruby iteration techniques.  
    def <<(value)
      @data_points << value
    end
    def each(&block)
      @data_points.each(&block)
    end
  end

  def DataFile.tester
    datadir = './data/'
    justOneFile = 'LHIP 240.txt'
    config = DEMO_COLUMN_CONFIG_HASHES[:ONLY_ONE_SO_FAR]
    dataFromFile = DataFileOfPoints.new(datadir, justOneFile, config)
    dataFromFile.read_file()
    puts dataFromFile
  end
end
