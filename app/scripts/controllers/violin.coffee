'use strict'

module = angular.module('547ProjectApp')

class ViolinCtrl
  @$inject: ['$scope', '$interval', 'DiseaseAttribute', 'Util', '_']
  constructor: (@$scope, @$interval, @DiseaseAttribute, @Util, @_) ->

    selectedAttributes = @$scope.$parent.$parent.ctrl.selectedAttributes
    @pointEstimate = @$scope.$parent.$parent.ctrl.pointEstimate

    @$scope.ctrl = @

    @convertAttributesToUsableViolinData(selectedAttributes)

    @$scope.$on "chartDataChanged", (event, nv) =>
      @convertAttributesToUsableViolinData(nv)

  convertAttributesToUsableViolinData: (attrs) ->
    @violinData =  @_.map attrs, (attr) ->
      color: if attr.deltaDirection then "lightgreen" else "#ffbfbb"
      data: attr.data
      key: attr.key
      label: attr.shortLabel

module.controller 'ViolinCtrl', ViolinCtrl