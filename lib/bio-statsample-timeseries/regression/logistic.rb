module Statsample
  module Regression
    module GLM

      class Logistic

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

      end

    end
  end
end