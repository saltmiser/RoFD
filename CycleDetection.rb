require_relative 'DataFile'
include DataFile

module CycleDetection
  INDEPENDENT_VAR = :TIME

  class Band
    def initialize(startPoint, for_column)
      @start_point = startPoint; @column = for_column
      @containing_points = [] # The full collection of points contained within the band.  
      # Null initializations
      @end_point = nil; @d_len = nil; @i_len = nil
    end
    def calculate_slope()
      @slope = @end_point[@column].to_f - @start_point[@column].to_f
    end
    def calculate_independent_var_length()
      # Note that this distance function only uses the INDEPENDENT_VAR channel
      # in order to calculate a length.  This is not a legitimate point
      # distance function.  
      @i_len = @end_point[INDEPENDENT_VAR].to_f - @start_point[INDEPENDENT_VAR].to_f
    end
    def calculate_dependent_var_length()
      @d_len = @end_point[@column].to_f - @start_point[@column].to_f
    end
    def set_end_point(endPoint)
      @end_point = endPoint
      self.calculate_slope()
      self.calculate_independent_var_length()
      self.calculate_dependent_var_length()
    end
    def get_slope()
      return @slope
    end
    def get_coordinates_s()
      return "From (#{@start_point.get_value(INDEPENDENT_VAR)}, #{@start_point.get_value(@column)}) to (#{@end_point.get_value(INDEPENDENT_VAR)}, #{@end_point.get_value(@column)})."
    end
    def get_distances_s
      return "\t#{INDEPENDENT_VAR} distance is #{@i_len}\n\t#{@column} distance is #{@d_len}."
    end
    def get_start_point(dimension)
      return @start_point[dimension]
    end
    def get_end_point(dimension)
      return @end_point[dimension]
    end
    def count
      return @containing_points.count
    end
    def to_s()
      return get_coordinates_s + "\n" + get_distances_s
    end
    def append_point(data_point)
      @containing_points << data_point
    end 
    def write_to_file(file_name)
      output_file = File.new(file_name, "w")
      @containing_points.each { |point|
        output_file.syswrite("#{point[:TIME]}\t#{point[:TORQUE]}\n")
      }
      output_file.close
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
        if @left_band != nil
          return @left_band.get_slope()
        else
          return nil
        end
      when :RIGHT
        if @right_band != nil
          return @right_band.get_slope()
        else
          return nil
        end
      else
        puts "Invalid band_Designator #{band_designator}"
      end
    end
    def get_slope_around_percentage(band_designator, percentage, filter)
      
    end
  end
  class CycleList
    include Enumerable
    def initialize(directory, file_name, column_config, inspect_column)
      @data_points = DataFileOfPoints.new(directory, file_name, column_config)
      self.initialize_cycle_list(inspect_column)
      self.find_average_slopes()
    end
    def <<(val)
      @cycle_list << val
    end
    def each(&block)
      @cycle_list.each(&block)
    end
    def initialize_band_list(for_column)
      band_list = []
      current_band = nil
      last_point = nil
      increasing_slope = @data_points[1][for_column] > @data_points[0][for_column] 
      current_point = 0
      @data_points.each { |dp| 
        if last_point == nil
          puts "We are seeing the first point: #{current_point}"
          puts "Our initial slope is: #{increasing_slope}"
          puts dp.to_s(:TIME, :TORQUE)
          current_band = Band.new(dp, for_column)
          current_point += 1
          last_point = dp
          next
        elsif increasing_slope && dp[for_column].to_f < last_point[for_column].to_f
          increasing_slope = false
          puts "Slope is now false starting with point: #{current_point}"
          puts dp.to_s(:TIME, :TORQUE)
          puts "Last point was: "
          puts last_point.to_s(:TIME, :TORQUE)
          current_band.set_end_point(last_point)
          # An open question is whether or not we need to clone the 
          # currentBand object before appending it to the bandList
          band_list << current_band
          current_band = Band.new(dp, for_column)
        elsif !increasing_slope && dp[for_column].to_f > last_point[for_column].to_f
          increasing_slope = true
          puts "Slope is now true starting with point: #{current_point}"
          puts dp.to_s(:TIME, :TORQUE)
          puts "Last point was: "
          puts last_point.to_s(:TIME, :TORQUE)
          current_band.set_end_point(last_point)
          band_list << current_band # Do we need to clone() currentBand?
          current_band = Band.new(dp, for_column)
        end
        current_point += 1
        current_band.append_point(dp)
        last_point = dp
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
    def find_average_slopes()
      @average_slopes = {:LEFT => 0.0, :RIGHT => 0.0}
      skip_bands = 0
      @cycle_list.each { |cycle|
        if cycle.get_slope(:LEFT) != nil && cycle.get_slope(:RIGHT) != nil
          @average_slopes[:LEFT] += cycle.get_slope(:LEFT)
          @average_slopes[:RIGHT] += cycle.get_slope(:RIGHT)
        else
          skip_bands += 1
        end
      }
      @cycle_list.first.get_band_designators.each { |band|
        @average_slopes[band] /= (@cycle_list.count - skip_bands)
      }
    end
    def [](cycle_index)
      return @cycle_list[cycle_index]
    end
    def get_average_slope(band_designator)
      return @average_slopes[band_designator]
    end
    def count()
      return @cycle_list.count
    end
    def puts_slope_list()
      cycle_no = 0
      @cycle_list.each { |cycle|
        if cycle.get_slope(:LEFT) != nil && cycle.get_slope(:RIGHT) != nil
          cycle_no += 1
          puts "Cycle #{cycle_no} :LEFT band slope: #{cycle.get_slope(:LEFT)}"
          puts "\t#{cycle.get_band(:LEFT)}" 
          puts "Cycle #{cycle_no} :RIGHT band slope: #{cycle.get_slope(:RIGHT)}"
          puts "\t#{cycle.get_band(:RIGHT)}"
        end
      }
      return cycle_no
    end
  end
end

