'use strict'

app = angular.module('547ProjectApp')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdViolinPlot', ['$document', '$window', '$timeout', '_', 'Util', '$sce', ($document, $window, $timeout, _, Util, $sce) ->
  scope:
    data: "=saData"
    pointEstimate: "@saPointEstimate"
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

        peToUse = scope.pointEstimate
        thedata = scope.data

        scope.$watch 'data', (nv, ov) ->
          if nv isnt ov
            thedata = nv
            dataUpdate()
        , true

        scope.$on 'chartPointEstimateChanged', (event, nv) ->
          peToUse = nv
          dataUpdate()

        id = "#" + scope.chartid
        wrapperid = id + "-wrapper"

        win = angular.element($window)

        height = 500
        leftPadding = 30
        rightPadding = 20
        topPadding = 20
        bottomPadding = 180


        canvas = null
        chart = null
        yScale = null
        yAxis = null
        yAxisDrawn = null

        xScale = null
        xAxis = null
        xAxisDrawn = null

        xZeroAxis = null
        xZeroAxisDrawn = null

        items = null
        itemWrappers = null

        min_bound = null
        max_bound = null

        maxViolinWidth = 70
        boxPlotWidth = 0.2
        imposeMax = 0.25
        resolution = 10
        interpolation = "bundle"

        pointEstimateRadius = 3

        # margin = 
        #   top: 10
        #   bottom: 10
        #   left: 35
        #   right: 10
        # #width = 600
        # height = 500
        # boxWidth = 100
        # #boxSpacing = 10
        # domain = [
        #   -10
        #   35
        # ]

        # resolution = 10
        # interpolation = 'step-before'
        # y = d3.scale.linear().range([
        #   height - (margin.bottom)
        #   margin.top
        # ]).domain(domain)
        # yAxis = d3.svg.axis().scale(y).ticks(5).orient('left').tickSize(5, 0, 5)

        # interpolation = 'basis'

        # addViolin = (svg, results, height, width, domain, imposeMax, violinColor) ->
        #   data = d3.layout.histogram().bins(resolution).frequency(0)(results)
        #   y = d3.scale.linear().range([
        #     width / 2
        #     0
        #   ]).domain([
        #     0
        #     Math.max(imposeMax, d3.max(data, (d) ->
        #       d.y
        #     ))
        #   ])
        #   x = d3.scale.linear().range([
        #     height
        #     0
        #   ]).domain(domain).nice()
        #   area = d3.svg.area().interpolate(interpolation).x((d) ->
        #     if interpolation == 'step-before'
        #       return x(d.x + d.dx / 2)
        #     x d.x
        #   ).y0(width / 2).y1((d) ->
        #     y d.y
        #   )
        #   line = d3.svg.line().interpolate(interpolation).x((d) ->
        #     if interpolation == 'step-before'
        #       return x(d.x + d.dx / 2)
        #     x d.x
        #   ).y((d) ->
        #     y d.y
        #   )
        #   gPlus = svg.append('g')
        #   gMinus = svg.append('g')
        #   gPlus.append('path').datum(data).attr('class', 'area').attr('d', area).style 'fill', violinColor
        #   gPlus.append('path').datum(data).attr('class', 'violin').attr('d', line).style 'stroke', violinColor
        #   gMinus.append('path').datum(data).attr('class', 'area').attr('d', area).style 'fill', violinColor
        #   gMinus.append('path').datum(data).attr('class', 'violin').attr('d', line).style 'stroke', violinColor
        #   x = width
        #   gPlus.attr 'transform', 'rotate(90,0,0)  translate(0,-' + width + ')'
        #   #translate(0,-200)");
        #   gMinus.attr 'transform', 'rotate(90,0,0) scale(1,-1)'
        #   return

        # addBoxPlot = (svg, results, height, width, domain, boxPlotWidth, boxColor, boxInsideColor) ->
        #   y = d3.scale.linear().range([
        #     height
        #     0
        #   ]).domain(domain)
        #   x = d3.scale.linear().range([
        #     0
        #     width
        #   ])
        #   left = 0.5 - (boxPlotWidth / 2)
        #   right = 0.5 + boxPlotWidth / 2
        #   probs = [
        #     0.05
        #     0.25
        #     0.5
        #     0.75
        #     0.95
        #   ]
        #   i = 0
        #   while i < probs.length
        #     probs[i] = y(d3.quantile(results, probs[i]))
        #     i++
        #   svg.append('rect').attr('class', 'boxplot fill').attr('x', x(left)).attr('width', x(right) - x(left)).attr('y', probs[3]).attr('height', -probs[3] + probs[1]).style 'fill', boxColor
        #   iS = [
        #     0
        #     2
        #     4
        #   ]
        #   iSclass = [
        #     ''
        #     'median'
        #     ''
        #   ]
        #   iSColor = [
        #     boxColor
        #     boxInsideColor
        #     boxColor
        #   ]
        #   i = 0
        #   while i < iS.length
        #     svg.append('line').attr('class', 'boxplot ' + iSclass[i]).attr('x1', x(left)).attr('x2', x(right)).attr('y1', probs[iS[i]]).attr('y2', probs[iS[i]]).style('fill', iSColor[i]).style 'stroke', iSColor[i]
        #     i++
        #   iS = [
        #     [
        #       0
        #       1
        #     ]
        #     [
        #       3
        #       4
        #     ]
        #   ]
        #   i = 0
        #   while i < iS.length
        #     svg.append('line').attr('class', 'boxplot').attr('x1', x(0.5)).attr('x2', x(0.5)).attr('y1', probs[iS[i][0]]).attr('y2', probs[iS[i][1]]).style 'stroke', boxColor
        #     i++
        #   svg.append('rect').attr('class', 'boxplot').attr('x', x(left)).attr('width', x(right) - x(left)).attr('y', probs[3]).attr('height', -probs[3] + probs[1]).style 'stroke', boxColor
        #   svg.append('circle').attr('class', 'boxplot mean').attr('cx', x(0.5)).attr('cy', y(d3.mean(results))).attr('r', x(boxPlotWidth / 5)).style('fill', boxInsideColor).style 'stroke', 'None'
        #   svg.append('circle').attr('class', 'boxplot mean').attr('cx', x(0.5)).attr('cy', y(d3.mean(results))).attr('r', x(boxPlotWidth / 10)).style('fill', boxColor).style 'stroke', 'None'

        # drawViolinPlot = () ->
        #   chartWrapper = d3.select(wrapperid)
        #   width = parseInt(chartWrapper.style('width'))
        #   x = d3.scale.linear().range([
        #     0
        #     width - margin.right - margin.left
        #   ]).domain([0..results.length])
        #   xAxis = d3.svg.axis().scale(x).ticks(0)
        #   #console.log width
        #   svg = d3.select(id).attr('height', height).attr('width', width)
        #   svg.append('line').attr('class', 'boxplot').attr('x1', margin.left).attr('x2', width - (margin.right)).attr('y1', y(0)).attr 'y2', y(0)
          
        #   itemWidth = (width / results.length) - margin.left - margin.right
        #   midPointItem = itemWidth / 2

        #   i = 0

        #   while i < results.length
        #     leftSpace = (itemWidth * i) + margin.left + midPointItem - (boxWidth / 2)
        #     results[i].data = results[i].data.sort(d3.ascending)
        #     g = svg.append('g').attr('transform', 'translate(' + leftSpace + ',0)')
        #     addViolin g, results[i].data, height, boxWidth, domain, 0.25, results[i].color
        #     addBoxPlot g, results[i].data, height, boxWidth, domain, .15, 'black', 'white'
        #     i++
          
        #   svg.append('g').attr('class', 'axis').attr('transform', 'translate(' + margin.left + ',0)').call yAxis
        #   svg.append('g').attr('class', 'xaxis').attr('transform', "translate(#{margin.left}, #{y(0)})").call xAxis

        drawBoxPlot = (item, d) ->
          y = d3.scale.linear().range([height-topPadding-bottomPadding, 0]).domain([min_bound, max_bound])
          x = d3.scale.linear().range([0, maxViolinWidth])

          left = 0.5 - (boxPlotWidth / 2)
          right = 0.5 + (boxPlotWidth / 2)
          
          quartileProbs = [0.05,0.25,0.5,0.75,0.95]
          quartiles = []
          _.each quartileProbs, (q) ->
            quartiles.push d3.quantile(d.data, q)

          item.select('.iqr')
            .transition().duration(500)
            .attr('x', x(left))
            .attr('width', x(right) - x(left))
            .attr('y', y(quartiles[3]))
            .attr('height', -y(quartiles[3]) + y(quartiles[1]))
            .attr('stroke', "black")
            .attr("stroke-width", 1)
            .attr("fill", "none")

          pe = if peToUse is "mean" then y(Util.arrMean(d.data)) else y(quartiles[2])

          item.select(".point-estimate")
            .transition().duration(500)
            .attr("r", pointEstimateRadius)
            .attr("fill", "white")
            .attr("stroke", "black")
            .attr("cx", x(left + (boxPlotWidth / 2)))
            .attr("cy", pe)

          # item.select(".qr-half")
          #   .transition().duration(500)
          #   .attr('x1', x(left))
          #   .attr('y1', quartiles[2])
          #   .attr('x2', x(left + boxPlotWidth))
          #   .attr('y2', quartiles[2])
          #   .attr("stroke", "black")
          #   .attr("stroke-width", 1)


        drawViolin = (item, d) ->
          violinData = d3.layout.histogram().bins(resolution).frequency(0)(d.data)

          y = d3.scale.linear().range([maxViolinWidth / 2, 0])
            .domain([0, Math.max(imposeMax, d3.max(violinData, (d) -> d.y))])

          x = d3.scale.linear().range([height-bottomPadding-topPadding, 0])
            .domain([min_bound, max_bound])

          area = d3.svg.area().interpolate(interpolation).x((dd) ->
            x(dd.x)
          ).y0(maxViolinWidth / 2).y1((dd) ->
            y(dd.y)
          )

          line = d3.svg.line().interpolate(interpolation).x((dd) ->
            x(dd.x)
          ).y((dd) ->
            y(dd.y)
          )

          gPlus = item.select('.g-plus')
          gMinus = item.select('.g-minus')
          gPlus.select('.area').transition().duration(500).attr('d', area(violinData))
            .attr('fill', d.color)
          gPlus.select('.violin').transition().duration(500).attr('d', line(violinData))
            .attr("stroke-width", 1)
            .attr('stroke', d.color)
            .attr("fill", "none")
          gMinus.select('.area').transition().duration(500).attr('d', area(violinData))
            .attr('fill', d.color)
          gMinus.select('.violin').transition().duration(500).attr('d', line(violinData))
            .attr("stroke-width", 1)
            .attr('stroke', d.color)
            .attr("fill", "none")
          gPlus.attr 'transform', "rotate(90,0,0) translate(0,#{-maxViolinWidth})"
          gMinus.attr 'transform', "rotate(90,0,0) scale(1,-1)"

        updateExistingItems = () ->
          chartWrapper = d3.select(wrapperid)
          svgWidth = parseInt(chartWrapper.style('width'))
          canvas.style('width', svgWidth + "px")

          xScale = d3.scale.ordinal()
            .domain(_.map(thedata, (d) -> d.label))
            .rangeBands([0, svgWidth-leftPadding-rightPadding])

          xAxis = d3.svg.axis().scale(xScale).orient("bottom")
            .ticks(0)

          xZeroAxis = d3.svg.axis().scale(xScale).orient("bottom")
            .ticks(0)
            .outerTickSize(0)
            .tickValues([])

          xZeroAxisDrawn.transition().duration(500)
            .attr("transform", "translate(0,#{yScale(0)})")
            .call(xZeroAxis)

          xZeroAxisDrawn.select("path").attr("stroke-dasharray", 5)

          xAxisDrawn.transition().duration(500).call(xAxis)
            .selectAll("text")  
            .style("text-anchor", "end")
            .attr("dx", "-.8em")
            
          xAxisDrawn.selectAll("text")
            .attr("dy", ".15em")
            .attr("transform", "rotate(-40)");

          rangeBand = xScale.rangeBand()

          items.transition().duration(500)
            .attr("transform", (d,i) -> 
              xTranslate = xScale(d.label) + (rangeBand/2) - (maxViolinWidth/2)
              "translate(#{xTranslate},0)"
            )
            .each((d, i) ->
              drawBoxPlot(d3.select(this), d)
              drawViolin(d3.select(this), d)
            )
          #rangeBand = xScale.rangeBand()

          # items.transition().duration(500).attr("transform", (d, i) ->
          #   xTranslate = xScale(d.label) + (rangeBand/2) - 10
          #   yTranslate = yScale(d[peToUse]+d[ciToUse])
          #   #console.log yTranslate
          #   "translate(#{xTranslate},#{yTranslate})"
          # )

        dataUpdate = () ->
          min_max_points = _.map thedata, (d) -> {min: _.min(d.data), max: _.max(d.data)}

          min_bound = _.min(min_max_points, (d) -> d.min).min - 10
          max_bound = _.max(min_max_points, (d) -> d.max).max + 10

          yScale = d3.scale.linear()
            .range([height-topPadding-bottomPadding, 0])
            .domain([min_bound, max_bound])
          
          yAxis = d3.svg.axis().scale(yScale).orient("left")

          yAxisDrawn
            .transition().duration(500)
            .call(yAxis)

          items = items.data(thedata, (d) -> d.label)
          updateChart()

        updateChart = () ->

          itemWrappers = items.enter()
            .append("g")
            .attr("class", "item-wrapper")

          gPlus = itemWrappers.append("g").attr("class", "g-plus")
          gMinus = itemWrappers.append("g").attr("class", "g-minus")

          itemWrappers.append("rect").attr("class", "iqr")
          itemWrappers.append("line").attr("class", "qr-half")
          itemWrappers.append("circle").attr("class", "point-estimate")

          gPlus.append('path').attr("class", "area")
          gPlus.append('path').attr("class", "violin")
          gMinus.append('path').attr("class", "area")
          gMinus.append('path').attr("class", "violin")

          itemWrappers.attr("transform", "translate(-60,-100)")

          updateExistingItems()

          items.exit().transition().duration(500).attr("transform", "translate(-60,-100)").remove()
        

        drawChart = () ->
          canvas = d3.select(id)
          canvas.style('height', height)
          chart = canvas.append("g")
            .attr("class", "chart-body")
            .attr("transform", "translate(#{leftPadding},#{topPadding})")

          min_max_points = _.map thedata, (d) -> {min: _.min(d.data), max: _.max(d.data)}

          min_bound = _.min(min_max_points, (d) -> d.min).min - 10
          max_bound = _.max(min_max_points, (d) -> d.max).max + 10

          yScale = d3.scale.linear()
            .range([height-topPadding-bottomPadding, 0])
            .domain([min_bound, max_bound])

          yAxis = d3.svg.axis().scale(yScale).orient("left")

          items = chart.selectAll("g")
            .data(thedata, (d) -> d.key)
          
          yAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-y-axis")
            .call(yAxis)

          xAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-x-axis")
            .attr("transform", "translate(0,#{height-topPadding-bottomPadding})")

          xZeroAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-x-axis")

          updateChart()
        
        win.on 'resize', () ->
          updateExistingItems()

        $timeout () =>
          drawChart()
        , 100
]