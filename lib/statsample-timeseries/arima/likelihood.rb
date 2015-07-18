module Statsample
  module TimeSeries
    module Arima
      module KF
        class LogLikelihood

          #Gives log likelihood value of an ARMA(p, q) process on given parameters
          attr_reader :log_likelihood

          #Gives sigma value of an ARMA(p,q) process on given parameters
          attr_reader :sigma

          #Gives AIC(Akaike Information Criterion)
          #https://www.scss.tcd.ie/Rozenn.Dahyot/ST7005/13AICBIC.pdf
          attr_reader :aic

          def initialize(params, timeseries, p, q)
            @params = params
            @timeseries = timeseries.to_a
            @p = p
            @q = q
            ll
          end

          #===Log likelihood link function.
          #iteratively minimized by simplex algorithm via KalmanFilter.ks
          #Not meant to be used directly. Will make it private later.
          def ll
            params, timeseries = @params, @timeseries
            p, q = @p, @q

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
            if m > 1
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
            @log_likelihood = -0.5 * (n*Math.log(2*Math::PI) + n*Math.log(sigma_2) + f_t_log_sum + n)
            
            @sigma = sigma_2
            @aic = -(2 * @log_likelihood - 2*(p+q+1))
            #puts ("ll = #{-ll}")
            return @log_likelihood
          end

          def to_s
            sprintf("LogLikelihood(p = %d, q = %d) on params: [%s]",
                    @p, @q, @params.join(', '))
          end
        end
      end
    end
  end
end
