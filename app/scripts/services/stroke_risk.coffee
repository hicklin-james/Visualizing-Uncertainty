'use strict'

angular.module('547ProjectApp')
  .factory 'StrokeRisk', ['$q', '_', 'Util', ($q, _, Util) ->
    class StrokeRisk

      # generate all the necessary variables that we need to work with
      constructor: () ->
        @data = strokedata
        @delta = strokedelta
        @mean = Util.arrMean(@data)
        @sd = Util.arrStd(@data, @mean)
        @ci95 = 1.96 * (@sd / Math.sqrt(@data.length))
        @sortedData = @data.sort()
        if @data.length % 2 isnt 0
          @median = @sortedData[(@data.length / 2) + 1]
        else
          @median = (@sortedData[@data.length / 2] + @sortedData[(@data.length / 2) + 1]) / 2
        @minimum = @sortedData[0]
        @maximum = @sortedData[@sortedData.length-1]
        
    ]
