#!/usr/bin/ruby

# Adjust Ruby's classpath so that it can find our written modules
$LOAD_PATH << '.'

# Load our written modules
require 'DataFile.rb'

# Invoke our module tests
puts 'Invoking DataFile.tester...'
DataFile.tester

# Good-bye!
puts 'Script complete!'

