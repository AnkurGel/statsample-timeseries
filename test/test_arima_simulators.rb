require(File.expand_path(File.dirname(__FILE__)+'/helpers_tests.rb'))

class StatsampleArimaSimulatorsTest < MiniTest::Unit::TestCase
  def generate_acf(simulation)
    ts = simulation.to_ts
    ts.acf
  end

  def generate_pacf(simulation)
    ts = simulation.to_ts
    ts.pacf
  end
  context("AR(1) simulations") do
    include Statsample::ARIMA

    setup do
      @series = ARIMA.new
      @ar_1_positive = @series.ar_sim(1500, [0.9], 2)
      @ar_1_negative = @series.ar_sim(1500, [-0.9], 2)

      #generating acf
      @positive_acf = generate_acf(@ar_1_positive)
      @negative_acf = generate_acf(@ar_1_negative)

      #generating pacf
      @positive_pacf = generate_pacf(@ar_1_positive)
      @negative_pacf = generate_pacf(@ar_1_negative)
    end


    should "have exponential decay of acf on positive side with phi > 0" do
      @acf = @positive_acf
      assert_equal @acf[0], 1.0
      assert_operator @acf[1], :>=, 0.7
      assert_operator @acf[@acf.size - 1], :<=, 0.2
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_positive_phi_acf.png
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_positive_phi_acf_line.png
    end

    should "have series with alternating sign on acf starting on negative side with phi < 0" do
      @acf = @negative_acf
      assert_equal @acf[0], 1.0
      #testing for alternating series
      assert_operator @acf[1], :<, 0
      assert_operator @acf[2], :>, 0
      assert_operator @acf[3], :<, 0
      assert_operator @acf[4], :>, 0
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_negative_phi_acf.png
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_negative_phi_acf_line.png
    end

    should "have positive spike on pacf at lag 1 for phi > 0" do
      @pacf = @positive_pacf
      assert_operator @pacf[1], :>=, 0.7
      assert_operator @pacf[2], :<=, 0.2
      assert_operator @pacf[3], :<=, 0.14
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_postive_phi_pacf.png
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_postive_phi_pacf_line.png
    end

    should "have negative spike on pacf at lag 1 for phi < 0" do
      @pacf = @negative_pacf
      assert_operator @pacf[1], :<=, 0
      assert_operator @pacf[1], :<=, -0.5
      assert_operator @pacf[2], :>=, -0.5
      #visualizaton:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%281%29_negative_phi_pacf.png
      #[hided @pacf[0] = 1 to convey accurate picture]
    end
  end

  context("AR(p) simulations") do
    include Statsample::ARIMA

    setup do
      @series = ARIMA.new
      @ar_p_positive = @series.ar_sim(1500, [0.3, 0.5], 2)
      @ar_p_negative = @series.ar_sim(1500, [-0.3, -0.5], 2)
    end


    should "have damped sine wave starting on positive side on acf" do
      @ar = @ar_p_positive
      @acf = generate_acf(@ar)
      assert_operator @acf[0], :>=, @acf[1]
      assert_operator @acf[1], :>=, 0.0
      assert_operator @acf[1], :>=, @acf[2]
      assert_operator @acf[2], :>=, @acf[3]
      #caution: sine curve can split on cartesian plane,
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR(p)_positive_phi_sine_wave.png
    end

    should "have damped sine wave starting on negative side on acf" do
      @ar = @ar_p_negative
      @acf = generate_acf(@ar)
      assert_operator @acf[0], :>=, @acf[1]
      assert_operator @acf[1], :<=, 0.0
      assert_operator @acf[1], :>=, @acf[2]
      #caution: sine curve can split on cartesian plane,
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR%28p%29_negative_phi_acf_sine_wave.png
    end

    should "have spikes from 1 to p for pacf" do
      #here p = 2
      @ar = @ar_p_positive
      @pacf = generate_pacf(@ar)
      assert_equal @pacf[0], 1.0
      assert_operator @pacf[1], :>, @pacf[3]
      assert_operator @pacf[1], :>, @pacf[4]
      assert_operator @pacf[1], :>, @pacf[5]
      assert_operator @pacf[2], :>, @pacf[3]
      assert_operator @pacf[2], :>, @pacf[4]
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/AR(p)_positive_phi_pacf_spikes.png
    end
  end


  context("MA(1) simulations") do
    include Statsample::ARIMA
    setup do
      @series = ARIMA.new
      @ma_positive = @series.ar_sim(1500, [0.5], 2)
      @ma_negative = @series.ar_sim(1500, [-0.5], 2)
    end

    should "have one positive spike at lag 1 on acf at positive theta" do
      @acf = generate_acf(@ma_positive)
      assert_equal @acf[0], 1.0
      assert_operator @acf[1], :>=, 0 #test if positive
      #test if spike
      assert_operator @acf[2], :>=, 0.2
      assert_operator @acf[3], :<=, 0.2
      assert_operator @acf[4], :<=, 0.1
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/MA%281%29_postive_acf.png
    end

    should "have one negative spike at lag 1 on acf at negative theta" do
      @acf = generate_acf(@ma_negative)
      assert_operator @acf[1], :<, 0
      assert_operator @acf[2], :>=, @acf[1]
      assert_operator @acf[3], :>=, @acf[1]
      #visualization:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/MA%281%29_negative_acf.png
      #positive_vs_negative:
      #https://dl.dropboxusercontent.com/u/102071534/sciruby/MA%281%29_acf_positive_vs_negative.png
    end

  end

  context("MA(q) simulations") do
    include Statsample::ARIMA
    setup do
      @series = ARIMA.new
      @ma_positive = @series.ar_sim(1500, [0.5, 0.3, 0.2], 2)
      @ma_negative = @series.ar_sim(1500, [-0.5], 2)
    end

    should "have q positive spikes at lag 1 to q on acf at positive thetas" do
      @acf = generate_acf(@ma_positive)
      assert_operator @acf[1], :>=, @acf[2]
      assert_operator @acf[2], :>=, @acf[3]
      assert_operator @acf[3], :>=, @acf[4]
      #Visualization: http://jsfiddle.net/YeK2c/
    end

    should "have damped sine wave on pacf at positive thetas" do
      #visualization: http://jsfiddle.net/7keHK/2/
    end
  end
end

