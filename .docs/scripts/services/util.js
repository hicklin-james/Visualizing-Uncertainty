(function() {
  'use strict';
  angular.module('547ProjectApp').factory('Util', [
    '$q', '_', function($q, _) {
      var arrMean;
      arrMean = function(arr) {
        return _.reduce(arr, function(memo, num) {
          return memo + num;
        }) / arr.length;
      };
      return {
        makeId: function() {
          var i, possible, text;
          text = "";
          possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
          i = 0;
          while (i < 5) {
            text += possible.charAt(Math.floor(Math.random() * possible.length));
            i = i + 1;
          }
          return text;
        },
        randomlySampleArray: function(n, arr) {
          var counter, randomIndex, randomSample, usedIndices;
          randomSample = [];
          counter = 0;
          while (counter < n) {
            usedIndices = [];
            randomIndex = Math.floor(Math.random() * arr.length);
            if (usedIndices.indexOf(randomIndex) === -1) {
              randomSample.push(arr[randomIndex]);
              counter += 1;
            }
          }
          return randomSample;
        },
        chunkArray: function(arr, size) {
          var chunks;
          chunks = [];
          while (arr.length > 0) {
            chunks.push(arr.splice(0, size));
          }
          return chunks;
        },
        arrMean: function(arr) {
          return arrMean(arr);
        },
        arrStd: function(arr, mean) {
          var diffsMean, squareDiffs;
          squareDiffs = _.map(arr, function(item) {
            var diff;
            diff = item - mean;
            return diff * diff;
          });
          diffsMean = arrMean(squareDiffs);
          return Math.sqrt(diffsMean);
        }
      };
    }
  ]);

}).call(this);

//# sourceMappingURL=util.js.map
