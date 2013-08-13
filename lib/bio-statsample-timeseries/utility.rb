module Statsample
  class Vector
    include Enumerable
    include Writable
    include Summarizable

    #=Squares of sum
    #---
    #parameter:
    #-demean::boolean - optional. __default__: false
    #Sums the timeseries and then returns the square
    def squares_of_sum(demean = false)
      if demean
        m = self.mean
        self.map { |x| (x-m)}.sum ** 2
      else
        return self.sum.to_f ** 2
      end
    end
  end


  class ::Matrix
    #=Squares f sum
    #---
    #Does squares of sum in column order.
    #Necessary for computations in various processes
    def squares_of_sum
      no_columns = self.column_size
      (0...no_columns).map do |j|
        self.column(j).sum ** 2
      end
    end

    #=Checks if given matrix is symmetric or not
    #---
    #returns bool
    #`symmetric?` is present in Ruby Matrix 1.9.3+, but not in 1.8.*
    def is_symmetric?
      return false unless square?

      (0...row_size).each do |i|
        0.upto(i).each do |j|
          return false if self[i, j] != self[j, i]
        end
      end
      true
    end

    #=Cholesky decomposition
    #Reference: http://en.wikipedia.org/wiki/Cholesky_decomposition
    #---
    #==Description
    #Cholesky decomposition is reprsented by `M = L X L*`, where
    #M is the symmetric matrix and `L` is the lower half of cholesky matrix,
    #and `L*` is the conjugate form of `L`.
    #*Returns* : Cholesky decomposition for a given matrix(if symmetric)
    #*Utility*: Essential matrix function, requisite in kalman filter, least squares
    def cholesky
      if is_symmetric?
        c = Matrix.zero(row_size)
        0.upto(row_size - 1).each do |k|
          0.upto(row_size - 1).each do |i|
            if i == k
              sum = (0..(k-1)).inject(0.0){ |sum, j| sum + c[k, j] ** 2 }
              value = Math.sqrt(self[k,k] - sum)
              c[k, k] = value
            elsif i > k
              sum = (0..(k-1)).inject(0.0){ |sum, j| sum + c[i, j] * c[k, j] }
              value = (self[k,i] - sum) / c[k, k]
              c[i, k] = value
            end
          end
        end
      else
        raise ArgumentError, "Given matrix should be symmetric."
      end
      c
    end


    #To abstract out diagonal elements code I wrote in pacf earlier.
  end
end
