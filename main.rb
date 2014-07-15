#!/usr/bin/ruby

# Load our written modules
require 'CycleDetection.rb'
include CycleDetection
include DataFile

def main()
  datadir = './data/'
  justOneFile = 'LHIP 240.txt'
  config = DEMO_COLUMN_CONFIG_HASHES[:ONLY_ONE_SO_FAR]
  $data = DataFileOfPoints.new(datadir, justOneFile, config)
  $cycletron = CycleList.new(datadir, justOneFile, config, :TORQUE)
  $cycletron.puts_slope_list 
end

main()
