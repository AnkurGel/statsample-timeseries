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


    #To abstract out diagonal elements code I wrote in pacf earlier.
  end
end
