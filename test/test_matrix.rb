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

  #TESTS for matrix symmetricity - Matrix#is_symmetric?
  context("is_symmetric?") do

    should "return false for non-symmetric matrix" do
      assert_equal @mat_non_symmetric.is_symmetric?, false
    end

    should "return false for non-square matrix" do
      assert_equal @mat_non_square.is_symmetric?, false
    end

    should "return true for symmetrix matrix" do
      arr = %w[4 12 -16 12 37 -43 -16 -43 93].map(&:to_i)
      mat = setup_square_matrix(arr, 3)
      assert_equal mat.is_symmetric?, true
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

  end

end
