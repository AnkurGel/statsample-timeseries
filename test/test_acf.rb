require(File.expand_path(File.dirname(__FILE__)+'/helper.rb'))

class StatsampleTimeSeriesPacfTestCase < MiniTest::Unit::TestCase
  context Statsample::TimeSeries do
    include Statsample::TimeSeries

    setup do
      @timeseries = (1..20).map { |e| e * 10 }.to_ts
    end

    should "cross-check ACF for 10 lags" do
      lags = 10
      result = @timeseries.acf(lags)
      assert_equal result.size, 11
      assert_equal result,  [1.0, 0.85, 0.7015037593984963, 0.556015037593985, 
        0.4150375939849624, 0.2800751879699248, 0.15263157894736842, 
        0.034210526315789476, -0.07368421052631578, -0.16954887218045114, 
        -0.2518796992481203]    
    end

    should "cross-check ACF for 5 lags" do
      lags = 5
      result = @timeseries.acf(lags)
      assert_equal result.size, 6
      assert_equal result, [1.0, 0.85, 0.7015037593984963, 0.556015037593985, 
        0.4150375939849624, 0.2800751879699248]
    end

    should "first value should be 1" do
      lags = 2
      result = @timeseries.acf(lags)
      assert_equal result.size, 3
      assert_equal result.first, 1.0
    end
  end
end