'use strict'

app = angular.module('547ProjectApp')

app.directive 'sdIconArray', ['$document', '$window', '$timeout', '_', 'Util', '$sce', ($document, $window, $timeout, _, Util, $sce) ->
  scope:
    data: "=saData"
    numPerRow: "@saNumPerRow"
  template:"<div id='{{chartid}}-wrapper' class='icon-array-chart' style='width: 95%;'>
              <svg id='{{chartid}}'></svg>
            </div>"
  compile: ($element, attr) ->    
      pre: (scope, element) ->
        scope.chartid = Util.makeId()

      post: (scope, element, attrs) ->

        scope.$on '$destroy', () ->
          win.off('resize')

        # deep watch the data, and update data if necessary
        scope.$watch 'data', (nv, ov) ->
          if nv isnt ov
            dataUpdate()
        , true

        initArrayItems = (n, color, selected=false) ->
          items = []
          if n > 0
            for i in [0..n-1]
              item = {
                color: color
              }
              items.push item
          items
        
        # map data structure we can use
        thedata = _.flatten(_.map scope.data, (dp, index) -> initArrayItems(dp.value, dp.color, (index + 1) is parseInt(scope.selectedIndex)))

        # cancel the timeout if the state changes - this prevents
        # errors in d3 when it tries to render the chart AFTER the page
        # has changed and the div no longer exists!
        scope.$on '$stateChangeStart', (e, to, top, from, fromp) =>
          $timeout.cancel(p)

        win = angular.element($window)
        id = "#" + scope.chartid
        wrapperid = id + "-wrapper"
        #console.log wrapperid
        data = scope.data

        biggestDataPoint = _.max(data, (d) -> d.value)
        longestLabel = _.max(data, (d) -> d.label.length)

        itemsPerRow = if scope.numPerRow then parseInt(scope.numPerRow) else 20
        canvas = null
        people = null
        legend = null
        legendItems = null
        chart = null

        textBorderPadding = 3

        ###
          Input:
            headRadius - radius of the head in pixels
            personWrapper - d3 selection for wrapper of person to be drawn
            color - color of person
          Description:
            This function draws a person for an icon array. The body is drawn in proportion
            with the headRadius input, inside the personWrapper input.
        ###
        drawPerson = (headRadius, personWrapper, color) ->
          r = headRadius
          headMidBottomX = r
          headMidBottomY = r
          head = personWrapper.select('circle').attr('r', headRadius * 0.7).attr('cy', 1).attr('stroke-width', 1).attr('stroke', color).attr('fill', color)
          # top line
          bodyStartX = -r
          bodyEndX = r
          bodyStartY = headMidBottomY + r / 3
          # right shoulder curve
          rightShoulderXCurve1 = bodyEndX + r / 3
          rightShoulderYCurve1 = bodyStartY
          rightShoulderXCurve2 = bodyEndX + r / 3
          rightShoulderYCurve2 = bodyStartY + r / 3
          rightShoulderEndX = bodyEndX + r / 3
          rightShoulderEndY = bodyStartY + r / 3
          # right arm outer line
          rightArmEndY = rightShoulderEndY + r * 2
          # right hand curve
          rhcx1 = rightShoulderEndX
          rhcy1 = rightArmEndY + r / 3
          rhcx2 = rightShoulderEndX - (r / 3)
          rhcy2 = rightArmEndY + r / 3
          rhex = rightShoulderEndX - (r / 3)
          rhey = rightArmEndY
          # right arm inner line
          rightArmInnerEndY = rhey - (r * 2) + r / 2
          # right armpit curve
          racx1 = rhex
          racy1 = rightArmInnerEndY - (r / 3)
          racx2 = rhex - (r / 2)
          racy2 = rightArmInnerEndY - (r / 3)
          racex = rhex - (r / 2)
          racey = rightArmInnerEndY
          # right leg outer line
          rightLegOuterEndY = racey + r * 4
          # right foot curve
          rfcx1 = racex
          rfcy1 = rightLegOuterEndY + r / 3
          rfcx2 = racex - (r / 3)
          rfcy2 = rightLegOuterEndY + r / 3
          rfcex = racex - (r / 3)
          rfcey = rightLegOuterEndY
          # right inner leg
          rightInnerLegEndY = rfcey - (r * 2.6)
          # crotch curve
          crx1 = rfcex
          cry1 = rightInnerLegEndY - (r / 3)
          crx2 = -(r * 0.2)
          cry2 = rightInnerLegEndY - (r / 3)
          crex = -(r * 0.2)
          crey = rightInnerLegEndY
          # left inner leg
          leftInnerLegEndY = crey + r * 2.6
          # left foot curve
          lfcx1 = crex
          lfcy1 = leftInnerLegEndY + r / 3
          lfcx2 = crex - (r / 3)
          lfcy2 = leftInnerLegEndY + r / 3
          lfcex = crex - (r / 3)
          lfcey = leftInnerLegEndY
          # left outer leg
          leftOuterLegEndY = rightArmInnerEndY
          # left armpit curve
          lacx1 = lfcex
          lacy1 = leftOuterLegEndY - (r / 3)
          lacx2 = lfcex - (r / 2)
          lacy2 = leftOuterLegEndY - (r / 3)
          lacex = lfcex - (r / 2)
          lacey = leftOuterLegEndY
          # left inner arm
          leftInnerArmEndY = rightArmEndY
          # left hand curve
          lhx1 = lacex
          lhy1 = leftInnerArmEndY + r / 3
          lhx2 = lacex - (r / 3)
          lhy2 = leftInnerArmEndY + r / 3
          lhex = lacex - (r / 3)
          lhey = leftInnerArmEndY
          # left arm outer
          leftOuterArmEndY = rightShoulderEndY
          # left shoulder curve
          lsx1 = lhex
          lsy1 = leftOuterArmEndY - (r / 3)
          lsx2 = bodyStartX
          lsy2 = bodyStartY
          lsex = bodyStartX
          lsey = bodyStartY

          body = personWrapper.select('path').attr('d', ->
            pathString = ''
            pathString += 'M' + bodyStartX + ' ' + bodyStartY
            pathString += ' L ' + bodyEndX + ' ' + bodyStartY
            pathString += ' C ' + rightShoulderXCurve1 + ' ' + rightShoulderYCurve1 + ', ' + rightShoulderXCurve2 + ' ' + rightShoulderYCurve2 + ', ' + rightShoulderEndX + ' ' + rightShoulderEndY
            pathString += ' L ' + rightShoulderEndX + ' ' + rightArmEndY
            pathString += ' C ' + rhcx1 + ' ' + rhcy1 + ', ' + rhcx2 + ' ' + rhcy2 + ', ' + rhex + ' ' + rhey
            pathString += ' L ' + rhex + ' ' + rightArmInnerEndY
            pathString += ' C ' + racx1 + ' ' + racy1 + ', ' + racx2 + ' ' + racy2 + ', ' + racex + ' ' + racey
            pathString += ' L ' + racex + ' ' + rightLegOuterEndY
            pathString += ' C ' + rfcx1 + ' ' + rfcy1 + ', ' + rfcx2 + ' ' + rfcy2 + ', ' + rfcex + ' ' + rfcey
            pathString += ' L ' + rfcex + ' ' + rightInnerLegEndY
            pathString += ' C ' + crx1 + ' ' + cry1 + ', ' + crx2 + ' ' + cry2 + ', ' + crex + ' ' + crey
            pathString += ' L ' + crex + ' ' + leftInnerLegEndY
            pathString += ' C ' + lfcx1 + ' ' + lfcy1 + ', ' + lfcx2 + ' ' + lfcy2 + ', ' + lfcex + ' ' + lfcey
            pathString += ' L ' + lfcex + ' ' + leftOuterLegEndY
            pathString += ' C ' + lacx1 + ' ' + lacy1 + ', ' + lacx2 + ' ' + lacy2 + ', ' + lacex + ' ' + lacey
            pathString += ' L ' + lacex + ' ' + leftInnerArmEndY
            pathString += ' C ' + lhx1 + ' ' + lhy1 + ', ' + lhx2 + ' ' + lhy2 + ', ' + lhex + ' ' + lhey
            pathString += ' L ' + lhex + ' ' + leftOuterArmEndY
            pathString += ' C ' + lsx1 + ' ' + lsy1 + ', ' + lsx2 + ' ' + lsy2 + ', ' + lsex + ' ' + lsey
            pathString
          ).attr('stroke', color)
            .attr('stroke-width', '1').attr('fill', color)

        ###
          Input:
            textItem -> d3 selection for text item to be wrapped
            width -> max width of the text
            label -> label to be written
          Returns:
            Number of lines that text takes.
          Description:
            This function takes the text in a d3 text selection and converts it
            to multiple stacked tspans, to simulate text wrapping. 

            Code adapted from https://bl.ocks.org/mbostock/7555321 and all credit
            to Mike Bostock
        ###
        wrap = (textItem, width, label) ->
          text = d3.select(textItem)
          words = label.split(/\s+/).reverse()
          word = undefined
          line = []
          lineNumber = 0
          lineHeight = 1.1
          y = text.attr('y')
          x = text.attr('x')
          dy = text.attr('dy')
          tspan = text.text(null).append('tspan').attr('x', x).attr('y', y).attr('dy', dy + 'em')
          while word = words.pop()
            line.push word
            tspan.text line.join("\ ")
            if tspan.node().getComputedTextLength() > width
              w = line.pop()
              newText = line.join(" ")
              tspan.text(newText)
              line = [ w ]
              tspan = text.append('tspan').attr('x', x).attr('y', y).attr('dy', ++lineNumber * lineHeight + dy + 'em').text(word)
          return lineNumber + 1

        ###
          Description:
            Main function called when chart data is updated. It deals with transition colors
            of changed data items
        ###
        dataUpdate = () ->
          # update data using d3 data() function
          thedata = _.flatten(_.map scope.data, (dp, index) -> initArrayItems(dp.value, dp.color, (index + 1) is parseInt(scope.selectedIndex)))
          people.data(thedata)
          legendItems.data(scope.data)
          
          # transition body and head colors to new colors if changed
          people.select("path")
            .transition()
            .duration(500)
            .ease("linear")
            .attr("fill", (d) ->
              d.color
            )
            .attr("stroke", (d) ->
              d.color
              )

          people.select("circle")
            .transition()
            .duration(500)
            .ease("linear")
            .attr("fill", (d) ->
              d.color
            )
            .attr("stroke", (d) ->
              d.color
            )

          # adjust legend labels if they have changed
          chartWrapper = d3.select(wrapperid)
          svgWidth = parseInt(chartWrapper.style('width'))
          r = ((svgWidth / itemsPerRow) / 3.5)
          legendItems.select("text")
            .each((d,i) ->
              wrap(this, svgWidth - (1.75*r) - (4 * r) - (1.75 * r) - (2 * textBorderPadding) - 1,  "#{d.value} out of 100 people (#{d.value}%) #{d.label}")
            )

        ###
          Inputs: 
            item -> d3 selection for the legend item wrapper
            currLegendHeight -> the current height of the legend at this update point
            svgWidth -> the width of the current svg element
            r -> the radius of the marker
            d -> item data
          Returns:
            Height of this legend item
          Description:
            Updates an individual legend item
        ###
        updateLegendItem = (item, currLegendHeight, svgWidth, r, d) ->
          text = item.select("text")
          # wrap the text, and return the number of lines
          lines = wrap(text.node(), svgWidth - (1.75*r) - (4 * r) - (1.75 * r) - (2 * textBorderPadding) - 1,  "#{d.value} out of 100 people (#{d.value}%) #{d.label}")
          # get text bounds
          bounds = text.node().getBoundingClientRect()
          # get the height of the text and width of the text
          itemheight = parseInt(bounds.height)
          itemWidth = parseInt(bounds.width) + ((r * 2) + (1.75 * r)) + ((1.75 * r) - r)
          # get the bigger height out of the text height and circle marker diameter
          biggerHeight = Math.max(itemheight, (r*2))
          # move the item down by the current total legend height
          item.attr("transform", (d,ii) => "translate(0," + currLegendHeight + ")")
          # update the legend height
          legendItemHeight = (biggerHeight + (r / 2) + (2 * textBorderPadding))
          # adjust legend marker position
          item.select("circle").attr("cy", r)
            .attr("cx", (1.75*r))
            .attr("cy", ((biggerHeight + (2 * textBorderPadding)) / 2))

          # adjust text y position so that it is vertically centered
          lineHeight = itemheight / lines
          y = ((biggerHeight / 2) / lines) + textBorderPadding
          text
            .attr("y", 0)
            .attr("transform", "translate(0,#{(biggerHeight / 2) + (lineHeight / 2) - ((lines - 1) * (lineHeight / 2))})")
            .attr("dy", 0)

          # wrap again - not sure why this is needed but it seems to fix a wrapping issue :S
          wrap(text.node(), svgWidth - (1.75*r) - (4 * r) - (1.75 * r) - (2 * textBorderPadding) - 1, "#{d.value} out of 100 people (#{d.value}%) #{d.label}")
          # return this legend item's legend height
          legendItemHeight
          

        ###
          Description:
            Main chart update function
        ###
        updateChart = () ->

          chartWrapper = d3.select(wrapperid)
          svgWidth = parseInt(chartWrapper.style('width'))
          r = ((svgWidth / itemsPerRow) / 3.5)
          canvas.style('width', svgWidth + "px")

          rowHeight = (r * 2) + (6*r)

          legendItems.select("text")
            .attr("x", ((r * 2) + (1.75 * r) + textBorderPadding))
            .attr("y", 0)
            .attr("dy", 0)
            .text((d, i) ->
              d.label
            )

          totalLegendHeight = r

          # iterate over each legend item, and keep track of the height as we go
          # once we get to the end of the legend, we know where to start the isotypes
          # from
          legendItems #.select("text")
            .each((d,i) ->
              textItem = d3.select(this)
              totalLegendHeight += updateLegendItem(textItem, totalLegendHeight, svgWidth, r, d)
            )

          # update legend item markers with proper colors
          legendItems.select("circle")
            .attr("r", r)
            .attr("stroke-width", 1)
            .attr("fill", (d) =>
              d.color
            ).attr("stroke", (d) =>
              d.color
            )

          # setup isotype variables
          numRows = Math.ceil(thedata.length / itemsPerRow)
          vertPadding = 10;
          height = (numRows * rowHeight) + totalLegendHeight + vertPadding;
          canvas.style("height", height + "px")

          # transform isotypes to point after legend
          people.attr("transform", (d, i) =>
            col = i % itemsPerRow
            row = Math.floor(i / itemsPerRow )
            return("translate("+((1.75*r)+(col*((2*r) + (r * 1.5))))+","+(totalLegendHeight + ((1.75*r)+(row*(8*r))))+")")
          )

          # for each item, draw a person
          people.each((d, i) ->
            me = d3.select(this)
            drawPerson(r, me, d.color)
          )

        ###
          Description:
            Main drawing function only called once. Mostly used to setup vis structure
            and initialize variables.
        ###
        drawChart = () ->

          canvas = d3.select(id)
          chart = canvas.append('g')
            .attr('class', 'chart-body')
          legend = canvas.append('g')
            .attr('class', 'chart-legend')
            .attr('transform', 'translate(1,0)')

          people = chart.selectAll("g")
            .data(thedata)
            .enter()
            .append("g")

          people.append("circle")
          people.append("path")

          legendItems = legend.selectAll("g")
            .data(scope.data)
            .enter()
            .append("g")

          legendItems.append("circle")
          legendItems.append("text")
            .attr('alignment-baseline', 'middle')
            .style("font-size", "0.9em")

          updateChart()
        
        # tap into window resize event to keep icon arrays intact on resize
        win.on 'resize', () ->
          updateChart(false)

        # wait for dom to render before first draw
        p = $timeout () =>
          drawChart()

]

