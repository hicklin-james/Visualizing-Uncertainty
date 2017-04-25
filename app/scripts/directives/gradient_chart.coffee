'use strict'

app = angular.module('547ProjectApp')

app.directive 'sdGradientPlot', ['$document', '$window', '$timeout', '_', 'Util', '$sce', ($document, $window, $timeout, _, Util, $sce) ->
  scope:
    data: "=saData"
    useNineNineCi: "=saUseNineNineCi"
    pointEstimate: "@saPointEstimate"
  template:"<div id='{{chartid}}-wrapper' class='gradient-chart' style='width: 100%;'>
              <svg id='{{chartid}}'>
                <linearGradient id='Gradient1' x1='0' x2='0' y1='0' y2='1'>
                  <stop offset='0%' stop-color='#7C69AA' stop-opacity='0'/>
                  <stop offset='25%' stop-color='#7C69AA' stop-opacity='0.4'/>
                  <stop offset='100%' stop-color='#7C69AA' stop-opacity='1'/>
                </linearGradient>
                <linearGradient id='Gradient2' x1='0' x2='0' y1='0' y2='1'>
                  <stop offset='0%' stop-color='#7C69AA' stop-opacity='1'/>
                  <stop offset='75%' stop-color='#7C69AA' stop-opacity='0.4'/>
                  <stop offset='100%' stop-color='#7C69AA' stop-opacity='0'/>
                </linearGradient>
                <linearGradient id='Gradient3' x1='0' x2='0' y1='0' y2='1'>
                  <stop offset='0%' stop-color='#F1592F' stop-opacity='0'/>
                  <stop offset='25%' stop-color='#F1592F' stop-opacity='0.4'/>
                  <stop offset='100%' stop-color='#F1592F' stop-opacity='1'/>
                </linearGradient>
                <linearGradient id='Gradient4' x1='0' x2='0' y1='0' y2='1'>
                  <stop offset='0%' stop-color='#F1592F' stop-opacity='1'/>
                  <stop offset='75%' stop-color='#F1592F' stop-opacity='0.4'/>
                  <stop offset='100%' stop-color='#F1592F' stop-opacity='0'/>
                </linearGradient>
              </svg>
            </div>"
  compile: ($element, attr) ->    
      pre: (scope, element) ->
        scope.chartid = Util.makeId()

      post: (scope, element, attrs) ->

        scope.$on '$destroy', () ->
          win.off('resize')

        # grab some scope parameters 
        ciToUse = (if scope.useNineNineCi then "ci99" else "ci95")
        peToUse = scope.pointEstimate

        # initialize bestcase & worstcase toggles
        bestcase = false
        worstcase = false

        # watch for changes in confidence value
        scope.$on 'chartUncertaintyChanged', (event, nv) ->
          if nv is "1"
            ciToUse = "ci95"
          else
            ciToUse = "ci99"

          dataUpdate()

        # watch for changes in the point estimate
        scope.$on 'chartPointEstimateChanged', (event, nv) ->
          peToUse = nv
          dataUpdate()

        # listen for bestcase and worstcase events
        scope.$on 'showBestCase', (e, nv) ->
          worstcase = false
          bestcase = nv
          toggleBestWorstScenarios()

        scope.$on 'showWorstCase', (e, nv) ->
          bestcase = false
          worstcase = nv
          toggleBestWorstScenarios()

        # grab data from the scope
        thedata = scope.data

        # deep watch data for any changes
        scope.$watch 'data', (nv, ov) =>
          if nv isnt ov
            thedata = nv
            dataUpdate()
        , true

        id = "#" + scope.chartid
        wrapperid = id + "-wrapper"

        win = angular.element($window)

        # setup some constants
        markerWidth = 6
        markerHeight = 6

        height = 500
        leftPadding = 90
        rightPadding = 20
        topPadding = 20
        bottomPadding = 180
        minPeHeight = 3
        barWidth = 40

        # initialize selection variables
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

        itemWrapper = null
        items = null
        itemDivs = null
        upperItemRects = null
        lowerItemRects = null
        peRects = null

        mindp = null
        maxdp = null

        bestMarkers = null

        worstMarkers = null
        yPositiveLabel = null
        yNegativeLabel = null
        yAxisLabel = null

        ###
          Description:
            Called whenever changes to the data are made. Updates the y axis
            and adds new items to the chart using the d3 data() function
        ###
        dataUpdate = () ->

          # get new y bounds
          mindp = _.min(thedata, (d) -> d[peToUse] - d[ciToUse])
          maxdp = _.max(thedata, (d) -> d[peToUse] + d[ciToUse])
          
          # update scale and axis
          yScale.domain([mindp[peToUse] - mindp[ciToUse] - 10,maxdp[peToUse] + maxdp[ciToUse] + 10])
          yAxisDrawn
            .transition().duration(500)
            .call(yAxis)

          # add new data
          items = items.data(thedata, (d) -> d.label)
          
          # udpate the chart
          updateChart()

        ###
          Description: 
            The following 6 show/hide questions are helpers to hide and show
            the gradients and/or best/worst scenarios depending on what is 
            toggled
        ###
        showGradientBars = () ->
          items.selectAll(".main-rect").transition().duration(500).style("opacity", "1")

        hideGradientBars = () ->
          items.selectAll(".main-rect").transition().duration(500).style("opacity", "0")

        showBestMarkers = () ->
          items.selectAll(".best-marker").transition().duration(500).style("opacity", "1")

        hideBestMarkers = () ->
          items.selectAll(".best-marker").transition().duration(500).style("opacity", "0")

        showWorstMarkers = () ->
          items.selectAll(".worst-marker").transition().duration(500).style("opacity", "1")

        hideWorstMarkers = () ->
          items.selectAll(".worst-marker").transition().duration(500).style("opacity", "0")


        ###
          Description:
            This function updates the bars for the worst case scenarios
        ###
        updateWorstMarkers = () ->
          worstmarkers = items.select(".worst-marker").transition().duration(500)
            .attr("height", (d) ->
                gradientTop =  yScale(d[peToUse] + d[ciToUse])
                yzero = yScale(0)
                Math.abs(gradientTop - yzero) - (minPeHeight / 2)
            )
            .attr("y", (d) ->
              if d[peToUse] + d[ciToUse] > 0
                # y pos of bottom of gradient bar
                gradientTop = -Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse])) - (minPeHeight / 2)
                gradientTop
              else
                -(Math.abs(yScale(0) - yScale(d[peToUse])))
            )

        ###
          Description:
            This function updates the bars for the best case scenarios
        ###
        updateBestMarkers = () ->
          bestmarkers = items.select(".best-marker").transition().duration(500)
            .attr("height", (d) ->
                gradientBottom = Math.abs(yScale(d[peToUse] - d[ciToUse]))
                yzero = yScale(0)
                Math.abs(gradientBottom - yzero) - (minPeHeight / 2)
            )
            .attr("y", (d) ->
              if d[peToUse] > 0 and d[peToUse] - d[ciToUse] > 0
                # y pos of bottom of gradient bar
                gradientBottom = Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse])) - (minPeHeight / 2)
                gradientBottom
              else if d[peToUse] > 0 and d[peToUse] - d[ciToUse] < 0
                Math.abs(yScale(0) - yScale(d[peToUse]))
              else  
                -(Math.abs(yScale(0) - yScale(d[peToUse])))
            )

        ###
          Description:
            This function updates the gradient bars on the chart with any new
            yAxis changes
        ###
        updateGradientBars = () ->
          # get confidence interval rects
          upperCiRects = items.select(".upper-gradient-rect")
          lowerCiRects = items.select(".lower-gradient-rect")

          # adjust y positions and heights of rects
          upperCiRects.transition().duration(500).attr("height", (d) ->
            Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse] - d[ciToUse])) / 2
          )
          .attr("y", (d) ->
            (minPeHeight / 2) - (Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse] - d[ciToUse])) / 2)
          )

          lowerCiRects.transition().duration(500).attr("height", (d) ->
            Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse] - d[ciToUse])) / 2
          )
          .attr("y", (d) ->
            -(minPeHeight / 2)
          )

        ###
          Description:
            Toggles best/worst case scenari
        ###
        toggleBestWorstScenarios = () ->
          if bestcase
            hideWorstMarkers()
            hideGradientBars()
            showBestMarkers()
          else if worstcase
            hideBestMarkers()
            hideGradientBars()
            showWorstMarkers()
          else
            hideBestMarkers()
            hideWorstMarkers()
            showGradientBars()

        ###
          Description:
            Updates the axis and various associated things 
        ###
        updateAxis = () ->
          # get new x bounds
          chartWrapper = d3.select(wrapperid)
          svgWidth = parseInt(chartWrapper.style('width'))
          canvas.style('width', svgWidth + "px")

          # update xScale
          xScale.domain(_.map(thedata, (d) -> d.label))
            .rangeBands([0, svgWidth-leftPadding-rightPadding])

          # update zeroAxis
          xZeroAxisDrawn.transition().duration(500)
            .attr("transform", "translate(0,#{yScale(0)})")
            .call(xZeroAxis)
          xZeroAxisDrawn.select("path").attr("stroke-dasharray", 5)

          # update xAxis
          xAxisDrawn.transition().duration(500).call(xAxis)
            .selectAll("text")  
            .style("text-anchor", "end")
            .attr("dx", "-.8em")

          # update positive and negative label locations
          yPositiveLabel.transition().duration(500)
            .attr("transform", (d) ->
              yZero = yScale(0)
              yBottom = yScale(mindp[peToUse] - mindp[ciToUse] - 10)
              diff = Math.abs(yZero - yBottom)
              "rotate(270) translate(-#{yZero + (diff / 2)},-45)"
            )

          yNegativeLabel.transition().duration(500)
            .attr("transform", (d) ->
              yZero = yScale(0)

              "rotate(270) translate(-#{yZero / 2},-45)"
            )

          # rotate x axis labels
          xAxisDrawn.selectAll("text")
            .attr("dy", ".15em")
            .attr("transform", "rotate(-40)")
            .style("font-weight", "bold")

        ###
          Description:
            Updates the existing data items in the chart
        ###
        updateExistingItems = () ->
          # update the axis
          updateAxis()

          # get the size of a rangeband so we can calculate the midpoint
          rangeBand = xScale.rangeBand()

          # move items into the middle of the rangeband
          items.transition().duration(500).attr("transform", (d, i) ->
            xTranslate = xScale(d.label) + (rangeBand/2)
            yTranslate = yScale(d[peToUse]) + (minPeHeight / 2)
            "translate(#{xTranslate},#{yTranslate})"
          )

          # update the gradient bars and best/worst bars
          updateGradientBars()
          updateBestMarkers()
          updateWorstMarkers()

        ### 
          Description:
            This function starts off the update. It starts by using the d3 enter()
            function to append new items, and all associated sub-items. It then fires
            off the main drawing functions to update all the positions of everything that
            has been added and the old stuff. It finishes by deleting any items in the
            exit() selection
        ###
        updateChart = () ->

          itemDivs = items.enter()
            .append("g")
            .attr("class", "gradient-item")

          itemOpacity = if bestcase or worstcase then 0 else 1
          bestMarkerOpacity = if bestcase then 1 else 0
          worstMarkerOpacity = if worstcase then 1 else 0

          upperItemRects = itemDivs
            .append("rect")
            .attr("class", "upper-gradient-rect main-rect")
            .attr("width", barWidth)
            .attr("opacity", itemOpacity)
            .attr("stroke", "none")
            .attr("fill", (d) -> if d.direction then "url(#Gradient1)" else "url(#Gradient3)")  
            .attr("x", -barWidth/2)

          lowerItemRects = itemDivs
            .append("rect")
            .attr("class", "lower-gradient-rect main-rect")
            .attr("width", barWidth)
            .attr("opacity", itemOpacity)
            .attr("stroke", "none")
            .attr("fill", (d) -> if d.direction then "url(#Gradient2)" else "url(#Gradient4)")  
            .attr("x", -barWidth/2)

          peRects = itemDivs
            .append("rect")
            .attr("class", "pe-rect main-rect")
            .attr("width", barWidth)
            .attr("opacity", itemOpacity)
            .attr("stroke", "none")
            .attr("fill", (d) -> if d.direction then "#7C69AA" else "#F1592F")
            .attr("x", -barWidth/2)
            .attr("height", minPeHeight)
            .attr("y", -minPeHeight/2)

          bestMarkers = itemDivs
            .append("rect")
            .attr("class", "best-marker")
            .attr("opacity", bestMarkerOpacity)
            .attr("stroke", (d) -> if d.direction then "#7C69AA" else "#F1592F")
            .attr("fill", (d) -> if d.direction then "#7C69AA" else "#F1592F")
            .attr("width", barWidth)
            .attr("x", -barWidth / 2)

          worstMarkers = itemDivs
            .append("rect")
            .attr("class", "worst-marker")
            .attr("opacity", worstMarkerOpacity)
            .attr("stroke", (d) -> if d.direction then "#7C69AA" else "#F1592F")
            .attr("fill", (d) -> if d.direction then "#7C69AA" else "#F1592F")
            .attr("width", barWidth)
            .attr("x", -barWidth / 2)

          itemDivs.attr("transform", "translate(-60,-100)")

          updateExistingItems()

          items.exit().transition().duration(500).attr("transform", "translate(-60,-100)").remove()

        ###
          Description:
            This function draws the initial structure needed to setup the chart. It initializes most
            of the necessary variables
        ###
        drawChart = () ->
          canvas = d3.select(id)
          canvas.style('height', height)
          chart = canvas.append("g")
            .attr("class", "chart-body")
            .attr("transform", "translate(#{leftPadding},#{topPadding})")

          mindp = _.min(thedata, (d) -> d[peToUse] - d[ciToUse])
          maxdp = _.max(thedata, (d) -> d[peToUse] + d[ciToUse])

          yScale = d3.scale.linear()
            .range([height-topPadding-bottomPadding, 0])
            .domain([mindp[peToUse] - mindp[ciToUse] - 10,maxdp[peToUse] + maxdp[ciToUse] + 10])
          
          yAxis = d3.svg.axis().scale(yScale).orient("left")
            .tickFormat((d) -> d3.format(',f')(Math.abs(d)))

          items = chart.selectAll("g")
            .data(thedata, (d) -> d.label)

          xScale = d3.scale.ordinal()

          xAxis = d3.svg.axis().scale(xScale).orient("bottom")
            .ticks(0)

          xZeroAxis = d3.svg.axis().scale(xScale).orient("bottom")
            .ticks(0)
            .outerTickSize(0)
            .tickValues([])
          
          yAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-y-axis")
            .call(yAxis)

          yPositiveLabel = yAxisDrawn.append("text")
            .attr("class", "y-positive-label")
            .text("Decrease")
            .style("font-weight", "bold")
            .attr("text-anchor", 'middle')

          yNegativeLabel = yAxisDrawn.append("text")
            .attr("class", "y-negative-label")
            .text("Increase")
            .style("font-weight", "bold")
            .attr("text-anchor", 'middle')

          yAxisLabel = yAxisDrawn.append("text")
            .attr("class", "y-axis-label")
            .style("font-size", "1.2em")
            .text("Number of people out of 100")
            .style("font-weight", "bold")
            .attr("text-anchor", 'middle')
            .attr("transform", "rotate(270) translate(-#{(height-topPadding-bottomPadding) / 2},-70)")

          xAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-x-axis")
            .attr("transform", "translate(0,#{height-topPadding-bottomPadding})")

          xZeroAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-x-axis")

          updateChart()

        # bind to resize event to adjust scale when resizing
        win.on 'resize', () ->
          updateExistingItems()

        # timeout before initial draw to ensure dom has rendered
        $timeout () ->
          drawChart()
        
]