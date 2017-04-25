(function() {
  'use strict';
  var app;

  app = angular.module('547ProjectApp');

  app.directive('sdIconArray', [
    '$document', '$window', '$timeout', '_', 'Util', '$sce', function($document, $window, $timeout, _, Util, $sce) {
      return {
        scope: {
          data: "=saData",
          numPerRow: "@saNumPerRow"
        },
        template: "<div id='{{chartid}}-wrapper' class='icon-array-chart' style='width: 95%;'> <svg id='{{chartid}}'></svg> </div>",
        compile: function($element, attr) {
          return {
            pre: function(scope, element) {
              return scope.chartid = Util.makeId();
            },
            post: function(scope, element, attrs) {
              var biggestDataPoint, canvas, chart, data, dataUpdate, drawChart, drawPerson, id, initArrayItems, itemsPerRow, legend, legendItems, longestLabel, p, people, textBorderPadding, thedata, updateChart, win, wrap, wrapperid;
              scope.$on('$destroy', function() {
                return win.off('resize');
              });
              scope.$watch('data', function(nv, ov) {
                if (nv !== ov) {
                  return dataUpdate();
                }
              }, true);
              initArrayItems = function(n, color, selected) {
                var i, item, items, _i, _ref;
                if (selected == null) {
                  selected = false;
                }
                items = [];
                if (n > 0) {
                  for (i = _i = 0, _ref = n - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
                    item = {
                      color: color
                    };
                    items.push(item);
                  }
                }
                return items;
              };
              thedata = _.flatten(_.map(scope.data, function(dp, index) {
                return initArrayItems(dp.value, dp.color, (index + 1) === parseInt(scope.selectedIndex));
              }));
              scope.$on('$stateChangeStart', (function(_this) {
                return function(e, to, top, from, fromp) {
                  return $timeout.cancel(p);
                };
              })(this));
              win = angular.element($window);
              id = "#" + scope.chartid;
              wrapperid = id + "-wrapper";
              data = scope.data;
              biggestDataPoint = _.max(data, function(d) {
                return d.value;
              });
              longestLabel = _.max(data, function(d) {
                return d.label.length;
              });
              itemsPerRow = scope.numPerRow ? parseInt(scope.numPerRow) : 20;
              canvas = null;
              people = null;
              legend = null;
              legendItems = null;
              chart = null;
              textBorderPadding = 3;

              /*
                Input:
                  headRadius - radius of the head in pixels - the body is drawn
                               with respect to the size of the head
                  personWrapper - d3 selection for wrapper of person to be drawn
                  color - color of person
               */
              drawPerson = function(headRadius, personWrapper, color) {
                var body, bodyEndX, bodyStartX, bodyStartY, crex, crey, crx1, crx2, cry1, cry2, head, headMidBottomX, headMidBottomY, lacex, lacey, lacx1, lacx2, lacy1, lacy2, leftInnerArmEndY, leftInnerLegEndY, leftOuterArmEndY, leftOuterLegEndY, lfcex, lfcey, lfcx1, lfcx2, lfcy1, lfcy2, lhex, lhey, lhx1, lhx2, lhy1, lhy2, lsex, lsey, lsx1, lsx2, lsy1, lsy2, r, racex, racey, racx1, racx2, racy1, racy2, rfcex, rfcey, rfcx1, rfcx2, rfcy1, rfcy2, rhcx1, rhcx2, rhcy1, rhcy2, rhex, rhey, rightArmEndY, rightArmInnerEndY, rightInnerLegEndY, rightLegOuterEndY, rightShoulderEndX, rightShoulderEndY, rightShoulderXCurve1, rightShoulderXCurve2, rightShoulderYCurve1, rightShoulderYCurve2;
                r = headRadius;
                headMidBottomX = r;
                headMidBottomY = r;
                head = personWrapper.select('circle').attr('r', headRadius * 0.7).attr('cy', 1).attr('stroke-width', 1).attr('stroke', color).attr('fill', color);
                bodyStartX = -r;
                bodyEndX = r;
                bodyStartY = headMidBottomY + r / 3;
                rightShoulderXCurve1 = bodyEndX + r / 3;
                rightShoulderYCurve1 = bodyStartY;
                rightShoulderXCurve2 = bodyEndX + r / 3;
                rightShoulderYCurve2 = bodyStartY + r / 3;
                rightShoulderEndX = bodyEndX + r / 3;
                rightShoulderEndY = bodyStartY + r / 3;
                rightArmEndY = rightShoulderEndY + r * 2;
                rhcx1 = rightShoulderEndX;
                rhcy1 = rightArmEndY + r / 3;
                rhcx2 = rightShoulderEndX - (r / 3);
                rhcy2 = rightArmEndY + r / 3;
                rhex = rightShoulderEndX - (r / 3);
                rhey = rightArmEndY;
                rightArmInnerEndY = rhey - (r * 2) + r / 2;
                racx1 = rhex;
                racy1 = rightArmInnerEndY - (r / 3);
                racx2 = rhex - (r / 2);
                racy2 = rightArmInnerEndY - (r / 3);
                racex = rhex - (r / 2);
                racey = rightArmInnerEndY;
                rightLegOuterEndY = racey + r * 4;
                rfcx1 = racex;
                rfcy1 = rightLegOuterEndY + r / 3;
                rfcx2 = racex - (r / 3);
                rfcy2 = rightLegOuterEndY + r / 3;
                rfcex = racex - (r / 3);
                rfcey = rightLegOuterEndY;
                rightInnerLegEndY = rfcey - (r * 2.6);
                crx1 = rfcex;
                cry1 = rightInnerLegEndY - (r / 3);
                crx2 = -(r * 0.2);
                cry2 = rightInnerLegEndY - (r / 3);
                crex = -(r * 0.2);
                crey = rightInnerLegEndY;
                leftInnerLegEndY = crey + r * 2.6;
                lfcx1 = crex;
                lfcy1 = leftInnerLegEndY + r / 3;
                lfcx2 = crex - (r / 3);
                lfcy2 = leftInnerLegEndY + r / 3;
                lfcex = crex - (r / 3);
                lfcey = leftInnerLegEndY;
                leftOuterLegEndY = rightArmInnerEndY;
                lacx1 = lfcex;
                lacy1 = leftOuterLegEndY - (r / 3);
                lacx2 = lfcex - (r / 2);
                lacy2 = leftOuterLegEndY - (r / 3);
                lacex = lfcex - (r / 2);
                lacey = leftOuterLegEndY;
                leftInnerArmEndY = rightArmEndY;
                lhx1 = lacex;
                lhy1 = leftInnerArmEndY + r / 3;
                lhx2 = lacex - (r / 3);
                lhy2 = leftInnerArmEndY + r / 3;
                lhex = lacex - (r / 3);
                lhey = leftInnerArmEndY;
                leftOuterArmEndY = rightShoulderEndY;
                lsx1 = lhex;
                lsy1 = leftOuterArmEndY - (r / 3);
                lsx2 = bodyStartX;
                lsy2 = bodyStartY;
                lsex = bodyStartX;
                lsey = bodyStartY;
                return body = personWrapper.select('path').attr('d', function() {
                  var pathString;
                  pathString = '';
                  pathString += 'M' + bodyStartX + ' ' + bodyStartY;
                  pathString += ' L ' + bodyEndX + ' ' + bodyStartY;
                  pathString += ' C ' + rightShoulderXCurve1 + ' ' + rightShoulderYCurve1 + ', ' + rightShoulderXCurve2 + ' ' + rightShoulderYCurve2 + ', ' + rightShoulderEndX + ' ' + rightShoulderEndY;
                  pathString += ' L ' + rightShoulderEndX + ' ' + rightArmEndY;
                  pathString += ' C ' + rhcx1 + ' ' + rhcy1 + ', ' + rhcx2 + ' ' + rhcy2 + ', ' + rhex + ' ' + rhey;
                  pathString += ' L ' + rhex + ' ' + rightArmInnerEndY;
                  pathString += ' C ' + racx1 + ' ' + racy1 + ', ' + racx2 + ' ' + racy2 + ', ' + racex + ' ' + racey;
                  pathString += ' L ' + racex + ' ' + rightLegOuterEndY;
                  pathString += ' C ' + rfcx1 + ' ' + rfcy1 + ', ' + rfcx2 + ' ' + rfcy2 + ', ' + rfcex + ' ' + rfcey;
                  pathString += ' L ' + rfcex + ' ' + rightInnerLegEndY;
                  pathString += ' C ' + crx1 + ' ' + cry1 + ', ' + crx2 + ' ' + cry2 + ', ' + crex + ' ' + crey;
                  pathString += ' L ' + crex + ' ' + leftInnerLegEndY;
                  pathString += ' C ' + lfcx1 + ' ' + lfcy1 + ', ' + lfcx2 + ' ' + lfcy2 + ', ' + lfcex + ' ' + lfcey;
                  pathString += ' L ' + lfcex + ' ' + leftOuterLegEndY;
                  pathString += ' C ' + lacx1 + ' ' + lacy1 + ', ' + lacx2 + ' ' + lacy2 + ', ' + lacex + ' ' + lacey;
                  pathString += ' L ' + lacex + ' ' + leftInnerArmEndY;
                  pathString += ' C ' + lhx1 + ' ' + lhy1 + ', ' + lhx2 + ' ' + lhy2 + ', ' + lhex + ' ' + lhey;
                  pathString += ' L ' + lhex + ' ' + leftOuterArmEndY;
                  pathString += ' C ' + lsx1 + ' ' + lsy1 + ', ' + lsx2 + ' ' + lsy2 + ', ' + lsex + ' ' + lsey;
                  return pathString;
                }).attr('stroke', color).attr('stroke-width', '1').attr('fill', color);
              };
              wrap = function(textItem, width, label) {
                var dy, line, lineHeight, lineNumber, newText, text, tspan, w, word, words, x, y;
                text = d3.select(textItem);
                words = label.split(/\s+/).reverse();
                word = void 0;
                line = [];
                lineNumber = 0;
                lineHeight = 1.1;
                y = text.attr('y');
                x = text.attr('x');
                dy = text.attr('dy');
                tspan = text.text(null).append('tspan').attr('x', x).attr('y', y).attr('dy', dy + 'em');
                while (word = words.pop()) {
                  line.push(word);
                  tspan.text(line.join("\ "));
                  if (tspan.node().getComputedTextLength() > width) {
                    w = line.pop();
                    newText = line.join(" ");
                    tspan.text(newText);
                    line = [w];
                    tspan = text.append('tspan').attr('x', x).attr('y', y).attr('dy', ++lineNumber * lineHeight + dy + 'em').text(word);
                  }
                }
                return lineNumber + 1;
              };
              dataUpdate = function() {
                var chartWrapper, r, svgWidth, totalLegendHeight;
                thedata = _.flatten(_.map(scope.data, function(dp, index) {
                  return initArrayItems(dp.value, dp.color, (index + 1) === parseInt(scope.selectedIndex));
                }));
                people.data(thedata);
                legendItems.data(scope.data);
                people.select("path").transition().duration(500).ease("linear").attr("fill", function(d) {
                  return d.color;
                }).attr("stroke", function(d) {
                  return d.color;
                });
                people.select("circle").transition().duration(500).ease("linear").attr("fill", function(d) {
                  return d.color;
                }).attr("stroke", function(d) {
                  return d.color;
                });
                chartWrapper = d3.select(wrapperid);
                svgWidth = parseInt(chartWrapper.style('width'));
                r = (svgWidth / itemsPerRow) / 3.5;
                totalLegendHeight = r;
                return legendItems.select("text").each(function(d, i) {
                  return wrap(this, svgWidth - (1.75 * r) - (4 * r) - (1.75 * r) - (2 * textBorderPadding) - 1, "" + d.value + " out of 100 people (" + d.value + "%) " + d.label);
                });
              };
              updateChart = function(animate) {
                var chartWrapper, height, numRows, r, rowHeight, svgWidth, totalLegendHeight, vertPadding;
                chartWrapper = d3.select(wrapperid);
                svgWidth = parseInt(chartWrapper.style('width'));
                r = (svgWidth / itemsPerRow) / 3.5;
                canvas.style('width', svgWidth + "px");
                rowHeight = (r * 2) + (6 * r);
                legendItems.select("text").attr("x", (r * 2) + (1.75 * r) + textBorderPadding).attr("y", 0).attr("dy", 0).text(function(d, i) {
                  return d.label;
                });
                totalLegendHeight = r;
                legendItems.select("text").each(function(d, i) {
                  var biggerHeight, bounds, itemWidth, itemheight, lineHeight, lines, parent, y;
                  lines = wrap(this, svgWidth - (1.75 * r) - (4 * r) - (1.75 * r) - (2 * textBorderPadding) - 1, "" + d.value + " out of 100 people (" + d.value + "%) " + d.label);
                  parent = d3.select(this.parentNode);
                  bounds = this.getBoundingClientRect();
                  itemheight = parseInt(bounds.height);
                  itemWidth = parseInt(bounds.width) + ((r * 2) + (1.75 * r)) + ((1.75 * r) - r);
                  biggerHeight = Math.max(itemheight, r * 2);
                  parent.attr("transform", (function(_this) {
                    return function(d, ii) {
                      return "translate(0," + totalLegendHeight + ")";
                    };
                  })(this));
                  totalLegendHeight += biggerHeight + (r / 2) + (2 * textBorderPadding);
                  parent.select("circle").attr("cy", r).attr("cx", 1.75 * r).attr("cy", (biggerHeight + (2 * textBorderPadding)) / 2);
                  lineHeight = itemheight / lines;
                  y = ((biggerHeight / 2) / lines) + textBorderPadding;
                  d3.select(this).attr("y", 0).attr("transform", "translate(0," + ((biggerHeight / 2) + (lineHeight / 2) - ((lines - 1) * (lineHeight / 2))) + ")").attr("dy", 0);
                  return lines = wrap(this, svgWidth - (1.75 * r) - (4 * r) - (1.75 * r) - (2 * textBorderPadding) - 1, "" + d.value + " out of 100 people (" + d.value + "%) " + d.label);
                });
                legendItems.select("circle").attr("r", r).attr("stroke-width", 1).attr("fill", (function(_this) {
                  return function(d) {
                    return d.color;
                  };
                })(this)).attr("stroke", (function(_this) {
                  return function(d) {
                    return d.color;
                  };
                })(this));
                numRows = Math.ceil(thedata.length / itemsPerRow);
                vertPadding = 10;
                height = (numRows * rowHeight) + totalLegendHeight + vertPadding;
                canvas.style("height", height + "px");
                people.attr("transform", (function(_this) {
                  return function(d, i) {
                    var col, row;
                    col = i % itemsPerRow;
                    row = Math.floor(i / itemsPerRow);
                    return "translate(" + ((1.75 * r) + (col * ((2 * r) + (r * 1.5)))) + "," + (totalLegendHeight + ((1.75 * r) + (row * (8 * r)))) + ")";
                  };
                })(this));
                return people.each(function(d, i) {
                  var me;
                  me = d3.select(this);
                  return drawPerson(r, me, d.color);
                });
              };
              drawChart = function() {
                canvas = d3.select(id);
                chart = canvas.append('g').attr('class', 'chart-body');
                legend = canvas.append('g').attr('class', 'chart-legend').attr('transform', 'translate(1,0)');
                people = chart.selectAll("g").data(thedata).enter().append("g");
                people.append("circle");
                people.append("path");
                legendItems = legend.selectAll("g").data(scope.data).enter().append("g");
                legendItems.append("circle");
                legendItems.append("text").attr('alignment-baseline', 'middle').style("font-size", "0.9em");
                return updateChart();
              };
              win.on('resize', function() {
                return updateChart(false);
              });
              return p = $timeout((function(_this) {
                return function() {
                  return drawChart();
                };
              })(this));
            }
          };
        }
      };
    }
  ]);

}).call(this);

//# sourceMappingURL=icon_array_chart.js.map
