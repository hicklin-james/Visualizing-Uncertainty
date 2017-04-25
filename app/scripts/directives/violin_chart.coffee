'use strict'

app = angular.module('547ProjectApp')

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
        scope.$on '$destroy', () ->
          win.off('resize')

        # grab scope parameters from directive 
        peToUse = scope.pointEstimate
        thedata = scope.data

        # deep watch the input data for changes, update
        # chart if necessary
        scope.$watch 'data', (nv, ov) ->
          if nv isnt ov
            thedata = nv
            dataUpdate()
        , true

        # when the point estimate type changes, an event will
        # be broadcast. Catch that even and update the data
        scope.$on 'chartPointEstimateChanged', (event, nv) ->
          peToUse = nv
          dataUpdate()

        # set some variables to make chart access easier
        id = "#" + scope.chartid
        wrapperid = id + "-wrapper"

        # get the window to tap into resize events
        win = angular.element($window)

        # constants
        height = 500
        leftPadding = 90
        rightPadding = 20
        topPadding = 20
        bottomPadding = 180

        maxViolinWidth = 70
        boxPlotWidth = 0.2
        imposeMax = 0.25
        resolution = 10
        interpolation = "bundle"

        pointEstimateRadius = 3

        # initializing variables
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

        yPositiveLabel = null
        yNegativeLabel = null
        yAxisLabel = null

        
        ### D3 drawing & updating functions ###
        ### ------------------------------- ###
        
        ###
          Input:
            data -> data to get boxplot quartiles for
          Returns:
            [Float] -> array of floats representing data quartiles 
        ###
        getBoxPlotQuartiles = (itemData) ->
          quartileProbs = [0.05,0.25,0.5,0.75,0.95]
          quartiles = []
          _.each quartileProbs, (q) ->
            # d3.quantile returns quantile at probability for input data
            quartiles.push d3.quantile(itemData, q)
          quartiles

        ### 
          Input:
            item -> d3 selection that represents boxplot wrapper
            d -> data associated with item
            itemXScale -> d3 x scale for box
          Description:
            Updates the box plot attributes with new values according to 
            input `item` corresponding to data `d`    
        ###
        updateBoxPlot = (item, d, itemXScale) ->
          # get bounds for plot
          left = 0.5 - (boxPlotWidth / 2)
          right = 0.5 + (boxPlotWidth / 2)
          
          quartiles = getBoxPlotQuartiles(d.data)

          # update interquartile range rect with new values
          item.select('.iqr')
            .transition().duration(500)
            .attr('x', itemXScale(left))
            .attr('width', itemXScale(right) - itemXScale(left))
            .attr('y', yScale(quartiles[3]))
            .attr('height', -yScale(quartiles[3]) + yScale(quartiles[1]))

          pe = if peToUse is "mean" then yScale(Util.arrMean(d.data)) else yScale(quartiles[2])

          # update point estimate circle with new values
          item.select(".point-estimate")
            .transition().duration(500)
            .attr("cx", itemXScale(left + (boxPlotWidth / 2)))
            .attr("cy", pe)

        ### 
          Input:
            item -> d3 selection that represents violin wrapper
            d -> data associated with item
          Description:
            Updates the violin attributes with new values according to 
            input `item` corresponding to data `d`. The violin creation
            has three main steps:
              1. Get a histogram of the underlying data
              2. Construct an area as if the violin was on the xaxis
              3. Draw the area and rotate 90 degrees - this will show
                 half the violin. Do the same thing again and mirror
                 the area - now we have a full violin.
        ###
        updateViolin = (item, d) ->
          # use d3 histogram layout to bin the data
          violinData = d3.layout.histogram().bins(resolution).frequency(0)(d.data)

          # create scale from 0 to max y-value in binned histogram data. Remember that axis will
          # be flipped so we want max y-value instead of x-value
          x = d3.scale.linear().range([maxViolinWidth / 2, 0])
            .domain([0, _.max(violinData, (d) -> d.y).y])

          # create area function using our scales
          area = d3.svg.area().interpolate(interpolation).x((dd) ->
            yScale(dd.x)
          ).y0(maxViolinWidth / 2).y1((dd) ->
            x(dd.y)
          )

          # grab our violin item wrappers
          gPlus = item.select('.g-plus')
          gMinus = item.select('.g-minus')

          # update violin areas with new data
          gPlus.select('.area').transition().duration(500).attr('d', area(violinData))
            .attr('fill', d.color)
          gMinus.select('.area').transition().duration(500).attr('d', area(violinData))
            .attr('fill', d.color)

          # rotate areas so that they show as violins
          gPlus.attr 'transform', "rotate(90,0,0) translate(0,#{-maxViolinWidth+1})"
          gMinus.attr 'transform', "rotate(90,0,0) scale(1,-1)"


        ###
          Description:
            Helper function that updates the x axis and zero axis with 
            the current data
        ###
        updateXAxis = () ->
          # modify svg width based on parent width
          chartWrapper = d3.select(wrapperid)
          svgWidth = parseInt(chartWrapper.style('width'))
          canvas.style('width', svgWidth + "px")

          # set xscale domain and range based on new width and new data
          xScale
            .domain(_.map(thedata, (d) -> d.label))
            .rangeBands([0, svgWidth-leftPadding-rightPadding])

          # move zero axis to match new yScale
          xZeroAxisDrawn.transition().duration(500)
            .call(xZeroAxis)
            .attr("transform", "translate(0,#{yScale(0)})")

          xZeroAxisDrawn.select("path").attr("stroke-dasharray", 5)

          # rotate and position new labels
          xAxisDrawn.transition().duration(500).call(xAxis)
            .selectAll("text")  
            .style("text-anchor", "end")
            .attr("dx", "-.8em")
            
          xAxisDrawn.selectAll("text")
            .attr("dy", ".15em")
            .attr("transform", "rotate(-40)")
            .style("font-weight", "bold")

        ###
          Description: 
            Update the existing violins in the plot. Updates the x axis,
            axis labels, and all box and violing plots with current data
            set bound to items.
        ###
        updateExistingItems = () ->
          # update x axis
          updateXAxis()

          # update positive & negative y axis labels
          yPositiveLabel.transition().duration(500)
            .attr("transform", (d) ->
              yZero = yScale(0)
              yBottom = yScale(min_bound)
              diff = Math.abs(yZero - yBottom)

              "rotate(270) translate(-#{yZero + (diff / 2)},-45)"
            )

          yNegativeLabel.transition().duration(500)
            .attr("transform", (d) ->
              yZero = yScale(0)

              "rotate(270) translate(-#{yZero / 2},-45)"
            )

          # update all items, including wrapper position, box plot, and
          # violin plot
          rangeBand = xScale.rangeBand()
          items.transition().duration(500)
            .attr("transform", (d,i) -> 
              xTranslate = xScale(d.label) + (rangeBand/2) - (maxViolinWidth/2)
              "translate(#{xTranslate},0)"
            )
            .each((d, i) ->
              x = d3.scale.linear().range([0, maxViolinWidth])
              me = d3.select(this)
              updateBoxPlot(me, d, x)
              updateViolin(me, d)
            )

        ###
          Description:
            Called whenever the data is changed. Calculates new bounds for the y axis,
            adjusts the y axis to correspon to new bounds, binds new data to items
            selection, and calls updateChart helper function.
        ###
        dataUpdate = () ->
          min_max_points = _.map thedata, (d) -> {min: _.min(d.data), max: _.max(d.data)}

          min_bound = _.min(min_max_points, (d) -> d.min).min - 10
          max_bound = _.max(min_max_points, (d) -> d.max).max + 10

          yScale
            .range([height-topPadding-bottomPadding, 0])
            .domain([min_bound, max_bound])
          
          yAxisDrawn
            .transition().duration(500)
            .call(yAxis)

          items = items.data(thedata, (d) -> d.label)
          updateChart()

        ###
          Description:
            Addes & removes new elements in chart using d3 enter() and exit()
        ###
        updateChart = () ->

          # add items in enter() selection
          itemWrappers = items.enter()
            .append("g")
            .attr("class", "item-wrapper")

          gPlus = itemWrappers.append("g").attr("class", "g-plus")
          gMinus = itemWrappers.append("g").attr("class", "g-minus")

          itemWrappers.append("rect")
            .attr("class", "iqr")
            .attr('stroke', "black")
            .attr("stroke-width", 1)
            .attr("fill", "white")

          itemWrappers.append("circle").attr("class", "point-estimate")
            .attr("r", pointEstimateRadius)
            .attr("fill", "white")
            .attr("stroke", "black")

          gPlus.append('path').attr("class", "area")
          gPlus.append('path').attr("class", "violin")
          gMinus.append('path').attr("class", "area")
          gMinus.append('path').attr("class", "violin")

          itemWrappers.attr("transform", "translate(-60,-100)")

          updateExistingItems()

          # remove items in exit() selection by translating offscreen
          items.exit().transition().duration(500).attr("transform", "translate(-60,-100)").remove()
        
        ###
          Description:
            Helper function to draw y axis labels
        ###
        drawYLabels = () ->
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

        ###
          Description:
            Only called once to setup initial chart structure.  Nothing data-dependent
            is drawn yet.
        ###
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
            .tickFormat((d) -> d3.format(',f')(Math.abs(d)))

          items = chart.selectAll("g")
            .data(thedata, (d) -> d.key)
          
          yAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-y-axis")
            .call(yAxis)

          xScale = d3.scale.ordinal()

          xAxis = d3.svg.axis().scale(xScale).orient("bottom")
            .ticks(0)

          xZeroAxis = d3.svg.axis().scale(xScale).orient("bottom")
            .ticks(0)
            .outerTickSize(0)
            .tickValues([])

          xAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-x-axis")
            .attr("transform", "translate(0,#{height-topPadding-bottomPadding})")

          xZeroAxisDrawn = chart.append("g")
            .attr("class", "gradient-plot-x-axis")

          drawYLabels()

          updateChart()
        
        # bind resize event so that window resizes can update the chart
        win.on 'resize', () ->
          updateExistingItems()

        # timeout before initial draw, so that dom is guaranteed to have rendered
        $timeout () =>
          drawChart()
        , 100
]