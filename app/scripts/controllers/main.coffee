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
  @$inject: ['$scope', 'filterFilter', '$interval', 'DiseaseAttribute', '$timeout', 'Util']
  constructor: (@$scope, @filterFilter, @$interval, @DiseaseAttribute, @$timeout, @Util) ->

    @$scope.ctrl = @

    @$scope.$watch 'ctrl.uncertaintyDegree', (nv, ov) =>
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
      label: "Risk of stroke"
      shortLabel: "Decrease risk of stroke"
      iconArrayLabels: ["don't have a stroke", "saved from having a stroke", "have a stroke anyways"]
      description: "Your risk of stroke will decrease if you choose to take warfarin"
      deltaDirection: true

    bleedRiskAttrs = 
      key: "bleedRisk"
      name: "Bleed Risk"
      label: "Risk of major bleed"
      iconArrayLabels: ["don't have a major bleed", "have a major bleed anyways", "have a major bleed caused by warfarin"]
      shortLabel: "Increase risk of bleed"
      description: "Taking warfarin can increase your risk of major internal bleed"
      deltaDirection: false

    ichRiskAttrs = 
      key: "ichRisk"
      name: "Intercranial Hemorrhage Risk"
      label: "Risk of intercranial hemorrhage"
      iconArrayLabels: ["don't have an intercranial hemmorhage", "have an intercranial hemmorhage anyways", "have an intercranial hemmorhage caused by warfarin"]
      shortLabel: "Increase risk of hemorrhage"
      description: "Taking warfarin can increase your risk of an intercranial hemorrhage"
      deltaDirection: false

    abdoPainRiskAttrs = 
      key: "abdoPain"
      name: "Abdominal Pain Risk"
      label: "Risk of abdominal pain"
      iconArrayLabels: ["don't have any abdominal pain", "already have abdominal pain", "develop abdominal pain from taking warfarin"]
      shortLabel: "Increase risk of abdominal pain"
      description: "Taking warfarin can increase your risk of abdominal pain."
      deltaDirection: false

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

    @currentView = "Isotype"
    @comparisonViewItems = ["Isotype", "Violin", "Gradient"]
    @uncertaintyDegree = "1"
    @pointEstimate = "mean"

  selectedAttrs: () ->
    @filterFilter(@attributes, {selected: true})

  continueToVis: () ->
    @selectedDefaults = true

  selectAttribute: (attr) ->
    i = @selectedAttributes.indexOf(attr)
    if i is -1
      attr.selected = true
      @selectedAttributes.push attr
    else
      attr.selected = false
      @selectedAttributes.splice(i, 1)

    
module.controller 'MainCtrl', MainCtrl