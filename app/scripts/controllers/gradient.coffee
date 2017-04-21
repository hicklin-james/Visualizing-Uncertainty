'use strict'

module = angular.module('547ProjectApp')

class GradientCtrl
  @$inject: ['$scope', '$interval', 'DiseaseAttribute', 'Util', '_']
  constructor: (@$scope, @$interval, @DiseaseAttribute, @Util, @_) ->

    selectedAttributes = @$scope.$parent.$parent.ctrl.selectedAttributes
    @use99 = @$scope.$parent.$parent.ctrl.uncertaintyDegree is "2"
    @pointEstimate = @$scope.$parent.$parent.ctrl.pointEstimate

    @$scope.ctrl = @

    @convertAttributesToUsableGradientData(selectedAttributes)

    @$scope.$on "chartDataChanged", (event, nv) =>
      @convertAttributesToUsableGradientData(nv)

  convertAttributesToUsableGradientData: (attrs) ->
    @gradientData =  @_.map attrs, (attr) ->
      label: attr.shortLabel
      mean: attr.mean
      median: attr.median
      ci95: attr.ci95
      ci99: attr.ci99
      direction: attr.deltaDirection

    # @gradientData = [
    #   label: "Decrease in stroke risk"
    #   mean: @strokeRiskData.mean
    #   ci95: @strokeRiskData.ci95
    #  ,
    #   label: "Increase in bleed risk"
    #   mean: @bleedRiskData.mean
    #   ci95: @bleedRiskData.ci95
    # ]

module.controller 'GradientCtrl', GradientCtrl