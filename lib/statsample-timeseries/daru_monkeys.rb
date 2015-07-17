require 'statsample-timeseries/timeseries/pacf'
module Statsample::TimeSeriesShorthands
  # Creates a new Statsample::TimeSeries object
  # Argument should be equal to TimeSeries.new
  def to_time_series(*args)
    Daru::Vector.new(self, *args)
  end

  alias :to_ts :to_time_series
end

class Array
  include Statsample::TimeSeriesShorthands
end

module Daru
  class Vector
    include Statsample::TimeSeries::Pacf

    # = Partial Autocorrelation
    # Generates partial autocorrelation series for a timeseries
    #
    # == Arguments
    #
    #* *max_lags*: integer, optional - provide number of lags
    #* *method*: string. Default: 'yw'.
    #    * *yw*: For yule-walker algorithm unbiased approach
    #    * *mle*: For Maximum likelihood algorithm approach
    #    * *ld*: Forr Levinson-Durbin recursive approach
    #
    # == Returns
    #
    # array of pacf
    def pacf(max_lags = nil, method = :yw)
      helper = Statsample::TimeSeries::Pacf
      method = method.downcase.to_sym
      max_lags ||= (10 * Math.log10(size)).to_i
      if method == :yw or method == :mle
        helper.pacf_yw(self, max_lags, method.to_s)
      elsif method == :ld
        series = self.acvf
        helper.levinson_durbin(series, max_lags, true)[2]
      else
        raise "Method presents for pacf are 'yw', 'mle' or 'ld'"
      end
    end
    
    # == Autoregressive estimation
    # Generates AR(k) series for the calling timeseries by yule walker.
    #
    # == Parameters
    #
    #* *n*: integer, (default = 1500) number of observations for AR.
    #* *k*: integer, (default = 1) order of AR process.
    #
    # == Returns
    #
    # Array constituting estimated AR series.
    def ar(n = 1500, k = 1)
      series = Statsample::TimeSeries.arima
      #series = Statsample::TimeSeries::ARIMA.new
      series.yule_walker(self, n, k)
    end
  end
end

module Statsample
  module TimeSeries

    # Deprecated. Use Daru::Vector.
    class Series < Daru::Vector
      def initialize *args, &block
        $stderr.puts "This class has been deprecated. Use Daru::Vector directly."
        super(*args, &block)
      end
    end
  end
end
