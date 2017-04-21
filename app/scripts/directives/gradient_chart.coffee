'use strict'

app = angular.module('547ProjectApp')

# when clicking the element, it will trigger a browser back operation
app.directive 'sdGradientPlot', ['$document', '$window', '$timeout', '_', 'Util', '$sce', ($document, $window, $timeout, _, Util, $sce) ->
  scope:
    data: "=saData"
    useNineNineCi: "=saUseNineNineCi"
    pointEstimate: "@saPointEstimate"
  template:"<div id='{{chartid}}-wrapper' class='gradient-chart' style='width: 100%;'>
              <svg id='{{chartid}}'>
                <linearGradient id='Gradient1' x1='0' x2='0' y1='0' y2='1'>
                  <stop offset='0%' stop-color='lightgreen' stop-opacity='0'/>
                  <stop offset='10%' stop-color='lightgreen' stop-opacity='0.4'/>
                  <stop offset='50%' stop-color='lightgreen' stop-opacity='1'/>
                  <stop offset='90%' stop-color='lightgreen' stop-opacity='0.4'/>
                  <stop offset='100%' stop-color='lightgreen' stop-opacity='0'/>
                </linearGradient>
                <linearGradient id='Gradient2' x1='0' x2='0' y1='0' y2='1'>
                  <stop offset='0%' stop-color='#ffbfbb' stop-opacity='0'/>
                  <stop offset='10%' stop-color='#ffbfbb' stop-opacity='0.4'/>
                  <stop offset='50%' stop-color='#ffbfbb' stop-opacity='1'/>
                  <stop offset='90%' stop-color='#ffbfbb' stop-opacity='0.4'/>
                  <stop offset='100%' stop-color='#ffbfbb' stop-opacity='0'/>
                </linearGradient>
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

        ciToUse = (if scope.useNineNineCi then "ci99" else "ci95")
        peToUse = scope.pointEstimate

        scope.$on 'chartUncertaintyChanged', (event, nv) ->
          if nv is "1"
            ciToUse = "ci95"
          else
            ciToUse = "ci99"

          dataUpdate()

        scope.$on 'chartPointEstimateChanged', (event, nv) ->
          peToUse = nv
          dataUpdate()

        thedata = scope.data

        scope.$watch 'data', (nv, ov) =>
          #console.log "CHANGED!"
          if nv isnt ov
            thedata = nv
            dataUpdate()
            #dataUpdate()
        , true

        id = "#" + scope.chartid
        wrapperid = id + "-wrapper"

        win = angular.element($window)

        height = 500
        leftPadding = 30
        rightPadding = 20
        topPadding = 20
        bottomPadding = 150

        barWidth = 20

        canvas = null
        chart = null
        yScale = null
        yAxis = null
        yAxisDrawn = null

        xScale = null
        xAxis = null
        xAxisDrawn = null

        itemWrapper = null
        items = null
        itemDivs = null
        itemRects = null

        dataUpdate = () ->
          
          yScale = d3.scale.linear()
            .range([height-topPadding-bottomPadding, 0])
            .domain([_.min(thedata, (d) -> d[peToUse])[peToUse] - 10,_.max(thedata, (d) -> d[peToUse])[peToUse] + 10])
          
          yAxis = d3.svg.axis().scale(yScale).orient("left")

          yAxisDrawn
            .transition().duration(500)
            .call(yAxis)

          items = items.data(thedata, (d) -> d.label)
          updateChart(true)

        updateExistingItems = () ->
          chartWrapper = d3.select(wrapperid)
          svgWidth = parseInt(chartWrapper.style('width'))
          canvas.style('width', svgWidth + "px")

          xScale = d3.scale.ordinal()
            .domain(_.map(thedata, (d) -> d.label))
            .rangeBands([0, svgWidth-leftPadding-rightPadding])

          xAxis = d3.svg.axis().scale(xScale).orient("bottom")
            .ticks(0)

          xAxisDrawn.transition().duration(500).call(xAxis)
            .selectAll("text")  
            .style("text-anchor", "end")
            .attr("dx", "-.8em")
            .attr("dy", ".15em")
            .attr("transform", "rotate(-40)");

          rangeBand = xScale.rangeBand()

          items.transition().duration(500).attr("transform", (d, i) ->
            xTranslate = xScale(d.label) + (rangeBand/2) - 10
            yTranslate = yScale(d[peToUse]+d[ciToUse])
            #console.log yTranslate
            "translate(#{xTranslate},#{yTranslate})"
          )

          rects = chart.selectAll(".gradient-rect")
          rects.attr("width", barWidth)
            .attr("stroke", "none")
            .attr("fill", (d) -> if d.direction then "url(#Gradient1)" else "url(#Gradient2)")
          
          rects.transition().duration(500).attr("height", (d) -> 
            Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse] - d[ciToUse]))
          )

        updateChart = (animate=false) ->

          itemDivs = items.enter()
            .append("g")
            .attr("class", "gradient-item")

          itemRects = itemDivs
            .append("rect")
            .attr("class", "gradient-rect")

          itemDivs.attr("transform", "translate(-60,-100)")

          updateExistingItems()

          items.exit().transition().duration(500).attr("transform", "translate(-60,-100)").remove()


        drawChart = () ->
          canvas = d3.select(id)
          canvas.style('height', height)
          chart = canvas.append("g")
            .attr("class", "chart-body")
            .attr("transform", "translate(#{leftPadding},#{topPadding})")

          yScale = d3.scale.linear()
            .range([height-topPadding-bottomPadding, 0])
            .domain([_.min(thedata, (d) -> d[peToUse])[peToUse] - 10,_.max(thedata, (d) -> d[peToUse])[peToUse] + 10])

          yAxis = d3.svg.axis().scale(yScale).orient("left")

          items = chart.selectAll("g")
            .data(thedata, (d) -> d.label)
          
          yAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-y-axis")
            .call(yAxis)

          xAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-x-axis")
            .attr("transform", "translate(0,#{height-topPadding-bottomPadding})")

          #itemDivs = items.attr("class", "gradient-item")

          #itemRects = itemDivs.append("rect")
          #  .attr("class", "gradient-rect")

          updateChart()

        win.on 'resize', () ->
          updateExistingItems()

        $timeout () ->
          drawChart()
        
]