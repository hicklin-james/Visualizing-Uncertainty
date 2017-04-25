(function() {
  'use strict';
  var GradientCtrl, module;

  module = angular.module('547ProjectApp');

  GradientCtrl = (function() {
    GradientCtrl.$inject = ['$scope', '$interval', 'DiseaseAttribute', 'Util', '_'];

    function GradientCtrl($scope, $interval, DiseaseAttribute, Util, _) {
      var selectedAttributes;
      this.$scope = $scope;
      this.$interval = $interval;
      this.DiseaseAttribute = DiseaseAttribute;
      this.Util = Util;
      this._ = _;
      selectedAttributes = this.$scope.$parent.$parent.ctrl.selectedAttributes;
      this.use99 = this.$scope.$parent.$parent.ctrl.uncertaintyDegree === "2";
      this.pointEstimate = this.$scope.$parent.$parent.ctrl.pointEstimate;
      this.$scope.ctrl = this;
      this.convertAttributesToUsableGradientData(selectedAttributes);
      this.$scope.$on("chartDataChanged", (function(_this) {
        return function(event, nv) {
          console.log(nv);
          return _this.convertAttributesToUsableGradientData(nv);
        };
      })(this));
    }

    GradientCtrl.prototype.convertAttributesToUsableGradientData = function(attrs) {
      return this.gradientData = this._.map(attrs, function(attr) {
        return {
          label: attr.label,
          mean: attr.mean,
          median: attr.median,
          ci95: attr.ci95,
          ci99: attr.ci99,
          direction: attr.deltaDirection
        };
      });
    };

    return GradientCtrl;

  })();

  module.controller('GradientCtrl', GradientCtrl);

}).call(this);

//# sourceMappingURL=gradient.js.map
