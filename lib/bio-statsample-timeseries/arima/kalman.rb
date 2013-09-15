require 'bio-statsample-timeseries/arima/likelihood'
module Statsample
  module TimeSeries
    module Arima

      class KalmanFilter
        include Statsample::TimeSeries
        include GSL::MultiMin
        attr_accessor :ts, :p, :i, :q
        attr_reader :ar, :ma
        def initialize(ts=[].to_ts, p=0, i=0, q=0)
          @ts = ts
          @p = p
          @i = i
          @q = q
          ks #call the filter
        end

        def to_s
          sprintf("ARIMA model(p = %d, i = %d, q = %d) on series(%d elements) - [%s]",
                  @p, @i, @q, @ts.size, @ts.to_a.join(','))
        end

        #=Kalman Filter
        #Function which minimizes KalmanFilter.ll iteratively for initial parameters
        #*Parameters*:
        #-_timeseries_: timeseries object, against which the ARMA params has to be estimated
        #-_p_: order of AR
        #-_q_: order of MA
        #*Usage*:
        #- ts = (1..100).to_a.to_ts
        #- KalmanFilter.ks(ts, 3, 1)
        #NOTE: Suceptible to syntactical change later. Can be called directly on timeseries.
        #NOTE: Return parameters
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
            -Arima::KF::LogLikelihood.new(x.to_a, timeseries, p, q).ll
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
              status = minimizer.iterate()
              status = minimizer.test_size(1e-2)
              x = minimizer.x
            rescue
              break
            end
          #  printf("%5d ", iter)
          #  for i in 0...np do
          #    puts "#{x[i]}.to_f"
          #    #printf("%10.3e ", x[i].to_f)
          #  end
          #  printf("f() = %7.3f size = %.3f\n", minimizer.fval, minimizer.size)
          end
          #
          @ar = (p > 0) ? x.to_a[0...p] : []
          @ma = (q > 0) ? x.to_a[p...(p+q)] : []
          x.to_a
        end


        #=log_likelihood
        #Computes Log likelihood on given parameters, ARMA order and timeseries
        #*params*:
        #-_params_::array of floats, contains phi/theta parameters
        #-_timeseries_::timeseries object
        #-_p_::integer, AR(p) order
        #-_q_::integer, MA(q) order
        #*Returns*:
        #LogLikelihood object
        #*Usage*:
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

        #=T
        #The coefficient matrix for the state vector in state equation
        # It's dimensions is r+k x r+k
        #*Parameters*
        #-_r_::integer, r is max(p, q+1), where p and q are orders of AR and MA respectively
        #-_k_::integer, number of exogeneous variables in ARMA model
        #-_q_::integer, The AR coefficient of ARMA model

        #*References*: Statsmodels tsa, Durbin and Koopman Section 4.7
        #def self.T(r, k, p)
        #  arr = Matrix.zero(r)
        #  params_padded  = Statsample::Vector.new(Array.new(r, 0), :scale)
        #
        #  params_padded[0...p] = params[k...(p+k)]
        #  intermediate_matrix = (r-1).times.map { Array.new(r, 0) }
        #  #appending an array filled with padded values in beginning
        #  intermediate_matrix[0,0] = [params_padded]
        #
        #  #now generating column matrix for that:
        #  arr = Matrix.columns(intermediate_matrix)
        #  arr_00 = arr[0,0]
        #
        #  #identify matrix substituition in matrix except row[0] and column[0]
        #  r.times do |i|
        #    arr[r,r] = 1
        #  end
        #  arr[0,0] = arr_00
        #  arr
        #end

      end
    end
  end
end
