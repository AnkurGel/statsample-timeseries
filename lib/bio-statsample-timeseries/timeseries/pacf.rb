module Statsample
  module TimeSeries
    module Pacf
      class Pacf

        def self.pacf_yw(timeseries, max_lags, method = 'yw')
          #partial autocorrelation by yule walker equations.
          #Inspiration: StatsModels
          pacf = [1.0]
          (1..max_lags).map do |i|
            pacf << yule_walker(timeseries, i, method)[0][-1]
          end
          pacf
        end

        def self.levinson_durbin(series, nlags = 10, is_acovf = false)
          #parameters:
          #series : timeseries, or a series of autocovariances
          #nlags: largest lag to include in recursion or order of the AR process
          #is_time_series: boolean. series is timeseries if it is true, else contains autocavariances

          #returns:
          #sigma_v: estimate of the error variance
          #arcoefs: AR coefficients
          #pacf: pacf function
          #sigma: some function

          if is_acovf
            series = series.map(&:to_f)
          else
            #nlags = order(k) of AR in this case
            series = series.acvf.map(&:to_f)[0..nlags]
          end
          #phi = Array.new((nlags+1), 0.0) { Array.new(nlags+1, 0.0) }
          order = nlags
          phi = Matrix.zero(nlags + 1)
          sig = Array.new(nlags+1)

          #setting initial point for recursion:
          phi[1,1] = series[1]/series[0]
          #phi[1][1] = series[1]/series[0]
          sig[1] = series[0] - phi[1, 1] * series[1]

          2.upto(order).each do |k|
            phi[k, k] = (series[k] - (Statsample::Vector.new(phi[1...k, k-1]) * series[1...k].reverse.to_ts).sum) / sig[k-1]
            #some serious refinement needed in above for matrix manipulation. Will do today
            1.upto(k-1).each do |j|
              phi[j, k] = phi[j, k-1] - phi[k, k] * phi[k-j, k-1]
            end
            sig[k] = sig[k-1] * (1-phi[k, k] ** 2)

          end
          sigma_v = sig[-1]
          arcoefs_delta = phi.column(phi.column_size - 1)
          arcoefs = arcoefs_delta[1..arcoefs_delta.size]
          pacf = diag(phi)
          pacf[0] = 1.0
          return [sigma_v, arcoefs, pacf, sig, phi]
        end

        def self.diag(mat)
          #returns array of diagonal elements of a matrix.
          #will later abstract it to matrix.rb in Statsample
          return mat.each_with_index(:diagonal).map { |x, r, c| x }
        end


        def self.yule_walker(ts, k = 1, method='yw')
          #From the series, estimates AR(p)(autoregressive) parameter
          #using Yule-Waler equation. See -
          #http://en.wikipedia.org/wiki/Autoregressive_moving_average_model

          #parameters:
          #ts = series
          #k = order, default = 1
          #method = can be 'yw' or 'mle'. If 'yw' then it is unbiased, denominator
          #is (n - k)

          #returns:
          #rho => autoregressive coefficients
          #sigma => sigma parameter
          ts = ts - ts.mean
          n = ts.size
          if method.downcase.eql? 'yw'
            #unbiased => denominator = (n - k)
            denom =->(k) { n - k }
          else
            #mle
            #denominator => (n)
            denom =->(k) { n }
          end
          r = Array.new(k + 1) { 0.0 }
          r[0] = ts.map { |x| x**2 }.inject(:+).to_f / denom.call(0).to_f

          1.upto(k) do |l|
            r[l] = (ts[0...-l].zip(ts[l...ts.size])).map do |x|
              x.inject(:*)
            end.inject(:+).to_f / denom.call(l).to_f
          end

          r_R = toeplitz(r[0...-1])

          mat = Matrix.columns(r_R).inverse()
          phi = solve_matrix(mat, r[1..r.size])
          phi_vector = Statsample::Vector.new(phi, :scale)
          r_vector = Statsample::Vector.new(r[1..r.size], :scale)
          sigma = r[0] - (r_vector * phi_vector).sum
          return [phi, sigma]
        end

        def self.toeplitz(arr)
          #Generates Toeplitz matrix -
          #http://en.wikipedia.org/wiki/Toeplitz_matrix
          #Toeplitz matrix are equal when they are stored in row &
          #column major
          #=> arr = [0, 1, 2, 3]
          #=> result:
          #[[0, 1, 2, 3],
          # [1, 0, 1, 2],
          # [2, 1, 0, 1],
          # [3, 2, 1, 0]]
          eplitz_matrix = Array.new(arr.size) { Array.new(arr.size) }

          0.upto(arr.size - 1) do |i|
            j = 0
            index = i
            while i >= 0 do
              eplitz_matrix[index][j] = arr[i]
              j += 1
              i -= 1
            end
            i = index + 1; k = 1
            while i < arr.size do
              eplitz_matrix[index][j] = arr[k]
              i += 1; j += 1; k += 1
            end
          end
          eplitz_matrix
        end

        def self.solve_matrix(matrix, out_vector)
          solution_vector = Array.new(out_vector.size, 0)
          matrix = matrix.to_a
          k = 0
          matrix.each do |row|
            row.each_with_index do |element, i|
              solution_vector[k] += element * 1.0 * out_vector[i]
            end
            k += 1
          end
          solution_vector
        end

      end
    end
  end
end
