require(File.expand_path(File.dirname(__FILE__)+'/helper.rb'))
class StatsampleMatrixTestCase < MiniTest::Unit::TestCase

  def setup_square_matrix(arr, n)
    #returns n * n matrix by slicing arr
    return Matrix.rows(arr.each_slice(n).to_a)
  end


  context("is_symmetric?") do

    should "return false for non-symmetric matrix" do
      arr = (1..16)
      mat = setup_square_matrix(arr, 4)
      assert_equal mat.is_symmetric?, false
    end

    should "return false for non-square matrix" do
      arr = (1..12).to_a
      #this is 4 X 3 matrix
      mat = Matrix.rows(arr.each_slice(3).to_a)
      assert_equal mat.is_symmetric?, false
    end

    should "return true for symmetrix matrix" do
      arr = %w[4 12 -16 12 37 -43 -16 -43 93].map(&:to_i)
      mat = setup_square_matrix(arr, 3)
      assert_equal mat.is_symmetric?, true
    end
  end
end
