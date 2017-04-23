'use strict'

module = angular.module('547ProjectApp')

class IsotypeCtrl
  @$inject: ['$scope', '$interval', 'DiseaseAttribute', 'Util', '_']
  constructor: (@$scope, @$interval, @DiseaseAttribute, @Util, @_) ->

    @selectedAttributes = @$scope.$parent.$parent.ctrl.selectedAttributes
    @pointEstimate = @$scope.$parent.$parent.ctrl.pointEstimate

    @$scope.ctrl = @

    @convertAttributesToUsableIsotypeData(@selectedAttributes)

    @$scope.$on 'chartPointEstimateChanged', (event, nv) =>
      @pointEstimate = nv
      @convertAttributesToUsableIsotypeData(@selectedAttributes)

    @$scope.$on "chartDataChanged", (event, nv) =>
      @selectedAttributes = nv
      @convertAttributesToUsableIsotypeData(@selectedAttributes)

    # @strokeRiskData = new @StrokeRisk
    # @strokeLabels = ["don't have a stroke", "saved from having a stroke", "have a stroke"]
    # @setIsotypeData("strokeRiskIconArrayData", "strokeRiskData", false, @strokeLabels)

    # @bleedRiskData = new @BleedRisk
    # @bleedLabels = ["don't have a major bleed", "have a major bleed", "have a major bleed caused by Warfarin"]
    # @setIsotypeData("bleedRiskIconArrayData", "bleedRiskData", true, @bleedLabels)

  convertAttributesToUsableIsotypeData: (attrs) ->
    @isotypeData = @_.map attrs, (attr) =>
      @setIsotypeData(attr)
    @chunkedIsotypeData = @Util.chunkArray(angular.copy(@isotypeData), 2)

  setIsotypeData: (dataAttr) ->
    baseline = Math.abs(Math.round(dataAttr[@pointEstimate]))
    delta = Math.round(dataAttr.delta * 100)
    if dataAttr.deltaDirection
      combined = baseline + delta
      rest = 100 - combined
      d = 
        attachedData: dataAttr.data
        key: dataAttr.key
        name: dataAttr.name
        iconArrayData: [
          value: rest
          color: "lightgreen"
          label: dataAttr.iconArrayLabels[0]
         ,
          value: delta
          color: "lightblue"
          label: dataAttr.iconArrayLabels[1]
         ,
          value: baseline
          color: "#ffbfbb"
          label: dataAttr.iconArrayLabels[2]
        ].reverse()
      d
    else
      combined = baseline - delta
      rest = 100 - baseline
      d = 
        attachedData: dataAttr.data
        key: dataAttr.key
        name: dataAttr.name
        iconArrayData: [
          value: rest
          color: "lightgreen"
          label: dataAttr.iconArrayLabels[0]
         ,
          value: delta
          color: "#ffdb89"
          label: dataAttr.iconArrayLabels[1]
         ,
          value: combined
          color: "#ffbfbb"
          label: dataAttr.iconArrayLabels[2]
        ].reverse()
      d

  resample: () ->
    @resampled = true
    data = @_.map @selectedAttributes, (d) =>
      mean = @Util.arrMean(@Util.randomlySampleArray(10, d.data))
      resampledAttr = 
        key: d.key
        mean: mean
        delta: d.delta
        deltaDirection: d.deltaDirection
        iconArrayLabels: d.iconArrayLabels
        name: d.name
      @setIsotypeData(resampledAttr)
    @isotypeData = data
    @chunkedIsotypeData = @Util.chunkArray(angular.copy(@isotypeData), 2)


    # @resampledStrokeRiskData = 
    #   mean: @Util.arrMean(@Util.randomlySampleArray(10, @strokeRiskData.data))
    #   delta: @strokeRiskData.delta

    # @resampledBleedRiskData = 
    #   mean: @Util.arrMean(@Util.randomlySampleArray(10, @bleedRiskData.data))
    #   delta: @bleedRiskData.delta

    # @setIsotypeData("strokeRiskIconArrayData", "resampledStrokeRiskData", false, @strokeLabels)
    # @setIsotypeData("bleedRiskIconArrayData", "resampledBleedRiskData", true, @bleedLabels)


module.controller 'IsotypeCtrl', IsotypeCtrl