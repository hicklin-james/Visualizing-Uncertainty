'use strict'

angular.module('547ProjectApp')
  .factory 'DiseaseAttribute', ['$q', '_', 'Util', ($q, _, Util) ->
    class DiseaseAttribute

      # generate all the necessary variables that we need to work with
      constructor: (diseaseAttrs) ->
        @key = diseaseAttrs.key
        @name = diseaseAttrs.name
        @label = diseaseAttrs.label
        @description = diseaseAttrs.description
        @shortLabel = diseaseAttrs.shortLabel
        @deltaDirection = diseaseAttrs.deltaDirection
        @data = syntheticData[@key].data
        @delta = syntheticData[@key].delta
        @iconArrayLabels = diseaseAttrs.iconArrayLabels
        @mean = Util.arrMean(@data)
        @sd = Util.arrStd(@data, @mean)
        @ci95 = 1.96 * (@sd / Math.sqrt(@data.length))
        @ci99 = 2.576 * (@sd / Math.sqrt(@data.length))
        @sortedData = @data.sort((a,b) -> return a - b)
        if @data.length % 2 isnt 0
          @median = @sortedData[(@data.length / 2) + 1]
        else
          @median = (@sortedData[@data.length / 2] + @sortedData[(@data.length / 2) + 1]) / 2
        @minimum = @sortedData[0]
        @maximum = @sortedData[@sortedData.length-1]
        
    ]
