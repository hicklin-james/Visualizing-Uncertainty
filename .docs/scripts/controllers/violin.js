(function() {
  'use strict';
  var ViolinCtrl, module;

  module = angular.module('547ProjectApp');

  ViolinCtrl = (function() {
    ViolinCtrl.$inject = ['$scope', '$interval', 'DiseaseAttribute', 'Util', '_'];

    function ViolinCtrl($scope, $interval, DiseaseAttribute, Util, _) {
      var selectedAttributes;
      this.$scope = $scope;
      this.$interval = $interval;
      this.DiseaseAttribute = DiseaseAttribute;
      this.Util = Util;
      this._ = _;
      selectedAttributes = this.$scope.$parent.$parent.ctrl.selectedAttributes;
      this.pointEstimate = this.$scope.$parent.$parent.ctrl.pointEstimate;
      this.$scope.ctrl = this;
      this.convertAttributesToUsableViolinData(selectedAttributes);
      this.$scope.$on("chartDataChanged", (function(_this) {
        return function(event, nv) {
          return _this.convertAttributesToUsableViolinData(nv);
        };
      })(this));
    }

    ViolinCtrl.prototype.convertAttributesToUsableViolinData = function(attrs) {
      return this.violinData = this._.map(attrs, function(attr) {
        return {
          color: attr.deltaDirection ? "#7C69AA" : "#F1592F",
          data: attr.data,
          key: attr.key,
          label: attr.label
        };
      });
    };

    return ViolinCtrl;

  })();

  module.controller('ViolinCtrl', ViolinCtrl);

}).call(this);

//# sourceMappingURL=violin.js.map
