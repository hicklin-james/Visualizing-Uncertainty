'use strict'

angular.module('547ProjectApp')
  .factory 'Util', ['$q', '_', ($q, _) ->

    arrMean = (arr) ->
      _.reduce(arr, (memo, num) -> memo + num) / arr.length

    makeId: () ->
      text = "";
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      i = 0
      while i < 5
        text += possible.charAt(Math.floor(Math.random() * possible.length))
        i = i + 1

      text

    randomlySampleArray: (n, arr) ->
      randomSample = []
      counter = 0
      while counter < n
        usedIndices = []
        randomIndex = Math.floor(Math.random() * arr.length)
        if usedIndices.indexOf(randomIndex) is -1
          randomSample.push arr[randomIndex]
          counter += 1
      randomSample

    chunkArray: (arr, size) ->
      chunks = []
      
      while arr.length > 0
        chunks.push arr.splice(0, size)

      chunks

    arrMean: (arr) ->
      arrMean(arr)

    arrStd: (arr, mean) ->
      squareDiffs = _.map arr, (item) ->
        diff = item - mean
        diff * diff

      diffsMean = arrMean(squareDiffs)
      Math.sqrt(diffsMean)

  ]
