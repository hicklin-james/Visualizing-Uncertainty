(function() {
  'use strict';
  var MainCtrl, module;

  module = angular.module('547ProjectApp');


  /**
    * @ngdoc function
    * @name 547ProjectApp.controller:MainCtrl
    * @description
    * # MainCtrl
    * Controller of the 547ProjectApp
   */

  MainCtrl = (function() {
    MainCtrl.$inject = ['$scope', 'filterFilter', '$interval', 'DiseaseAttribute', '$timeout', 'Util', '_'];

    function MainCtrl($scope, filterFilter, $interval, DiseaseAttribute, $timeout, Util, _) {
      var abdoPainRiskAttrs, bleedRiskAttrs, ichRiskAttrs, strokeRiskAttrs;
      this.$scope = $scope;
      this.filterFilter = filterFilter;
      this.$interval = $interval;
      this.DiseaseAttribute = DiseaseAttribute;
      this.$timeout = $timeout;
      this.Util = Util;
      this._ = _;
      this.$scope.ctrl = this;
      this.$scope.$watch('ctrl.uncertaintyDegree', (function(_this) {
        return function(nv, ov) {
          _this.degUncert = nv === 1 ? "ci95" : "ci99";
          return _this.$scope.$broadcast('chartUncertaintyChanged', nv);
        };
      })(this));
      this.$scope.$watch('ctrl.pointEstimate', (function(_this) {
        return function(nv, ov) {
          return _this.$scope.$broadcast('chartPointEstimateChanged', nv);
        };
      })(this));
      this.$scope.$watch('ctrl.attributes | filter:{selected:true}', (function(_this) {
        return function(nv) {
          _this.selectedAttributes = nv;
          return _this.$scope.$broadcast('chartDataChanged', _this.selectedAttributes);
        };
      })(this), true);
      strokeRiskAttrs = {
        key: "strokeRisk",
        name: "Stroke Risk",
        label: "Risk of stroke",
        shortLabel: "Decrease risk of stroke",
        iconArrayLabels: ["don't have a stroke", "saved from having a stroke"],
        description: "Your risk of stroke will decrease if you choose to take warfarin"
      };
      bleedRiskAttrs = {
        key: "bleedRisk",
        name: "Bleed Risk",
        label: "Risk of major bleed",
        iconArrayLabels: ["don't have a major bleed", "have a major bleed caused by warfarin"],
        shortLabel: "Increase risk of bleed",
        description: "Taking warfarin can increase your risk of major internal bleed"
      };
      ichRiskAttrs = {
        key: "ichRisk",
        name: "Intercranial Hemorrhage Risk",
        label: "Risk of intercranial hemorrhage",
        iconArrayLabels: ["don't have an intercranial hemmorhage", "have an intercranial hemmorhage caused by warfarin"],
        shortLabel: "Increase risk of hemorrhage",
        description: "Taking warfarin can increase your risk of an intercranial hemorrhage"
      };
      abdoPainRiskAttrs = {
        key: "abdoPain",
        name: "Abdominal Pain Risk",
        label: "Risk of abdominal pain",
        iconArrayLabels: ["don't have any abdominal pain", "develop abdominal pain from taking warfarin"],
        shortLabel: "Increase risk of abdominal pain",
        description: "Taking warfarin can increase your risk of abdominal pain."
      };
      this.attrInputs = [strokeRiskAttrs, bleedRiskAttrs, ichRiskAttrs, abdoPainRiskAttrs];
      this.strokeRisk = new this.DiseaseAttribute(strokeRiskAttrs);
      this.bleedRisk = new this.DiseaseAttribute(bleedRiskAttrs);
      this.ichRisk = new this.DiseaseAttribute(ichRiskAttrs);
      this.abdoRisk = new this.DiseaseAttribute(abdoPainRiskAttrs);
      this.strokeRisk.selected = true;
      this.bleedRisk.selected = true;
      this.ichRisk.selected = true;
      this.abdoRisk.selected = true;
      this.attributes = [this.strokeRisk, this.bleedRisk, this.ichRisk, this.abdoRisk];
      this.selectedAttributes = [this.strokeRisk, this.bleedRisk, this.ichRisk, this.abdoRisk];
      this.selectedDefaults = true;
      this.currentView = "Violin";
      this.comparisonViewItems = ["Isotype", "Violin", "Gradient"];
      this.uncertaintyDegree = "1";
      this.pointEstimate = "mean";
    }

    MainCtrl.prototype.selectedAttrs = function() {
      if (this.resampled) {
        return this.filterFilter(this.sampledAttrs, {
          selected: true
        });
      } else {
        return this.filterFilter(this.attributes, {
          selected: true
        });
      }
    };

    MainCtrl.prototype.bestCaseFromCurrentDataSet = function() {
      this.showBestCase = !this.showBestCase;
      this.showWorstCase = false;
      return this.$scope.$broadcast('showBestCase', this.showBestCase);
    };

    MainCtrl.prototype.worstCaseFromCurrentDataSet = function() {
      this.showWorstCase = !this.showWorstCase;
      this.showBestCase = false;
      return this.$scope.$broadcast('showWorstCase', this.showWorstCase);
    };

    MainCtrl.prototype.randomlySample = function() {
      this.sampledAttrs = [];
      this._.each(this.attributes, (function(_this) {
        return function(attr, index) {
          var newAttr, randomSample;
          randomSample = _this.Util.randomlySampleArray(100, attr.data);
          newAttr = new _this.DiseaseAttribute(_this.attrInputs[index], randomSample);
          newAttr.selected = attr.selected;
          return _this.sampledAttrs.push(newAttr);
        };
      })(this));
      this.resampled = true;
      this.selectedAttributes = this.selectedAttrs();
      return this.$scope.$broadcast('chartDataChanged', this.selectedAttributes);
    };

    MainCtrl.prototype.continueToVis = function() {
      return this.selectedDefaults = true;
    };

    MainCtrl.prototype.resetAll = function() {
      this.resampled = false;
      this.selectedAttributes = this.selectedAttrs();
      return this.$scope.$broadcast('chartDataChanged', this.selectedAttributes);
    };

    MainCtrl.prototype.selectAttribute = function(attr) {
      var i;
      i = this.selectedAttributes.indexOf(attr);
      if (i === -1) {
        attr.selected = true;
        return this.selectedAttributes.push(attr);
      } else {
        attr.selected = false;
        return this.selectedAttributes.splice(i, 1);
      }
    };

    return MainCtrl;

  })();

  module.controller('MainCtrl', MainCtrl);

}).call(this);

//# sourceMappingURL=main.js.map
