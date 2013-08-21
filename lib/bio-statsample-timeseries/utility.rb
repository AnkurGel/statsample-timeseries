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
        self.map { |x| (x-m) }.sum ** 2
      else
        return self.sum.to_f ** 2
      end
    end
  end


  class ::Matrix
    #=Squares of sum
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

    #=Chain Product
    #Class method
    #Returns the chain product of two matrices
    #==Usage:
    #Let `a` be 4 * 3 matrix, 
    #Let `b` be 3 * 3 matrix, 
    #Let `c` be 3 * 1 matrix,
    #then `Matrix.chain_dot(a, b, c)`
    #===*NOTE*: Send the matrices in multiplicative order with proper dimensions
    def self.chain_dot(*args)
      #inspired by Statsmodels
      begin
        args.reduce { |x, y| x * y } #perform matrix multiplication in order
      rescue ExceptionForMatrix::ErrDimensionMismatch
        puts "ExceptionForMatrix: Please provide matrices with proper multiplicative dimensions"
      end
    end
  end

  #=Adds a column of constants.
  #Appends a column of ones to the matrix/array if first argument is false
  #If an n-array, first checks if one column of ones is already present
  #if present, then original(self) is returned, else, prepends with a vector of ones
  def add_constant(prepend = true)
    #for Matrix
    (0...column_size).each do |i|
      if Statsample::Vector.new(Matrix.column(i), :scale) == Statsample::Vector.new(Array.new(row_size, 1), :scale)
        #a column with constant is already present
        return self
      end
    end
    #prepend/append a column with ones
    
  end
end
