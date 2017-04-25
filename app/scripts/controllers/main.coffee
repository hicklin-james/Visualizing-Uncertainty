'use strict'

module = angular.module('547ProjectApp')

###*
 # @ngdoc function
 # @name 547ProjectApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the 547ProjectApp
###
class MainCtrl
  @$inject: ['$scope', 'filterFilter', '$interval', 'DiseaseAttribute', '$timeout', 'Util', '_']
  constructor: (@$scope, @filterFilter, @$interval, @DiseaseAttribute, @$timeout, @Util, @_) ->

    @$scope.ctrl = @

    @$scope.$watch 'ctrl.uncertaintyDegree', (nv, ov) =>
      @degUncert = if nv is 1 then "ci95" else "ci99"
      @$scope.$broadcast 'chartUncertaintyChanged', nv

    @$scope.$watch 'ctrl.pointEstimate', (nv, ov) =>
      @$scope.$broadcast 'chartPointEstimateChanged', nv

    @$scope.$watch 'ctrl.attributes | filter:{selected:true}', (nv) =>
      @selectedAttributes = nv
      @$scope.$broadcast 'chartDataChanged', @selectedAttributes
    , true

    strokeRiskAttrs = 
      key: "strokeRisk"
      name: "Stroke Risk"
      label: "Have a stroke"
      shortLabel: "Decrease risk of stroke"
      iconArrayLabels: ["don't have a stroke", "saved from having a stroke"]
      description: "Your risk of stroke will decrease if you choose to take warfarin"

    bleedRiskAttrs = 
      key: "bleedRisk"
      name: "Bleed Risk"
      label: "Have a major bleed"
      iconArrayLabels: ["don't have a major bleed", "have a major bleed caused by warfarin"]
      shortLabel: "Increase risk of bleed"
      description: "Taking warfarin can increase your risk of major internal bleed"

    ichRiskAttrs = 
      key: "ichRisk"
      name: "Intercranial Hemorrhage Risk"
      label: "Have an intercranial hemorrhage"
      iconArrayLabels: ["don't have an intercranial hemmorhage", "have an intercranial hemmorhage caused by warfarin"]
      shortLabel: "Increase risk of hemorrhage"
      description: "Taking warfarin can increase your risk of an intercranial hemorrhage"

    abdoPainRiskAttrs = 
      key: "abdoPain"
      name: "Abdominal Pain Risk"
      label: "Have abdominal pain"
      iconArrayLabels: ["don't have any abdominal pain", "develop abdominal pain from taking warfarin"]
      shortLabel: "Increase risk of abdominal pain"
      description: "Taking warfarin can increase your risk of abdominal pain."

    
    @attrInputs = [strokeRiskAttrs, bleedRiskAttrs, ichRiskAttrs, abdoPainRiskAttrs]
    @strokeRisk = new @DiseaseAttribute(strokeRiskAttrs)
    @bleedRisk = new @DiseaseAttribute(bleedRiskAttrs)
    @ichRisk = new @DiseaseAttribute(ichRiskAttrs)
    @abdoRisk = new @DiseaseAttribute(abdoPainRiskAttrs)

    @strokeRisk.selected = true
    @bleedRisk.selected = true
    @ichRisk.selected = true
    @abdoRisk.selected = true

    @attributes = [@strokeRisk, @bleedRisk, @ichRisk, @abdoRisk]
    # start as empty
    @selectedAttributes = [@strokeRisk, @bleedRisk, @ichRisk, @abdoRisk]
    @selectedDefaults = true

    @currentView = "Violin"
    @comparisonViewItems = ["Isotype", "Violin", "Gradient"]
    @uncertaintyDegree = "1"
    @pointEstimate = "mean"

  selectedAttrs: () ->
    if @resampled
      @filterFilter @sampledAttrs, {selected: true}
    else
      @filterFilter(@attributes, {selected: true})

  bestCaseFromCurrentDataSet: () ->
    @showBestCase = !@showBestCase
    @showWorstCase = false
    @$scope.$broadcast 'showBestCase', @showBestCase

  worstCaseFromCurrentDataSet: () ->
    @showWorstCase = !@showWorstCase
    @showBestCase = false 
    @$scope.$broadcast 'showWorstCase', @showWorstCase

  randomlySample: () ->
    @sampledAttrs = []
    @_.each @attributes, (attr, index) =>
      randomSample = @Util.randomlySampleArray(100, attr.data)
      newAttr = new @DiseaseAttribute(@attrInputs[index], randomSample)
      newAttr.selected = attr.selected
      @sampledAttrs.push newAttr

    @resampled = true
    @selectedAttributes = @selectedAttrs()
    #console.log @selectedAttributes
    @$scope.$broadcast 'chartDataChanged', @selectedAttributes

  continueToVis: () ->
    @selectedDefaults = true

  resetAll: () ->
    @resampled = false
    @selectedAttributes = @selectedAttrs()
    @$scope.$broadcast 'chartDataChanged', @selectedAttributes

  selectAttribute: (attr) ->
    i = @selectedAttributes.indexOf(attr)
    if i is -1
      attr.selected = true
      @selectedAttributes.push attr
    else
      attr.selected = false
      @selectedAttributes.splice(i, 1)

    
module.controller 'MainCtrl', MainCtrl