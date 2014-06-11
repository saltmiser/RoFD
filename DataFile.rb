
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

  class DataFileOfPoints
    def initialize(directory, file_name, column_config_hash)
      @file_path = directory + file_name
      @data_points = []
      @column_config = column_config_hash
    end
    def read_file()
      File.open(@file_path) do |infile|
        skiplines = 0
        while line = infile.gets
          if skiplines < 7
            skiplines = skiplines + 1
          else 
            @data_points << DataPointFromFile.new(line, @column_config)
          end
        end
      end
    end
    def count()
      @data_points.count()
    end
    def to_s()
      "Data File with " + self.count.to_s + " records."
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
