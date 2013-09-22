module Statsample
  module Regression
    module GLM

      class Logistic

        attr_reader :coefficients, :se, :fit, :residuals, :df, :iter, :converged
        def initialize(x, y)
          @x = x
          @y = y
        end

        def self.mu(x, b)
          matrix_mul = x * b
          numerator = matrix_mul.map { |y| Math.exp(y) }
          denominator = numerator.map { |y| 1 + y }

          numerator.each_with_index { |e, r, c|
            numerator[r,c] = numerator[r,c].to_f / denominator[r,c].to_f
          }
        end

        def self.w(x, b)
          mus = mu(x,b).column_vectors(&:to_a).flatten
          mus_intermediate = mus.collect { |x| 1 - x }
          w = mus.zip(mus_intermediate).collect { |x| x.inject(:*) }
          w_mat = Matrix.I(w.size)
          w_enum = w.to_enum
          return w_mat.map do |x|
            x.eql?(1) ? w_enum.next : x
          end
        end

        def self.h(x,b,y)
          x_t = x.transpose
          mu_flat = mu(x,b).column_vectors.map(&:to_a).flatten
          column_data = y.zip(mu_flat).collect { |x| x.inject(:-) }
          x_t * Matrix.column_vector(column_data)
        end

        def self.j(x,b)
          w_matrix = w(x, b)
          jacobian_matrix = x.transpose * w_matrix * x
          jacobian_matrix.map { |x| -x }
        end

        def to_s

        end

        def irwls
          x, y = @x, @y
          #calling irwls on Regression and passing equivalent methods in lambdas.
          #Ruby_level+=awesome!
          @coefficients, @se, @fit, @residuals, @df, @iter, @converged = Statsample::Regression.irwls(
              x,y, ->l,m{self.class.mu(l,m)}, ->l,m{self.class.w(l,m)},
              ->l,m{self.class.j(l,m)}, ->k,l,m{self.class.h(k,l,m)}
          )
        end
      end

    end
  end
end