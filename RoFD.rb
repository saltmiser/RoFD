require_relative 'CycleDetection'

module RoFD
  class RofdForCycleList
    HEADER_CONST = "Repetition | Rep Start | Time to Peak |  Force  |  RoFD (dF/dT)\n"
    def initialize(cycle_list, sanitation_threshold)
      @cycle_list = cycle_list
      sanitize_cycle_list(sanitation_threshold)
      build_console_readable_cycle_list_report_s
    end
    def build_console_readable_cycle_list_report_s
      iter_count = 0
      @output_s = HEADER_CONST
      begin
        @cycle_list.each { |cycle|
          iter_count += 1
          left_band_duration = cycle.get_band(:LEFT).get_end_point(:TIME).to_f - cycle.get_band(:LEFT).get_start_point(:TIME).to_f
          left_band_duration = left_band_duration.to_i
          left_band_slope = cycle.get_band(:LEFT).get_slope().to_f.round(3)
          left_band_time_start = cycle.get_band(:LEFT).get_start_point(:TIME)
          left_band_time_start = left_band_time_start.to_i
          rofd = (left_band_slope / left_band_duration.to_f).round(3)
          @output_s += "\t#{iter_count}\t#{left_band_time_start}\t\t#{left_band_duration}"
          @output_s += "\t#{left_band_slope}\t\t#{rofd}\n"
        }
      rescue
        return
      end
    end
    def to_s()
      return @output_s
    end
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

  end
end
