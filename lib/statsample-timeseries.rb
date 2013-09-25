# Please require your code below, respecting the naming conventions in the
# bioruby directory tree.
#
# For example, say you have a plugin named bio-plugin, the only uncommented
# line in this file would be 
#
#   require 'bio/bio-plugin/plugin'
#
# In this file only require other files. Avoid other source code.

require 'statsample'
require_relative 'statsample-timeseries/timeseries.rb'
require_relative 'statsample-timeseries/arima.rb'
require_relative 'statsample-timeseries/arima/kalman'
require_relative 'statsample-timeseries/arima/likelihood'
require_relative 'statsample-timeseries/utility.rb'


