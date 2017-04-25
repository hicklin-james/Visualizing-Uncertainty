(function() {
  'use strict';
  angular.module('547ProjectApp').factory('DiseaseAttribute', [
    '$q', '_', 'Util', function($q, _, Util) {
      var DiseaseAttribute;
      return DiseaseAttribute = (function() {
        function DiseaseAttribute(diseaseAttrs, inputData) {
          if (inputData == null) {
            inputData = null;
          }
          this.key = diseaseAttrs.key;
          this.name = diseaseAttrs.name;
          this.label = diseaseAttrs.label;
          this.description = diseaseAttrs.description;
          this.shortLabel = diseaseAttrs.shortLabel;
          this.iconArrayLabels = diseaseAttrs.iconArrayLabels;
          this.delta = syntheticData[this.key].delta;
          if (inputData) {
            this.data = inputData;
          } else {
            this.data = syntheticData[this.key].data;
          }
          this.mean = Util.arrMean(this.data);
          this.deltaDirection = this.mean < 0;
          this.sd = Util.arrStd(this.data, this.mean);
          this.ci95 = 1.96 * (this.sd / Math.sqrt(this.data.length));
          this.ci99 = 2.576 * (this.sd / Math.sqrt(this.data.length));
          this.sortedData = this.data.sort(function(a, b) {
            return a - b;
          });
          if (this.data.length % 2 !== 0) {
            this.median = this.sortedData[(Math.floor(this.data.length / 2)) + 1];
          } else {
            this.median = (this.sortedData[this.data.length / 2] + this.sortedData[(this.data.length / 2) + 1]) / 2;
          }
          this.minimum = this.sortedData[0];
          this.maximum = this.sortedData[this.sortedData.length - 1];
        }

        return DiseaseAttribute;

      })();
    }
  ]);

}).call(this);

//# sourceMappingURL=disease_attribute.js.map
