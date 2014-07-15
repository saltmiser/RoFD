require 'DataFile.rb'
include DataFile

module CycleDetection
  class Band
    def initialize(startPoint, for_column)
      @start_point = startPoint
      @end_point = nil
      @slope = nil
      @column = for_column
    end
    def calculate_slope()
      @slope = @end_point[@column].to_f - @start_point[@column].to_f
    end
    def set_end_point(endPoint)
      @end_point = endPoint
      calculate_slope()
    end
    def get_slope()
      return @slope
    end
  end
  class Cycle
    def initialize()
      @left_band = nil
      @right_band = nil 
    end
    def get_band_designators()
      return [:LEFT, :RIGHT]
    end
    def get_band(band_designator)
      case band_designator
      when :LEFT
        return @left_band
      when :RIGHT
        return @right_band
      else
        puts "Invalid band_designator #{band_designator}"
        return nil
      end
    end
    def set_band(band_designator, band)
      case band_designator
      when :LEFT
        @left_band = band
      when :RIGHT
        @right_band = band
      else
        puts "Invalid band_designator #{band_designator}"
      end
    end
    def get_slope(band_designator)
      case band_designator
      when :LEFT
        return @left_band.get_slope()
      when :RIGHT
        return @right_band.get_slope()
      else
        puts "Invalid band_Designator #{band_designator}"
      end
    end
  end
  class CycleList
    def initialize(directory, file_name, column_config, inspect_column)
      @data_points = DataFileOfPoints.new(directory, file_name, column_config)
      self.initialize_cycle_list(inspect_column)
    end
    def initialize_band_list(for_column)
      band_list = []
      current_band = nil
      last_point = nil
      increasing_slope = true
      @data_points.each { |dp| 
        if last_point == nil
          last_point = dp
        elsif increasing_slope && dp[for_column] < last_point[for_column]
          increasing_slope = false
          current_band.set_end_point(last_point)
          # An open question is whether or not we need to clone the 
          # currentBand object before appending it to the bandList
          band_list << current_band
        elsif !increasing_slope && dp[for_column] > last_point[for_column]
          increasing_slope = true
          current_band.set_end_point(last_point)
          band_list << current_band # Do we need to clone() currentBand?
        else
          next # There has been no slope change; continue iteration...
        end
        current_band = Band.new(dp, for_column)
      }
      return band_list
    end
    def initialize_cycle_list(for_column)
      @cycle_list = [Cycle.new()]
      initialize_band_list(for_column).each { |band|
          if @cycle_list.last.get_band(:LEFT) == nil
            @cycle_list.last.set_band(:LEFT, band)
          else
            @cycle_list.last.set_band(:RIGHT, band)
            @cycle_list << Cycle.new()
          end
      }
    end
  end
end

