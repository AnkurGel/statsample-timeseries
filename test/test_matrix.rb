require(File.expand_path(File.dirname(__FILE__)+'/helper.rb'))
class StatsampleMatrixTestCase < MiniTest::Unit::TestCase

  def setup_square_matrix(arr, n)
    #returns n * n matrix by slicing arr
    return Matrix.rows(arr.each_slice(n).to_a)
  end
  def setup
    @arr_square = (1..16)
    @mat_non_symmetric = setup_square_matrix(@arr_square, 4)

    @arr_non_square = (1..12).to_a
    #this is a 4 X 3 matrix
    @mat_non_square = Matrix.rows(@arr_non_square.each_slice(3).to_a)
  end

  #TESTS for matrix symmetricity - Matrix#symmetric?
  context("symmetric?") do

    should "return false for non-symmetric matrix" do
      assert_equal @mat_non_symmetric.symmetric?, false
    end

    should "return false for non-square matrix" do
      assert_equal @mat_non_square.symmetric?, false
    end

    should "return true for symmetrix matrix" do
      arr = %w[4 12 -16 12 37 -43 -16 -43 93].map(&:to_i)
      mat = setup_square_matrix(arr, 3)
      assert_equal mat.symmetric?, true
    end
  end

  #TESTS for cholesky decomposition - Matrix#cholesky
  context("Cholesky Decomposition") do

    should "raise error for non symmetric matrix" do
      assert_raises(ArgumentError) { @mat_non_symmetric.cholesky }
    end

    should "raise raise error if non-square matix" do
      arr = (1..12).to_a
      mat = Matrix.rows(arr.each_slice(3).to_a)
      assert_raises(ArgumentError) { @mat_non_square.cholesky }
    end

    should "give hermitian cholesky decomposed matrix for symmetrix matrix" do
       arr = %w[4 12 -16 12 37 -43 -16 -43 93].map(&:to_i)
       mat = setup_square_matrix(arr, 3)
       assert_equal Matrix[[2.0, 0, 0], [6.0, 1.0, 0], [-8.0, 5.0, 2.0]], mat.cholesky
    end
  end

  #TESTS for matrix squares of sum - Matrix#squares_of_sum
  context("Squares of sum") do

    should "return array of size 4 for matrix - #{@mat_non_symmetric}" do
      #equal to column size
      assert_equal @mat_non_symmetric.squares_of_sum.size, 4
    end

    should "return [784, 1024, 1296, 1600] for matrix - #{@mat_non_symmetric}" do
      assert_equal @mat_non_symmetric.squares_of_sum, [784, 1024, 1296, 1600]
    end
  end

  #TESTS for adding constants to matrix
  context("Add constant") do

    should "prepend all rows with ones" do
      mat = @mat_non_symmetric.add_constant
      assert_equal @mat_non_symmetric.column_size, 4
      assert_equal mat.column_size, 5
      assert_equal mat.column(0).to_a, [1.0, 1.0,1.0,1.0]
    end

    should "append all rows with ones if prepend = false" do
      mat = @mat_non_symmetric.add_constant(false)
      assert_equal @mat_non_symmetric.column_size, 4
      assert_equal mat.column_size, 5
      assert_equal mat.column(mat.column_size - 1).to_a, [1.0, 1.0,1.0,1.0]
    end

    should "not append/prepend if a column of ones already exists in matrix" do
      matrix = Matrix[[1, 2, 1, 4], [5, 6, 1, 8], [9, 10, 1, 12]]  
      const_mat = matrix.add_constant
      assert_equal matrix.column_size, const_mat.column_size
      assert_equal matrix.row_size, const_mat.row_size
    end
  end
end
