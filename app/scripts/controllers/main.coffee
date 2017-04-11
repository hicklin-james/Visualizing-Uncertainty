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
  @$inject: ['$scope', '$interval']
  constructor: (@$scope, @$interval) ->

    @$scope.ctrl = @

    randNum = Math.floor(Math.random() * 100) + 1
    diff = 100 - randNum
      
    @data1 = [
      {
        "value":"#{randNum}",
        "label":"#{randNum} out of 100 (#{randNum}%) will have a stroke.",
        "color":"darkred",
        "sub_value":null
      },
      {
        "value":"#{diff}",
        "label":"#{diff} out of 100 (#{diff}%) will not have a stroke.",
        "color":"#82D78C",
        "sub_value":null
      }
    ]

    randNum2 = Math.floor(Math.random() * 100) + 1
    diff2 = 100 - randNum2

    @data2 = [
      {
        "value":"#{randNum2}",
        "label":"#{randNum2} out of 100 (#{randNum2}%) will have a stroke.",
        "color":"darkred",
        "sub_value":null
      },
      {
        "value":"#{diff2}",
        "label":"#{diff2} out of 100 (#{diff2}%) will not have a stroke.",
        "color":"#82D78C",
        "sub_value":null
      }
    ]

    randNum3 = Math.floor(Math.random() * 100) + 1
    diff3 = 100 - randNum3
      
    @data3 = [
      {
        "value":"#{randNum3}",
        "label":"#{randNum3} out of 100 (#{randNum3}%) will have a major bleed.",
        "color":"darkred",
        "sub_value":null
      },
      {
        "value":"#{diff3}",
        "label":"#{diff3} out of 100 (#{diff3}%) will not have a major bleed.",
        "color":"#82D78C",
        "sub_value":null
      }
    ]

    randNum4 = Math.floor(Math.random() * 100) + 1
    diff4 = 100 - randNum4

    @data4 = [
      {
        "value":"#{randNum4}",
        "label":"#{randNum4} out of 100 (#{randNum4}%) will have a major bleed.",
        "color":"darkred",
        "sub_value":null
      },
      {
        "value":"#{diff4}",
        "label":"#{diff4} out of 100 (#{diff4}%) will not have a major bleed.",
        "color":"#82D78C",
        "sub_value":null
      }
    ]

  resampleStrokeRiskData: () ->
    randNum = Math.floor(Math.random() * 100) + 1
    diff = 100 - randNum
    @data1[0]["value"] = randNum
    @data1[0]["label"] = "#{randNum} out of 100 (#{randNum}%) will have a stroke."
    @data1[1]["value"] = diff
    @data1[1]["label"] = "#{diff} out of 100 (#{diff}%) patients will not have a stroke."

    randNum2 = Math.floor(Math.random() * 100) + 1
    diff2 = 100 - randNum2
    @data2[0]["value"] = randNum2
    @data2[0]["label"] = "#{randNum2} out of 100 (#{randNum2}%) will have a stroke."
    @data2[1]["value"] = diff2
    @data2[1]["label"] = "#{diff2} out of 100 (#{diff2}%) patients will not have a stroke."

  resampleMajorBleedData: () ->
    randNum3 = Math.floor(Math.random() * 100) + 1
    diff3 = 100 - randNum3
    @data3[0]["value"] = randNum3
    @data3[0]["label"] = "#{randNum3} out of 100 (#{randNum3}%) will have a stroke."
    @data3[1]["value"] = diff3
    @data3[1]["label"] = "#{diff3} out of 100 (#{diff3}%) patients will not have a stroke."

    randNum4 = Math.floor(Math.random() * 100) + 1
    diff4 = 100 - randNum4
    @data4[0]["value"] = randNum4
    @data4[0]["label"] = "#{randNum4} out of 100 (#{randNum4}%) will have a stroke."
    @data4[1]["value"] = diff4
    @data4[1]["label"] = "#{diff4} out of 100 (#{diff4}%) patients will not have a stroke."

    # @$interval () =>
    #   randNum = Math.floor(Math.random() * 100) + 1
    #   diff = 100 - randNum
    #   @data1[0]["value"] = randNum
    #   @data1[0]["label"] = "#{randNum} out of 100 (#{randNum}%) will have a stroke."
    #   @data1[1]["value"] = diff
    #   @data1[1]["label"] = "#{diff} out of 100 (#{diff}%) patients will not have a stroke."

    #   randNum2 = Math.floor(Math.random() * 100) + 1
    #   diff2 = 100 - randNum2
    #   @data2[0]["value"] = randNum2
    #   @data2[0]["label"] = "#{randNum2} out of 100 (#{randNum2}%) will have a stroke."
    #   @data2[1]["value"] = diff2
    #   @data2[1]["label"] = "#{diff2} out of 100 (#{diff2}%) patients will not have a stroke."

    # , 5000
module.controller 'MainCtrl', MainCtrl