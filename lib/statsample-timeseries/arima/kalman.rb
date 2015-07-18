require 'statsample-timeseries/arima/likelihood'
module Statsample
  module TimeSeries
    module Arima

      class KalmanFilter
        include Statsample::TimeSeries
        include GSL::MultiMin if Statsample.has_gsl?

        #timeseries object
        attr_writer :ts
        #Autoregressive order
        attr_accessor :p
        #Integerated part order
        attr_accessor :i
        #Moving average order
        attr_accessor :q

        # Autoregressive coefficients
        attr_reader :ar
        # Moving average coefficients
        attr_reader :ma

        #Creates a new KalmanFilter object and computes the likelihood
        def initialize(ts=[], p=0, i=0, q=0)
          @ts = ts.to_a
          @p = p
          @i = i
          @q = q
          ks #call the filter
        end

        def ts
          Daru::Vector.new(@ts)
        end

        def to_s
          sprintf("ARIMA model(p = %d, i = %d, q = %d) on series(%d elements) - [%s]",
                  @p, @i, @q, @ts.size, @ts.to_a.join(','))
        end

        # = Kalman Filter
        #  Function which minimizes KalmanFilter.ll iteratively for initial parameters
        # == Usage
        #    @s = [-1.16025577,0.64758021,0.77158601,0.14989543,2.31358162,3.49213868,1.14826956,0.58169457,-0.30813868,-0.34741084,-1.41175595,0.06040081, -0.78230232,0.86734837,0.95015787,-0.49781397,0.53247330,1.56495187,0.30936619,0.09750217,1.09698829,-0.81315490,-0.79425607,-0.64568547,-1.06460320,1.24647894,0.66695937,1.50284551,1.17631218,1.64082872,1.61462736,0.06443761,-0.17583741,0.83918339,0.46610988,-0.54915270,-0.56417108,-1.27696654,0.89460084,1.49970338,0.24520493,0.26249138,-1.33744834,-0.57725961,1.55819543,1.62143157,0.44421891,-0.74000084 ,0.57866347,3.51189333,2.39135077,1.73046244,1.81783890,0.21454040,0.43520890,-1.42443856,-2.72124685,-2.51313877,-1.20243091,-1.44268002 ,-0.16777305,0.05780661,2.03533992,0.39187242,0.54987983,0.57865693,-0.96592469,-0.93278473,-0.75962671,-0.63216906,1.06776183, 0.17476059 ,0.06635860,0.94906227,2.44498583,-1.04990407,-0.88440073,-1.99838258,-1.12955558,-0.62654882,-1.36589161,-2.67456821,-0.97187696, -0.84431782 ,-0.10051809,0.54239549,1.34622861,1.25598105,0.19707759,3.29286114,3.52423499,1.69146333,-0.10150024,0.45222903,-0.01730516, -0.49828727, -1.18484684,-1.09531773,-1.17190808,0.30207662].to_ts
        #    @kf=Statsample::TimeSeries::ARIMA.ks(@s,1,0,0)
        #    #=> ks is implictly called in above operation
        #    @kf.ar
        #    #=> AR coefficients
        def ks
          initial = Array.new((@p+@q), 0.0)

          my_f = Proc.new{ |x, params|
            #In rb-gsl, params remain idle, x is varied upon
            #In R code, initial parameters varied in each iteration
            #my_func.set_params([(1..100).to_a.to_ts, p_value, q_value])
            timeseries = params[0]
            p,q = params[1], params[2]
            params = x
            #puts x
            -Arima::KF::LogLikelihood.new(x.to_a, timeseries, p, q).log_likelihood
            #KalmanFilter.ll(x.to_a, timeseries, p, q)
          }
          np = @p + @q
          my_func = Function.alloc(my_f, np)
          my_func.set_params([@ts, @p, @q])
          x = GSL::Vector.alloc(initial)
          ss = GSL::Vector.alloc(np)
          ss.set_all(0.1)

          minimizer = FMinimizer.alloc("nmsimplex", np)
          minimizer.set(my_func, x, ss)
          status = GSL::CONTINUE
          iter = 0
          while status == GSL::CONTINUE && iter < 100
            iter += 1
            begin
              status = minimizer.iterate
              status = minimizer.test_size(1e-2)
              x = minimizer.x
            rescue
              break
            end
          end
          @ar = (p > 0) ? x.to_a[0...p] : []
          @ma = (q > 0) ? x.to_a[p...(p+q)] : []
          x.to_a
        end


        #=Log Likelihood
        #Computes Log likelihood on given parameters, ARMA order and timeseries
        #==params
        #* *params*: array of floats, contains phi/theta parameters
        #* *timeseries*: timeseries object
        #* *p*: integer, AR(p) order
        #* *q*: integer, MA(q) order
        #==Returns
        #LogLikelihood object
        #==Usage
        # s = (1..100).map { rand }.to_ts
        # p, q  = 1, 0
        # ll = KalmanFilter.log_likelihood([0.2], s, p, q)
        # ll.log_likelihood
        # #=> -22.66
        # ll.sigma
        # #=> 0.232
        def self.log_likelihood(params, timeseries, p, q)
          Arima::KF::LogLikelihood.new(params, timeseries, p, q)
        end


        def self.T(r, k, p)
          #=T
          #The coefficient matrix for the state vector in state equation
          # It's dimensions is r+k x r+k
          #==Parameters
          #* *r*: integer, r is max(p, q+1), where p and q are orders of AR and MA respectively
          #* *k*: integer, number of exogeneous variables in ARMA model
          #* *q*: integer, The AR coefficient of ARMA model

          #==References Statsmodels tsa, Durbin and Koopman Section 4.7
          raise NotImplementedError
        end
      end
    end
  end
end
