class ::Matrix
  # == Squares of sum
  #
  # Does squares of sum in column order.
  # Necessary for computations in various processes
  def squares_of_sum
    (0...column_size).map do |j|
      self.column(j).sum**2
    end
  end

  # == Symmetric?
  # `symmetric?` is present in Ruby Matrix 1.9.3+, but not in 1.8.*
  #
  # == Returns
  #
  # bool
  def symmetric?
    return false unless square?

    (0...row_size).each do |i|
      0.upto(i).each do |j|
        return false if self[i, j] != self[j, i]
      end
    end
    true
  end

  # == Cholesky decomposition
  #
  # Reference: http://en.wikipedia.org/wiki/Cholesky_decomposition
  # == Description
  #
  # Cholesky decomposition is reprsented by `M = L X L*`, where
  # M is the symmetric matrix and `L` is the lower half of cholesky matrix,
  # and `L*` is the conjugate form of `L`.
  #
  # == Returns
  #
  # Cholesky decomposition for a given matrix(if symmetric)
  #
  # == Utility
  #
  # Essential matrix function, requisite in kalman filter, least squares
  def cholesky
    raise ArgumentError, "Given matrix should be symmetric" unless symmetric?
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
    c
  end

  #==Chain Product
  #Class method
  #Returns the chain product of two matrices
  #===Usage:
  #Let `a` be 4 * 3 matrix,
  #Let `b` be 3 * 3 matrix,
  #Let `c` be 3 * 1 matrix,
  #then `Matrix.chain_dot(a, b, c)`
  #===NOTE:
  # Send the matrices in multiplicative order with proper dimensions
  def self.chain_dot(*args)
    #inspired by Statsmodels
    begin
      args.reduce { |x, y| x * y } #perform matrix multiplication in order
    rescue ExceptionForMatrix::ErrDimensionMismatch
      puts "ExceptionForMatrix: Please provide matrices with proper multiplicative dimensions"
    end
  end


  #==Adds a column of constants.
  #Appends a column of ones to the matrix/array if first argument is false
  #If an n-array, first checks if one column of ones is already present
  #if present, then original(self) is returned, else, prepends with a vector of ones
  def add_constant(prepend = true)
    #for Matrix
    (0...column_size).each do |i|
      if self.column(i).map(&:to_f) == Object::Vector.elements(Array.new(row_size, 1.0))
        return self
      end
    end
    #append/prepend a column of one's
    vectors = (0...row_size).map do |r|
      if prepend
        [1.0].concat(self.row(r).to_a)
      else
        self.row(r).to_a.push(1.0)
      end
    end
    return Matrix.rows(vectors)
  end

  #populates column i of given matrix with arr
  def set_column(i, arr)
    columns = self.column_vectors
    column = columns[i].to_a
    column[0...arr.size] = arr
    columns[i] = column
    return Matrix.columns(columns)
  end

  #populates row i of given matrix with arr
  def set_row(i, arr)
    #similar implementation as set_column
    #writing and commenting metaprogrammed version
    #Please to give opinion :)
    rows = self.row_vectors
    row = rows[i].to_a
    row[0...arr.size] = arr
    rows[i] = row
    return Matrix.rows(rows)
  end
end
