'use strict'

app = angular.module('547ProjectApp')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdViolinPlot', ['$document', '$window', '$timeout', '_', 'Util', '$sce', ($document, $window, $timeout, _, Util, $sce) ->
  scope:
    data: "=saData"
  template:"<div id='{{chartid}}-wrapper' class='violin-chart' style='width: 100%;'>
              <svg id='{{chartid}}'>
              </svg>
            </div>"
  compile: ($element, attr) ->    
      pre: (scope, element) ->
        scope.chartid = Util.makeId()

      post: (scope, element, attrs) ->
        # colors
        # #BEFAD7, #82D78C, #CD913C, #DE2D26, #A50F15

        scope.$on '$destroy', () ->
          win.off('resize')

        scope.$watch 'data', (nv, ov) ->
          #console.log "CHANGED!"
          if nv isnt ov
            console.log "updated"
            #dataUpdate()
        , true

        id = "#" + scope.chartid
        wrapperid = id + "-wrapper"

        win = angular.element($window)

        results = scope.data

        margin = 
          top: 10
          bottom: 10
          left: 35
          right: 10
        #width = 600
        height = 500
        boxWidth = 100
        #boxSpacing = 10
        domain = [
          -10
          35
        ]

        resolution = 10
        interpolation = 'step-before'
        y = d3.scale.linear().range([
          height - (margin.bottom)
          margin.top
        ]).domain(domain)
        yAxis = d3.svg.axis().scale(y).ticks(5).orient('left').tickSize(5, 0, 5)

        interpolation = 'basis'

        addViolin = (svg, results, height, width, domain, imposeMax, violinColor) ->
          data = d3.layout.histogram().bins(resolution).frequency(0)(results)
          y = d3.scale.linear().range([
            width / 2
            0
          ]).domain([
            0
            Math.max(imposeMax, d3.max(data, (d) ->
              d.y
            ))
          ])
          x = d3.scale.linear().range([
            height
            0
          ]).domain(domain).nice()
          area = d3.svg.area().interpolate(interpolation).x((d) ->
            if interpolation == 'step-before'
              return x(d.x + d.dx / 2)
            x d.x
          ).y0(width / 2).y1((d) ->
            y d.y
          )
          line = d3.svg.line().interpolate(interpolation).x((d) ->
            if interpolation == 'step-before'
              return x(d.x + d.dx / 2)
            x d.x
          ).y((d) ->
            y d.y
          )
          gPlus = svg.append('g')
          gMinus = svg.append('g')
          gPlus.append('path').datum(data).attr('class', 'area').attr('d', area).style 'fill', violinColor
          gPlus.append('path').datum(data).attr('class', 'violin').attr('d', line).style 'stroke', violinColor
          gMinus.append('path').datum(data).attr('class', 'area').attr('d', area).style 'fill', violinColor
          gMinus.append('path').datum(data).attr('class', 'violin').attr('d', line).style 'stroke', violinColor
          x = width
          gPlus.attr 'transform', 'rotate(90,0,0)  translate(0,-' + width + ')'
          #translate(0,-200)");
          gMinus.attr 'transform', 'rotate(90,0,0) scale(1,-1)'
          return

        addBoxPlot = (svg, results, height, width, domain, boxPlotWidth, boxColor, boxInsideColor) ->
          y = d3.scale.linear().range([
            height
            0
          ]).domain(domain)
          x = d3.scale.linear().range([
            0
            width
          ])
          left = 0.5 - (boxPlotWidth / 2)
          right = 0.5 + boxPlotWidth / 2
          probs = [
            0.05
            0.25
            0.5
            0.75
            0.95
          ]
          i = 0
          while i < probs.length
            probs[i] = y(d3.quantile(results, probs[i]))
            i++
          svg.append('rect').attr('class', 'boxplot fill').attr('x', x(left)).attr('width', x(right) - x(left)).attr('y', probs[3]).attr('height', -probs[3] + probs[1]).style 'fill', boxColor
          iS = [
            0
            2
            4
          ]
          iSclass = [
            ''
            'median'
            ''
          ]
          iSColor = [
            boxColor
            boxInsideColor
            boxColor
          ]
          i = 0
          while i < iS.length
            svg.append('line').attr('class', 'boxplot ' + iSclass[i]).attr('x1', x(left)).attr('x2', x(right)).attr('y1', probs[iS[i]]).attr('y2', probs[iS[i]]).style('fill', iSColor[i]).style 'stroke', iSColor[i]
            i++
          iS = [
            [
              0
              1
            ]
            [
              3
              4
            ]
          ]
          i = 0
          while i < iS.length
            svg.append('line').attr('class', 'boxplot').attr('x1', x(0.5)).attr('x2', x(0.5)).attr('y1', probs[iS[i][0]]).attr('y2', probs[iS[i][1]]).style 'stroke', boxColor
            i++
          svg.append('rect').attr('class', 'boxplot').attr('x', x(left)).attr('width', x(right) - x(left)).attr('y', probs[3]).attr('height', -probs[3] + probs[1]).style 'stroke', boxColor
          svg.append('circle').attr('class', 'boxplot mean').attr('cx', x(0.5)).attr('cy', y(d3.mean(results))).attr('r', x(boxPlotWidth / 5)).style('fill', boxInsideColor).style 'stroke', 'None'
          svg.append('circle').attr('class', 'boxplot mean').attr('cx', x(0.5)).attr('cy', y(d3.mean(results))).attr('r', x(boxPlotWidth / 10)).style('fill', boxColor).style 'stroke', 'None'

        drawViolinPlot = () ->
          chartWrapper = d3.select(wrapperid)
          width = parseInt(chartWrapper.style('width'))
          x = d3.scale.linear().range([
            0
            width - margin.right - margin.left
          ]).domain([0..results.length])
          xAxis = d3.svg.axis().scale(x).ticks(0)
          #console.log width
          svg = d3.select(id).attr('height', height).attr('width', width)
          svg.append('line').attr('class', 'boxplot').attr('x1', margin.left).attr('x2', width - (margin.right)).attr('y1', y(0)).attr 'y2', y(0)
          
          itemWidth = (width / results.length) - margin.left - margin.right
          midPointItem = itemWidth / 2

          i = 0

          while i < results.length
            leftSpace = (itemWidth * i) + margin.left + midPointItem - (boxWidth / 2)
            results[i].data = results[i].data.sort(d3.ascending)
            g = svg.append('g').attr('transform', 'translate(' + leftSpace + ',0)')
            addViolin g, results[i].data, height, boxWidth, domain, 0.25, results[i].color
            addBoxPlot g, results[i].data, height, boxWidth, domain, .15, 'black', 'white'
            i++
          
          svg.append('g').attr('class', 'axis').attr('transform', 'translate(' + margin.left + ',0)').call yAxis
          svg.append('g').attr('class', 'xaxis').attr('transform', "translate(#{margin.left}, #{y(0)})").call xAxis
        
        $timeout () =>
          drawViolinPlot()
        , 100
]