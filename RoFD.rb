#require_relative 'CycleDetection'

module RoFD
  HEADER_CONST = "Repetition | Rep Start | Rep End | Rep Len |  Force  |  RoFD (dF/dT)\n"

  class Repetition
    include Enumerable
    def initialize
      @cycle_list = []
    end
    def <<(val)
      @cycle_list << val
    end
    def each(&block)
      @cycle_list.each(&block)
    end
    def [](cycle_index)
      return @cycle_list[cycle_index]
    end
  end

  class RofdForCycleList

    def initialize(cycle_list, sanitation_threshold)
      @cycle_list = cycle_list
      sanitize_cycle_list(sanitation_threshold)
      build_repetition_list
      build_console_readable_cycle_list_report_s(:LEFT)
    end
    def build_repetition_list
      1
    end

    # Warning!  This method assumes millisecond values should be handled as integers!
    def build_console_readable_cycle_list_report_s(band_designator)
      iter_count = 0
      @output_s = HEADER_CONST
      begin
        @cycle_list.each { |cycle|
          iter_count += 1
          band_time_start = cycle.get_band(band_designator).get_start_point(:TIME).to_i
          band_time_end = cycle.get_band(band_designator).get_end_point(:TIME).to_i
          band_duration = band_time_end - band_time_start
          band_slope = cycle.get_band(band_designator).get_slope().round(3)
          rofd = (band_slope / band_duration.to_f).round(3)
          @output_s += "\t#{iter_count}\t#{band_time_start}\t#{band_time_end}\t#{band_duration}"
          @output_s += "\t#{band_slope}\t\t#{rofd}\n"
        }
      rescue
        return
      end
    end
    def to_s()
      return @output_s
    end
  
    def write_bands_to_file(write_directory) 
      cycle_count = 0
      begin
        @cycle_list.each { |cycle|
          cycle_count += 1
          cycle.get_band(:LEFT).write_to_file(write_directory + "#{cycle_count}_RISING.txt")
          cycle.get_band(:RIGHT).write_to_file(write_directory + "#{cycle_count}_FALLING.txt")
        }
      rescue
        return cycle_count
      end
    end
    def sanitize_cycle_list(threshold)
      1
    end
  end
end

