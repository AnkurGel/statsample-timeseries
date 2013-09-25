#require 'debugger'
require 'statsample-timeseries/arima/kalman'
require 'statsample-timeseries/arima/likelihood'
module Statsample
  module TimeSeries

    def self.arima
      #not passing (ds,p,i,q) elements for now
      #will do that once #arima is ready for all modelling
      Statsample::TimeSeries::ARIMA.new
    end

    class ARIMA < Statsample::Vector
      include Statsample::TimeSeries

      #= Kalman filter on ARIMA model
      #== Params
      #
      #* *ts*: timeseries object
      #* *p*: AR order
      #* *i*: Integerated part order
      #* *q*: MA order
      #
      #== Usage
      # ts = (1..100).map { rand }.to_ts
      # k_obj = Statsample::TimeSeries::ARIMA.ks(ts, 2, 1, 1)
      # k_obj.ar
      # #=> AR's phi coefficients
      # k_obj.ma 
      # #=> MA's theta coefficients
      #
      #== Returns
      #Kalman filter object
      def self.ks(ts, p, i, q)
        #prototype
        if i > 0
          ts = ts.diff(i).reject { |x| x.nil? }.to_ts
        end
        filter = Arima::KalmanFilter.new(ts, p, i, q)
        filter
      end

      def ar(p)
        #AutoRegressive part of model
        #http://en.wikipedia.org/wiki/Autoregressive_model#Definition
        #For finding parameters(to fit), we will use either Yule-walker
        #or Burg's algorithm(more efficient)
      end

      #Converts a linear array into a Statsample vector
      #== Parameters
      #
      #* *arr*: Array which has to be converted in Statsample vector
      def create_vector(arr)
        Statsample::Vector.new(arr, :scale)
      end

      #=Yule Walker
      #Performs yule walker estimation on given timeseries, observations and order
      #==Parameters
      #
      #* *ts*: timeseries object
      #* *n* : number of observations
      #* *k* : order
      #
      #==Returns
      #phi and sigma vectors
      def yule_walker(ts, n, k)
        phi, sigma = Pacf::Pacf.yule_walker(ts, k)
        return phi, sigma
        #return ar_sim(n, phi, sigma)
      end

      #=Levinson Durbin estimation
      #Performs levinson durbin estimation on given timeseries, observations and order
      #==Parameters
      #
      #* *ts*: timeseries object
      #* *n* : number of observations
      #* *k* : autoregressive order
      #
      #==Returns
      #phi and sigma vectors
      def levinson_durbin(ts, n, k)
        intermediate = Pacf::Pacf.levinson_durbin(ts, k)
        phi, sigma = intermediate[1], intermediate[0]
        return phi, sigma
        #return ar_sim(n, phi, sigma)
      end

      #=Autoregressive Simulator
      #Simulates an autoregressive AR(p) model with specified number of
      #observations(n), with phi number of values for order p and sigma.
      #
      #==Analysis:
      # [http://ankurgoel.com/blog/2013/07/20/ar-ma-arma-acf-pacf-visualizations/](http://ankurgoel.com/blog/2013/07/20/ar-ma-arma-acf-pacf-visualizations/)
      #
      #==Parameters:
      #* *n*: integer, number of observations
      #* *phi* :array of phi values, e.g: [0.35, 0.213] for p = 2
      #* *sigma*: float, sigma value for error generalization
      #
      #==Usage
      #  ar = ARIMA.new
      #  ar.ar_sim(1500, [0.3, 0.9], 0.12)
      #    # => AR(2) autoregressive series of 1500 values
      #
      #==Returns
      #Array of generated autoregressive series against attributes
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

      #=Moving Average Simulator
      #Simulates a moving average model with specified number of
      #observations(n), with theta values for order k and sigma
      #
      #==Parameters
      #* *n*: integer, number of observations
      #* *theta*: array of floats, e.g: [0.23, 0.732], must be < 1
      #* *sigma*: float, sigma value for whitenoise error
      #
      #==Usage
      #  ar = ARIMA.new
      #  ar.ma_sim(1500, [0.23, 0.732], 0.27)
      #
      #==Returns
      #Array of generated MA(q) model
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

      #=ARMA(Autoregressive and Moving Average) Simulator
      #ARMA is represented by:
      #http://upload.wikimedia.org/math/2/e/d/2ed0485927b4370ae288f1bc1fe2fc8b.png
      #This simulates the ARMA model against p, q and sigma.
      #If p = 0, then model is pure MA(q),
      #If q = 0, then model is pure AR(p),
      #otherwise, model is ARMA(p, q) represented by above.
      #
      #==Detailed analysis:
      # [http://ankurgoel.com/blog/2013/07/20/ar-ma-arma-acf-pacf-visualizations/](http://ankurgoel.com/blog/2013/07/20/ar-ma-arma-acf-pacf-visualizations/)
      #
      #==Parameters
      #* *n*: integer, number of observations
      #* *p*: array, contains p number of phi values for AR(p) process
      #* *q*: array, contains q number of theta values for MA(q) process
      #* *sigma*: float, sigma value for whitenoise error generation
      #
      #==Usage
      #  ar = ARIMA.new
      #  ar.arma_sim(1500, [0.3, 0.272], [0.8, 0.317], 0.92)
      #
      #==Returns
      #array of generated ARMA model values
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

  end
end
