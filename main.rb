#!/usr/bin/ruby

# Load our written modules
require_relative 'DataFile'
require_relative 'CycleDetection'
require_relative 'RoFD'
include CycleDetection
include DataFile
include RoFD

def main()
  datadir = './data/'
  justOneFile = 'LHIP 240.txt'
  config = DEMO_COLUMN_CONFIG_HASHES[:ONLY_ONE_SO_FAR]
  $data = DataFileOfPoints.new(datadir, justOneFile, config)
  $cycletron = CycleList.new(datadir, justOneFile, config, :TORQUE)
  $cycletron.puts_slope_list
  $rofd = RofdPrinter.new($cycletron)
  puts $rofd.to_s 
end

main()
