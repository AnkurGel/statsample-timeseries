require 'bio-statsample-timeseries/regression/poisson'
require 'bio-statsample-timeseries/regression/logistic'
module Statsample
  module Regression

    def self.glm(x, y, method=:poisson)
      if method.downcase.to_sym == :poisson
        obj = Statsample::Regression::GLM::Poisson.new(x,y)
      elsif method.downcase.to_sym == :logit
        obj = Statsample::Regression::GLM::Logistic.new(x,y)
      end
      obj
      #now, #irwls method is available to be called on returned obj
    end

    def self.irwls(x, y, mu, w, j, h, epsilon = 1e-7, max_iter = 100)
      b = Matrix.column_vector(Array.new(x.column_size,0.0))
      converged = false
      1.upto(max_iter) do |i|
        #conversion from : (solve(j(x,b)) %*% h(x,b,y))
        #p j.call(x,b)
        #p h.call(x,b,y)
        # Remember that we need here the inverse of j -> J^-1
        # On R, solve gives you the inverse
        intermediate = (j.call(x,b) * h.call(x,b,y))
        b_new = b - intermediate
        
        if((b_new - b).map(&:abs)).to_a.flatten.inject(:+) < epsilon
          converged = true
          b = b_new
          break
        end
        b = b_new
      end
		
      ss = j.call(x,b).inverse.diagonal.map{ |x| - x}.map{ |y| Math.sqrt(y) }
      values = mu.call(x,b)
      
      residuals = y - values
      df_residuals = y.count - x.column_size
      return [b, ss, mu.call(x,b), residuals, max_iter, df_residuals, converged]
    end

  end
end
