require 'DataFile.rb'

module CycleDetection
  class Band
    def initialize(startPoint)
      @start_point = startPoint
      @end_point = nil
      @slope = nil
    end
  end
  class Cycle
    def initialize(leftBand, rightBand)
      @left_band = leftBand
      @right_band = rightBand
    end
  end
  class CycleList
    def initialize(directory, file_name, column_config_hash)
      @file_path = directory + file_name
      @data_points = []
      @column_config = column_config_hash
    end
  end
end

