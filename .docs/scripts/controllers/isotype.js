(function() {
  'use strict';
  var IsotypeCtrl, module;

  module = angular.module('547ProjectApp');

  IsotypeCtrl = (function() {
    IsotypeCtrl.$inject = ['$scope', '$interval', 'DiseaseAttribute', 'Util', '_'];

    function IsotypeCtrl($scope, $interval, DiseaseAttribute, Util, _) {
      this.$scope = $scope;
      this.$interval = $interval;
      this.DiseaseAttribute = DiseaseAttribute;
      this.Util = Util;
      this._ = _;
      this.selectedAttributes = this.$scope.$parent.$parent.ctrl.selectedAttributes;
      this.pointEstimate = this.$scope.$parent.$parent.ctrl.pointEstimate;
      this.ciToUse = this.$scope.$parent.$parent.ctrl.degUncert;
      this.bestcase = this.$scope.$parent.$parent.ctrl.showBestCase;
      this.worstcase = this.$scope.$parent.$parent.ctrl.showWorstCase;
      this.$scope.ctrl = this;
      this.convertAttributesToUsableIsotypeData(this.selectedAttributes);
      this.$scope.$on('chartPointEstimateChanged', (function(_this) {
        return function(event, nv) {
          _this.pointEstimate = nv;
          return _this.convertAttributesToUsableIsotypeData(_this.selectedAttributes);
        };
      })(this));
      this.$scope.$on("chartDataChanged", (function(_this) {
        return function(event, nv) {
          _this.selectedAttributes = nv;
          return _this.convertAttributesToUsableIsotypeData(_this.selectedAttributes);
        };
      })(this));
      this.$scope.$on('chartUncertaintyChanged', (function(_this) {
        return function(event, nv) {
          if (nv === "1") {
            _this.ciToUse = "ci95";
          } else {
            _this.ciToUse = "ci99";
          }
          return _this.convertAttributesToUsableIsotypeData(_this.selectedAttributes);
        };
      })(this));
      this.$scope.$on('showBestCase', (function(_this) {
        return function(e, nv) {
          _this.worstcase = false;
          _this.bestcase = nv;
          return _this.convertAttributesToUsableIsotypeData(_this.selectedAttributes);
        };
      })(this));
      this.$scope.$on('showWorstCase', (function(_this) {
        return function(e, nv) {
          _this.bestcase = false;
          _this.worstcase = nv;
          return _this.convertAttributesToUsableIsotypeData(_this.selectedAttributes);
        };
      })(this));
    }

    IsotypeCtrl.prototype.convertAttributesToUsableIsotypeData = function(attrs) {
      this.isotypeData = this._.map(attrs, (function(_this) {
        return function(attr) {
          return _this.setIsotypeData(attr);
        };
      })(this));
      return this.chunkedIsotypeData = this.Util.chunkArray(angular.copy(this.isotypeData), 2);
    };

    IsotypeCtrl.prototype.setIsotypeData = function(dataAttr) {
      var baseline, combined, d, delta, rest;
      baseline = null;
      if (this.bestcase) {
        if (dataAttr.deltaDirection) {
          baseline = Math.abs(Math.round(dataAttr[this.pointEstimate] + dataAttr[this.ciToUse]));
        } else {
          baseline = Math.abs(Math.round(dataAttr[this.pointEstimate] - dataAttr[this.ciToUse]));
        }
      } else if (this.worstcase) {
        if (dataAttr.deltaDirection) {
          baseline = Math.abs(Math.round(dataAttr[this.pointEstimate] - dataAttr[this.ciToUse]));
        } else {
          baseline = Math.abs(Math.round(dataAttr[this.pointEstimate] + dataAttr[this.ciToUse]));
        }
      } else {
        baseline = Math.abs(Math.round(dataAttr[this.pointEstimate]));
      }
      delta = Math.round(dataAttr.delta * 100);
      if (dataAttr.deltaDirection) {
        combined = baseline + delta;
        rest = 100 - baseline;
        d = {
          attachedData: dataAttr.data,
          key: dataAttr.key,
          name: dataAttr.name,
          iconArrayData: [
            {
              value: rest,
              color: "#BEBEBE",
              label: dataAttr.iconArrayLabels[0]
            }, {
              value: baseline,
              color: "#7C69AA",
              label: dataAttr.iconArrayLabels[1]
            }
          ].reverse()
        };
        return d;
      } else {
        combined = baseline - delta;
        rest = 100 - baseline;
        d = {
          attachedData: dataAttr.data,
          key: dataAttr.key,
          name: dataAttr.name,
          iconArrayData: [
            {
              value: rest,
              color: "#BEBEBE",
              label: dataAttr.iconArrayLabels[0]
            }, {
              value: baseline,
              color: "#F1592F",
              label: dataAttr.iconArrayLabels[1]
            }
          ].reverse()
        };
        return d;
      }
    };

    IsotypeCtrl.prototype.resample = function() {
      var data;
      this.resampled = true;
      data = this._.map(this.selectedAttributes, (function(_this) {
        return function(d) {
          var mean, resampledAttr;
          mean = _this.Util.arrMean(_this.Util.randomlySampleArray(10, d.data));
          resampledAttr = {
            key: d.key,
            mean: mean,
            delta: d.delta,
            deltaDirection: d.deltaDirection,
            iconArrayLabels: d.iconArrayLabels,
            name: d.name
          };
          return _this.setIsotypeData(resampledAttr);
        };
      })(this));
      this.isotypeData = data;
      return this.chunkedIsotypeData = this.Util.chunkArray(angular.copy(this.isotypeData), 2);
    };

    return IsotypeCtrl;

  })();

  module.controller('IsotypeCtrl', IsotypeCtrl);

}).call(this);

//# sourceMappingURL=isotype.js.map
