require 'bio-statsample-timeseries/regression/poisson'
require 'bio-statsample-timeseries/regression/logistic'
module Statsample
  module Regression

    def self.glm(x, y, method=:poisson)
      if method.downcase.to_sym == :poisson
        #Statsample::Regression::GLM::Poisson.new(x,y)
      end
    end

    def self.irwls(x, y, mu, w, j, h, epsilon = 1e-7, max_iter = 100)
      b = Matrix.column_vector(Array.new(x.column_size,0.0))
      converted = false
      1.upto(max_iter) do |i|
        b_new #continuing
      end
    end

  end
end