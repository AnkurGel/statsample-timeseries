#require 'debugger'
module Statsample
  module ARIMA
    class ARIMA < Statsample::Vector
      include Statsample::TimeSeries

      def arima(ds, p, i, q)
        #prototype
        if q.zero?
          self.ar(p)
        elsif p.zero?
          self.ma(p)
        end
      end

      def ar(p)
        #AutoRegressive part of model
        #http://en.wikipedia.org/wiki/Autoregressive_model#Definition
        #For finding parameters(to fit), we will use either Yule-walker
        #or Burg's algorithm(more efficient)
      end

      def create_vector(arr)
        Statsample::Vector.new(arr, :scale)
      end

      def yule_walker(ts, n, k)
        #parameters: timeseries, no of observations, order
        #returns: simulated autoregression with phi parameters and sigma
        phi, sigma = Pacf::Pacf.yule_walker(ts, k)
        return ar_sim(n, phi, sigma)
      end

      def levinson_durbin(ts, n, k)
        #parameters;
        #ts: timseries against which to generate phi coefficients
        #n: number of observations for simulation
        #k: order of AR
        intermediate = Pacf::Pacf.levinson_durbin(ts, k)
        phi, sigma = intermediate[1], intermediate[0]
        return ar_sim(n, phi, sigma)
      end
      #tentative AR(p) simulator
      def ar_sim(n, phi, sigma)
        #using random number generator for inclusion of white noise
        err_nor = Distribution::Normal.rng(0, sigma)
        #creating buffer with 10 random values
        buffer = Array.new(10, err_nor.call())

        x = buffer + Array.new(n, 0)

        #For now "phi" are the known model parameters
        #later we will obtain it by Yule-walker/Burg

        #instead of starting from 0, start from 11
        #and later take away buffer values for failsafe
        11.upto(n+11) do |i|
          if i <= phi.size
            #dependent on previous accumulation of x
            backshifts = create_vector(x[0...i].reverse)
          else
            #dependent on number of phi size/order
            backshifts = create_vector(x[(i - phi.size)...i].reverse)
          end
          parameters = create_vector(phi[0...backshifts.size])

          summation = (backshifts * parameters).inject(:+)
          x[i] = summation + err_nor.call()
        end
        x - buffer
      end

      #moving average simulator
      def ma_sim(n, theta, sigma)
        #n is number of observations (eg: 1000)
        #theta are the model parameters containting q values
        #q is the order of MA
        mean = theta.to_ts.mean()
        whitenoise_gen = Distribution::Normal.rng(0, sigma)
        x = Array.new(n, 0)
        q = theta.size
        noise_arr = (n+1).times.map { whitenoise_gen.call() }

        1.upto(n) do |i|
          #take care that noise vector doesn't try to index -ve value:
          if i <= q
            noises = create_vector(noise_arr[0..i].reverse)
          else
            noises = create_vector(noise_arr[(i-q)..i].reverse)
          end
          weights = create_vector([1] + theta[0...noises.size - 1])

          summation = (weights * noises).inject(:+)
          x[i] = mean + summation
        end
        x
      end

      #arma simulator
      def arma_sim(n, p, q, sigma)
        #represented by :
        #http://upload.wikimedia.org/math/2/e/d/2ed0485927b4370ae288f1bc1fe2fc8b.png


        whitenoise_gen = Distribution::Normal.rng(0, sigma)
        noise_arr = (n+11).times.map { whitenoise_gen.call() }

        buffer = Array.new(10, whitenoise_gen.call())
        x = buffer + Array.new(n, 0)

        11.upto(n+11) do |i|
          if i <= p.size
            backshifts = create_vector(x[0...i].reverse)
          else
            backshifts = create_vector(x[(i - p.size)...i].reverse)
          end
          parameters = create_vector(p[0...backshifts.size])

          ar_summation = (backshifts * parameters).inject(:+)

          if i <= q.size
            noises = create_vector(noise_arr[0..i].reverse)
          else
            noises = create_vector(noise_arr[(i-q.size)..i].reverse)
          end
          weights = create_vector([1] + q[0...noises.size - 1])

          ma_summation = (weights * noises).inject(:+)

          x[i] = ar_summation + ma_summation
        end
        x - buffer
      end

      #=Hannan-Rissanen for ARMA fit
      def self.hannan(ts, p, q, k)
        start_params = create_vector(Array.new(p+q+k, 0))
        ts_dup = ts.dup

      end
    end
    class KalmanFilter < Statsample::Vector
      include Statsample::TimeSeries

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
