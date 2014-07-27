require_relative 'CycleDetection'

module RoFD
  class RofdPrinter
    def initialize(cycle_list)
      @cycle_list = cycle_list
      @header_string = "Repetition | Time to Peak |     Force   | RoFD (dF/dT)\n"
      fill_output_s()
    end
    def fill_output_s()
      iter_count = 0
      @output_s = "" + @header_string
      begin
        @cycle_list.each { |cycle|
          iter_count += 1
          left_band_duration = cycle.get_band(:LEFT).get_end_point(:TIME).to_f - cycle.get_band(:LEFT).get_start_point(:TIME).to_f
          left_band_slope = cycle.get_band(:LEFT).get_slope().to_f
          rofd = left_band_slope / left_band_duration
          @output_s += "\t#{iter_count}\t#{left_band_duration}\t"
          @output_s += "\t#{left_band_slope}\t#{rofd}\n"
        }
      rescue
        return
      end
    end
    def to_s()
      return @output_s
    end
  end
end
