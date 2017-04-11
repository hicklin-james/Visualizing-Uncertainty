'use strict'

angular.module('547ProjectApp')
  .factory 'Chads', ['$q', '_', ($q, _) ->
    class Chads
      risks = 
        0:
          risk_estimate: 1.9
          lower_bound: 1.2
          upper_bound: 3.0
        1:
          risk_estimate: 2.8
          lower_bound: 2.0
          upper_bound: 3.0
        2:
          risk_estimate: 4.0
          lower_bound: 3.1
          upper_bound: 5.1
        3:
          risk_estimate: 5.9
          lower_bound: 4.6
          upper_bound: 7.3
        4:
          risk_estimate: 8.5
          lower_bound: 4.6
          upper_bound: 7.3
        5: 
          risk_estimate: 12.5
          lower_bound: 8.2
          upper_bound: 17.5
        6:
          risk_estimate: 18.2
          lower_bound: 10.5
          upper_bound: 27.4

      

      constructor: (C, H, A, D, S2) ->
        @chads_score = C + H + A + D + (2 * S2)

      getRisks: () ->
        risks[@chads_score]
    ]
