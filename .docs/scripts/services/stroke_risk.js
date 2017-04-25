(function() {
  'use strict';
  angular.module('547ProjectApp').factory('StrokeRisk', [
    '$q', '_', 'Util', function($q, _, Util) {
      var StrokeRisk;
      return StrokeRisk = (function() {
        function StrokeRisk() {
          this.data = strokedata;
          this.delta = strokedelta;
          this.mean = Util.arrMean(this.data);
          this.sd = Util.arrStd(this.data, this.mean);
          this.ci95 = 1.96 * (this.sd / Math.sqrt(this.data.length));
          this.sortedData = this.data.sort();
          if (this.data.length % 2 !== 0) {
            this.median = this.sortedData[(this.data.length / 2) + 1];
          } else {
            this.median = (this.sortedData[this.data.length / 2] + this.sortedData[(this.data.length / 2) + 1]) / 2;
          }
          this.minimum = this.sortedData[0];
          this.maximum = this.sortedData[this.sortedData.length - 1];
        }

        return StrokeRisk;

      })();
    }
  ]);

}).call(this);

//# sourceMappingURL=stroke_risk.js.map
