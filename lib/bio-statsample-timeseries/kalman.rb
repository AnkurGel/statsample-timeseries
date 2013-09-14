module Statsample
  module TimeSeries
    module Arima
      class KalmanFilter < Statsample::Vector
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
            KalmanFilter.ll(x.to_a, timeseries, p, q)
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

        #=ll
        #Kalman filter function.
        #iteratively minimized by simplex algorithm via KalmanFilter.ks
        #Not meant to be used directly. Will make it private later.
        def self.ll(params, timeseries, p, q)
          phi = []
          theta = []
          phi = params[0...p] if p > 0
          theta = params[(p)...(p + q)] if q > 0

          [phi, theta].each do |v|
            if v.size>0 and v.map(&:abs).inject(:+) > 1
              return
            end
          end

          m = [p, q].max
          h = Matrix.column_vector(Array.new(m,0))
          m.times do |i|
            h[i,0] = phi[i] if i< p
            h[i,0] = h[i,0] + theta[i] if i < q
          end

          t = Matrix.zero(m)
          #set_column is available in utility.rb
          t = t.set_column(0, phi)
          if(m > 1)
            t[0...(m-1), 1...m] = Matrix.I(m-1)
            #chances of extra constant 0 values as unbalanced column, so:
            t = Matrix.columns(t.column_vectors)
          end

          g = Matrix[[1]]
          a_t = Matrix.column_vector(Array.new(m,0))
          n = timeseries.size
          z = Matrix.row_vector(Array.new(m,0))
          z[0,0] = 1
          p_t = Matrix.I(m)
          v_t, f_t = Array.new(n,0), Array.new(n, 0)

          n.times do |i|
            v_t[i] = (z * a_t).map { |x| timeseries[i] - x }[0,0]

            f_t[i] = (z * p_t * (z.transpose)).map { |x| x + 1 }[0,0]

            k_t = ((t * p_t * z.transpose) + h).map { |x| x / f_t[i] }

            a_t = (t * a_t) + (k_t * v_t[i])
            l_t = t - k_t * z
            j_t = h - k_t

            p_t = (t * p_t * (l_t.transpose)) + (h * (j_t.transpose))
          end

          pot = v_t.map(&:square).zip(f_t).map { |x,y| x / y}.inject(:+)
          sigma_2 = pot.to_f / n.to_f

          f_t_log_sum = f_t.map { |x| Math.log(x) }.inject(:+)
          ll = -0.5 * (n*Math.log(sigma_2) + f_t_log_sum + n)
          #puts ("ll = #{-ll}")
          return -ll
        end

        #=T
        #The coefficient matrix for the state vector in state equation
        # It's dimensions is r+k x r+k
        #*Parameters*
        #-_r_::integer, r is max(p, q+1), where p and q are orders of AR and MA respectively
        #-_k_::integer, number of exogeneous variables in ARMA model
        #-_q_::integer, The AR coefficient of ARMA model

        #*References*: Statsmodels tsa, Durbin and Koopman Section 4.7
        def self.T(r, k, p)
          arr = Matrix.zero(r)
          params_padded  = Statsample::Vector.new(Array.new(r, 0), :scale)

          params_padded[0...p] = params[k...(p+k)]
          intermediate_matrix = (r-1).times.map { Array.new(r, 0) }
          #appending an array filled with padded values in beginning
          intermediate_matrix[0,0] = [params_padded]

          #now generating column matrix for that:
          arr = Matrix.columns(intermediate_matrix)
          arr_00 = arr[0,0]

          #identify matrix substituition in matrix except row[0] and column[0]
          r.times do |i|
            arr[r,r] = 1
          end
          arr[0,0] = arr_00
          arr
        end


        #=R
        #The coefficient matrix for the state vector in the observation matrix.
        #It's dimension is r+k x 1
        #*Parameters*
        #-_r_::integer, r is max(p, q+1) where p and q are order of AR and MA respectively
        #-_k_::integer, number of exogeneous variables in ARMA model
        #-_q_::integer, The MA order in ARMA model
        #-_p_::integer, The AR order in ARMA model
        #*References*: Statsmodels tsa, Durbin and Koopman
        def self.R(r, k, q, p)
          arr = Matrix.column_vector(Array.new(r,0.0))

          #pending - in kind of difficult end here;
        end

        #=Z
        #The Z selector matrix
        #*Parameters*
        #-_r_::integer, max(p, q+1)
        #Returns: vector
        def self.Z(r)
          arr = Statsample::Vector.new(Array.new(r, 0.0), :scale)
          arr[0] = 1.0
          return arr
        end

      end
    end
  end
end
