require(File.expand_path(File.dirname(__FILE__)+'/helper.rb'))

class StatsampleArimaKSTestCase < MiniTest::Unit::TestCase

  context("AR(0.5) simulation") do
    #include Statsample::TimeSeries
    setup do
      @s = [-1.16025577,0.64758021,0.77158601,0.14989543,2.31358162,3.49213868,1.14826956,0.58169457,-0.30813868,-0.34741084,-1.41175595,0.06040081, -0.78230232,0.86734837,0.95015787,-0.49781397,0.53247330,1.56495187,0.30936619,0.09750217,1.09698829,-0.81315490,-0.79425607,-0.64568547,-1.06460320,1.24647894,0.66695937,1.50284551,1.17631218,1.64082872,1.61462736,0.06443761,-0.17583741,0.83918339,0.46610988,-0.54915270,-0.56417108,-1.27696654,0.89460084,1.49970338,0.24520493,0.26249138,-1.33744834,-0.57725961,1.55819543,1.62143157,0.44421891,-0.74000084 ,0.57866347,3.51189333,2.39135077,1.73046244,1.81783890,0.21454040,0.43520890,-1.42443856,-2.72124685,-2.51313877,-1.20243091,-1.44268002 ,-0.16777305,0.05780661,2.03533992,0.39187242,0.54987983,0.57865693,-0.96592469,-0.93278473,-0.75962671,-0.63216906,1.06776183, 0.17476059 ,0.06635860,0.94906227,2.44498583,-1.04990407,-0.88440073,-1.99838258,-1.12955558,-0.62654882,-1.36589161,-2.67456821,-0.97187696, -0.84431782 ,-0.10051809,0.54239549,1.34622861,1.25598105,0.19707759,3.29286114,3.52423499,1.69146333,-0.10150024,0.45222903,-0.01730516, -0.49828727, -1.18484684,-1.09531773,-1.17190808,0.30207662].to_ts
    end
    context "passed through the Kalman Filter" do
      setup do
        @kf=Statsample::TimeSeries::ARIMA.ks(@s,1,0,0)
      end
      should "return correct object" do
        assert_instance_of Statsample::TimeSeries::Arima::KalmanFilter, @kf
      end
      should "return correct parameters" do
        assert_equal @kf.p,1
        assert_equal @kf.q,0
        assert_equal @kf.i,0
      end
      should "return correct ar estimators" do
        assert_equal @kf.ar.length,1
        assert_in_delta @kf.ar[0], 0.700 #0.564
      end
      should "return correct ma estimators" do
        assert_equal @kf.ma.length,0
      end
    end
    context "passed through the Kalman Filter with AR(0.564)" do
      setup do
        @kf_likehood=Statsample::TimeSeries::Arima::KalmanFilter.log_likelihood([0.564],@s,1,0)
      end
      should "return correct object for log_likehood" do
        assert_instance_of Statsample::TimeSeries::Arima::KF::LogLikelihood, @kf_likehood
      end
      should "return correct log_likehood" do
        assert_in_delta -148.7003,  @kf_likehood.log_likelihood
      end
      should "return correct sigma" do
        assert_in_delta 1.137915,  @kf_likehood.sigma
      end

    end
    context "passed through the Kalman Filter with AR(0.2)" do
      setup do
        @kf_likehood=Statsample::TimeSeries::Arima::KalmanFilter.log_likelihood([0.2],@s,1,0)
      end
      should "return correct object for log_likehood" do
        assert_instance_of Statsample::TimeSeries::Arima::KF::LogLikelihood, @kf_likehood
      end
      should "return correct log_likehood" do
        assert_in_delta -66.40337-0.5*@s.size*(Math.log(2*Math::PI)),  @kf_likehood.log_likelihood
      end
      should "return correct sigma" do
        assert_in_delta 1.378693,  @kf_likehood.sigma
      end

    end
  end

  context("ARMA(1, 1) process") do
    setup do
      @s = [-1.16025577,0.64758021,0.77158601,0.14989543,2.31358162,3.49213868,1.14826956,0.58169457,-0.30813868,-0.34741084,-1.41175595,0.06040081, -0.78230232,0.86734837,0.95015787,-0.49781397,0.53247330,1.56495187,0.30936619,0.09750217,1.09698829,-0.81315490,-0.79425607,-0.64568547,-1.06460320,1.24647894,0.66695937,1.50284551,1.17631218,1.64082872,1.61462736,0.06443761,-0.17583741,0.83918339,0.46610988,-0.54915270,-0.56417108,-1.27696654,0.89460084,1.49970338,0.24520493,0.26249138,-1.33744834,-0.57725961,1.55819543,1.62143157,0.44421891,-0.74000084 ,0.57866347,3.51189333,2.39135077,1.73046244,1.81783890,0.21454040,0.43520890,-1.42443856,-2.72124685,-2.51313877,-1.20243091,-1.44268002 ,-0.16777305,0.05780661,2.03533992,0.39187242,0.54987983,0.57865693,-0.96592469,-0.93278473,-0.75962671,-0.63216906,1.06776183, 0.17476059 ,0.06635860,0.94906227,2.44498583,-1.04990407,-0.88440073,-1.99838258,-1.12955558,-0.62654882,-1.36589161,-2.67456821,-0.97187696, -0.84431782 ,-0.10051809,0.54239549,1.34622861,1.25598105,0.19707759,3.29286114,3.52423499,1.69146333,-0.10150024,0.45222903,-0.01730516, -0.49828727, -1.18484684,-1.09531773,-1.17190808,0.30207662].to_ts
    end
    context "passed through the Kalman Filter" do
      setup do
        @kf = Statsample::TimeSeries::ARIMA.ks(@s, 2, 0, 1)
      end

      should "return correct parameters" do
        assert_equal @kf.p, 1
        assert_equal @kf.q, 1
        assert_equal @kf.i, 0
      end
      should "return correct AR estimators" do
        assert_equal @kf.ar.length, 2
        assert_in_delta @kf.ar[0], 0.45
        assert_in_delta @kf.ar[1], 0.016
      end
      should "return correct ma estimators" do
        assert_equal @kf.ma.length, 1
        assert_equal @kf.ma[0], 0.18
      end
    end

    context "passed through the LogLikelihood with ARMA([0.45, 0.16, 0.18])" do
      setup do
        @ll = Statsample::TimeSeries::Arima::KF::LogLikelihood.new([0.45, 0.16, 0.18], @s, 2, 1)
      end
      should "return correct log likelihood" do
        assert_in_delta 56.35, @ll.log_likelihood
      end
      should "return correct sigma" do
        assert_in_delta 1.11, @ll.sigma
      end
    end
  end

end
