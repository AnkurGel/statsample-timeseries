require 'bio-statsample-timeseries/regression/poisson'
module Statsample
  module Regression

    def self.glm(x, y, method=:poisson)
      if method.downcase.to_sym == :poisson
        #Statsample::Regression::GLM::Poisson.new(x,y)
      end
    end
  end
end