'use strict'

angular.module('547ProjectApp')
  .factory 'Util', ['$q', '_', ($q, _) ->

    makeId: () ->
      text = "";
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
      i = 0
      while i < 5
        text += possible.charAt(Math.floor(Math.random() * possible.length))
        i = i + 1

      text
  ]
