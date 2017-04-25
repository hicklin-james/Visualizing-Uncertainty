(function() {
  'use strict';
  var app;

  app = angular.module('547ProjectApp');

  app.directive('sdGradientPlot', [
    '$document', '$window', '$timeout', '_', 'Util', '$sce', function($document, $window, $timeout, _, Util, $sce) {
      return {
        scope: {
          data: "=saData",
          useNineNineCi: "=saUseNineNineCi",
          pointEstimate: "@saPointEstimate"
        },
        template: "<div id='{{chartid}}-wrapper' class='gradient-chart' style='width: 100%;'> <svg id='{{chartid}}'> <linearGradient id='Gradient1' x1='0' x2='0' y1='0' y2='1'> <stop offset='0%' stop-color='#7C69AA' stop-opacity='0'/> <stop offset='25%' stop-color='#7C69AA' stop-opacity='0.4'/> <stop offset='100%' stop-color='#7C69AA' stop-opacity='1'/> </linearGradient> <linearGradient id='Gradient2' x1='0' x2='0' y1='0' y2='1'> <stop offset='0%' stop-color='#7C69AA' stop-opacity='1'/> <stop offset='75%' stop-color='#7C69AA' stop-opacity='0.4'/> <stop offset='100%' stop-color='#7C69AA' stop-opacity='0'/> </linearGradient> <linearGradient id='Gradient3' x1='0' x2='0' y1='0' y2='1'> <stop offset='0%' stop-color='#F1592F' stop-opacity='0'/> <stop offset='25%' stop-color='#F1592F' stop-opacity='0.4'/> <stop offset='100%' stop-color='#F1592F' stop-opacity='1'/> </linearGradient> <linearGradient id='Gradient4' x1='0' x2='0' y1='0' y2='1'> <stop offset='0%' stop-color='#F1592F' stop-opacity='1'/> <stop offset='75%' stop-color='#F1592F' stop-opacity='0.4'/> <stop offset='100%' stop-color='#F1592F' stop-opacity='0'/> </linearGradient> </svg> </div>",
        compile: function($element, attr) {
          return {
            pre: function(scope, element) {
              return scope.chartid = Util.makeId();
            },
            post: function(scope, element, attrs) {
              var barWidth, bestMarkers, bestcase, bottomPadding, canvas, chart, ciToUse, dataUpdate, drawBestMarkers, drawChart, drawGradientBars, drawWorstMarkers, height, hideBestMarkers, hideGradientBars, hideWorstMarkers, id, itemDivs, itemWrapper, items, leftPadding, lowerItemRects, markerHeight, markerWidth, maxdp, minPeHeight, mindp, peRects, peToUse, rightPadding, showBestMarkers, showGradientBars, showWorstMarkers, thedata, toggleBestCase, toggleBestWorstScenarios, toggleWorstCase, topPadding, updateAxis, updateChart, updateExistingItems, upperItemRects, win, worstMarkers, worstcase, wrapperid, xAxis, xAxisDrawn, xScale, xZeroAxis, xZeroAxisDrawn, yAxis, yAxisDrawn, yAxisLabel, yNegativeLabel, yPositiveLabel, yScale;
              scope.$on('$destroy', function() {
                return win.off('resize');
              });
              ciToUse = (scope.useNineNineCi ? "ci99" : "ci95");
              peToUse = scope.pointEstimate;
              bestcase = false;
              worstcase = false;
              scope.$on('chartUncertaintyChanged', function(event, nv) {
                if (nv === "1") {
                  ciToUse = "ci95";
                } else {
                  ciToUse = "ci99";
                }
                return dataUpdate();
              });
              scope.$on('chartPointEstimateChanged', function(event, nv) {
                peToUse = nv;
                return dataUpdate();
              });
              scope.$on('showBestCase', function(e, nv) {
                worstcase = false;
                bestcase = nv;
                return toggleBestWorstScenarios();
              });
              scope.$on('showWorstCase', function(e, nv) {
                bestcase = false;
                worstcase = nv;
                return toggleBestWorstScenarios();
              });
              thedata = scope.data;
              scope.$watch('data', (function(_this) {
                return function(nv, ov) {
                  if (nv !== ov) {
                    thedata = nv;
                    return dataUpdate();
                  }
                };
              })(this), true);
              id = "#" + scope.chartid;
              wrapperid = id + "-wrapper";
              win = angular.element($window);
              markerWidth = 6;
              markerHeight = 6;
              height = 500;
              leftPadding = 90;
              rightPadding = 20;
              topPadding = 20;
              bottomPadding = 180;
              barWidth = 40;
              canvas = null;
              chart = null;
              yScale = null;
              yAxis = null;
              yAxisDrawn = null;
              xScale = null;
              xAxis = null;
              xAxisDrawn = null;
              xZeroAxis = null;
              xZeroAxisDrawn = null;
              itemWrapper = null;
              items = null;
              itemDivs = null;
              upperItemRects = null;
              lowerItemRects = null;
              peRects = null;
              mindp = null;
              maxdp = null;
              bestMarkers = null;
              worstMarkers = null;
              yPositiveLabel = null;
              yNegativeLabel = null;
              yAxisLabel = null;
              minPeHeight = 3;
              dataUpdate = function() {
                mindp = _.min(thedata, function(d) {
                  return d[peToUse] - d[ciToUse];
                });
                maxdp = _.max(thedata, function(d) {
                  return d[peToUse] + d[ciToUse];
                });
                yScale = d3.scale.linear().range([height - topPadding - bottomPadding, 0]).domain([mindp[peToUse] - mindp[ciToUse] - 10, maxdp[peToUse] + maxdp[ciToUse] + 10]);
                yAxis = d3.svg.axis().scale(yScale).orient("left").tickFormat(function(d) {
                  return d3.format(',f')(Math.abs(d));
                });
                yAxisDrawn.transition().duration(500).call(yAxis);
                items = items.data(thedata, function(d) {
                  return d.label;
                });
                return updateChart();
              };
              showGradientBars = function() {
                return items.selectAll(".main-rect").transition().duration(500).style("opacity", "1");
              };
              hideGradientBars = function() {
                return items.selectAll(".main-rect").transition().duration(500).style("opacity", "0");
              };
              showBestMarkers = function() {
                return items.selectAll(".best-marker").transition().duration(500).style("opacity", "1");
              };
              hideBestMarkers = function() {
                return items.selectAll(".best-marker").transition().duration(500).style("opacity", "0");
              };
              showWorstMarkers = function() {
                return items.selectAll(".worst-marker").transition().duration(500).style("opacity", "1");
              };
              hideWorstMarkers = function() {
                return items.selectAll(".worst-marker").transition().duration(500).style("opacity", "0");
              };
              drawWorstMarkers = function() {
                var worstmarkers;
                return worstmarkers = items.select(".worst-marker").transition().duration(500).attr("width", barWidth).attr("height", function(d) {
                  var gradientTop, yzero;
                  gradientTop = yScale(d[peToUse] + d[ciToUse]);
                  yzero = yScale(0);
                  return Math.abs(gradientTop - yzero) - (minPeHeight / 2);
                }).attr("y", function(d) {
                  var gradientTop;
                  if (d[peToUse] + d[ciToUse] > 0) {
                    gradientTop = -Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse])) - (minPeHeight / 2);
                    return gradientTop;
                  } else {
                    return -(Math.abs(yScale(0) - yScale(d[peToUse])));
                  }
                }).attr("x", -barWidth / 2);
              };
              drawBestMarkers = function() {
                var bestmarkers;
                return bestmarkers = items.select(".best-marker").transition().duration(500).attr("width", barWidth).attr("height", function(d) {
                  var gradientBottom, yzero;
                  gradientBottom = Math.abs(yScale(d[peToUse] - d[ciToUse]));
                  yzero = yScale(0);
                  return Math.abs(gradientBottom - yzero) - (minPeHeight / 2);
                }).attr("y", function(d) {
                  var gradientBottom;
                  if (d[peToUse] > 0 && d[peToUse] - d[ciToUse] > 0) {
                    gradientBottom = Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse])) - (minPeHeight / 2);
                    return gradientBottom;
                  } else if (d[peToUse] > 0 && d[peToUse] - d[ciToUse] < 0) {
                    return Math.abs(yScale(0) - yScale(d[peToUse]));
                  } else {
                    return -(Math.abs(yScale(0) - yScale(d[peToUse])));
                  }
                }).attr("x", -barWidth / 2);
              };
              drawGradientBars = function() {
                var lowerCiRects, upperCiRects;
                peRects = items.select(".pe-rect").attr("stroke", "none").attr("fill", function(d) {
                  if (d.direction) {
                    return "#7C69AA";
                  } else {
                    return "#F1592F";
                  }
                }).attr("x", -barWidth / 2);
                upperCiRects = items.select(".upper-gradient-rect");
                upperCiRects.attr("stroke", "none").attr("fill", function(d) {
                  if (d.direction) {
                    return "url(#Gradient1)";
                  } else {
                    return "url(#Gradient3)";
                  }
                }).attr("x", -barWidth / 2);
                lowerCiRects = items.select(".lower-gradient-rect");
                lowerCiRects.attr("stroke", "none").attr("fill", function(d) {
                  if (d.direction) {
                    return "url(#Gradient2)";
                  } else {
                    return "url(#Gradient4)";
                  }
                }).attr("x", -barWidth / 2);
                peRects.transition().duration(500).attr("height", minPeHeight).attr("y", -minPeHeight / 2);
                upperCiRects.transition().duration(500).attr("height", function(d) {
                  return Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse] - d[ciToUse])) / 2;
                }).attr("y", function(d) {
                  return (minPeHeight / 2) - (Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse] - d[ciToUse])) / 2);
                });
                return lowerCiRects.transition().duration(500).attr("height", function(d) {
                  return Math.abs(yScale(d[peToUse] + d[ciToUse]) - yScale(d[peToUse] - d[ciToUse])) / 2;
                }).attr("y", function(d) {
                  return -(minPeHeight / 2);
                });
              };
              toggleBestWorstScenarios = function() {
                if (bestcase) {
                  hideWorstMarkers();
                  hideGradientBars();
                  return showBestMarkers();
                } else if (worstcase) {
                  hideBestMarkers();
                  hideGradientBars();
                  return showWorstMarkers();
                } else {
                  hideBestMarkers();
                  hideWorstMarkers();
                  return showGradientBars();
                }
              };
              toggleBestCase = function() {
                if (bestcase) {
                  hideGradientBars();
                  return showBestMarkers();
                } else {
                  showGradientBars();
                  return hideBestMarkers();
                }
              };
              toggleWorstCase = function() {
                if (worstcase) {
                  hideGradientBars();
                  return showWorstMarkers();
                } else {
                  showGradientBars();
                  return hideWorstMarkers();
                }
              };
              updateAxis = function() {
                var chartWrapper, svgWidth;
                chartWrapper = d3.select(wrapperid);
                svgWidth = parseInt(chartWrapper.style('width'));
                canvas.style('width', svgWidth + "px");
                xScale = d3.scale.ordinal().domain(_.map(thedata, function(d) {
                  return d.label;
                })).rangeBands([0, svgWidth - leftPadding - rightPadding]);
                xAxis = d3.svg.axis().scale(xScale).orient("bottom").ticks(0);
                xZeroAxis = d3.svg.axis().scale(xScale).orient("bottom").ticks(0).outerTickSize(0).tickValues([]);
                xZeroAxisDrawn.transition().duration(500).attr("transform", "translate(0," + (yScale(0)) + ")").call(xZeroAxis);
                xZeroAxisDrawn.select("path").attr("stroke-dasharray", 5);
                xAxisDrawn.transition().duration(500).call(xAxis).selectAll("text").style("text-anchor", "end").attr("dx", "-.8em");
                yPositiveLabel.transition().duration(500).attr("transform", function(d) {
                  var diff, yBottom, yZero;
                  yZero = yScale(0);
                  yBottom = yScale(mindp[peToUse] - mindp[ciToUse] - 10);
                  diff = Math.abs(yZero - yBottom);
                  return "rotate(270) translate(-" + (yZero + (diff / 2)) + ",-45)";
                });
                yNegativeLabel.transition().duration(500).attr("transform", function(d) {
                  var yZero;
                  yZero = yScale(0);
                  return "rotate(270) translate(-" + (yZero / 2) + ",-45)";
                });
                return xAxisDrawn.selectAll("text").attr("dy", ".15em").attr("transform", "rotate(-40)").style("font-weight", "bold");
              };
              updateExistingItems = function() {
                var rangeBand;
                updateAxis();
                rangeBand = xScale.rangeBand();
                items.transition().duration(500).attr("transform", function(d, i) {
                  var xTranslate, yTranslate;
                  xTranslate = xScale(d.label) + (rangeBand / 2);
                  yTranslate = yScale(d[peToUse]) + (minPeHeight / 2);
                  return "translate(" + xTranslate + "," + yTranslate + ")";
                });
                drawGradientBars();
                drawBestMarkers();
                return drawWorstMarkers();
              };
              updateChart = function(animate) {
                var bestMarkerOpacity, itemOpacity, worstMarkerOpacity;
                if (animate == null) {
                  animate = false;
                }
                itemDivs = items.enter().append("g").attr("class", "gradient-item");
                itemOpacity = bestcase || worstcase ? 0 : 1;
                bestMarkerOpacity = bestcase ? 1 : 0;
                worstMarkerOpacity = worstcase ? 1 : 0;
                upperItemRects = itemDivs.append("rect").attr("class", "upper-gradient-rect main-rect").attr("width", barWidth).attr("opacity", itemOpacity);
                lowerItemRects = itemDivs.append("rect").attr("class", "lower-gradient-rect main-rect").attr("width", barWidth).attr("opacity", itemOpacity);
                peRects = itemDivs.append("rect").attr("class", "pe-rect main-rect").attr("width", barWidth).attr("opacity", itemOpacity);
                bestMarkers = itemDivs.append("rect").attr("class", "best-marker").attr("opacity", bestMarkerOpacity).attr("stroke", function(d) {
                  if (d.direction) {
                    return "#7C69AA";
                  } else {
                    return "#F1592F";
                  }
                }).attr("fill", function(d) {
                  if (d.direction) {
                    return "#7C69AA";
                  } else {
                    return "#F1592F";
                  }
                });
                worstMarkers = itemDivs.append("rect").attr("class", "worst-marker").attr("opacity", worstMarkerOpacity).attr("stroke", function(d) {
                  if (d.direction) {
                    return "#7C69AA";
                  } else {
                    return "#F1592F";
                  }
                }).attr("fill", function(d) {
                  if (d.direction) {
                    return "#7C69AA";
                  } else {
                    return "#F1592F";
                  }
                });
                itemDivs.attr("transform", "translate(-60,-100)");
                updateExistingItems();
                return items.exit().transition().duration(500).attr("transform", "translate(-60,-100)").remove();
              };
              drawChart = function() {
                canvas = d3.select(id);
                canvas.style('height', height);
                chart = canvas.append("g").attr("class", "chart-body").attr("transform", "translate(" + leftPadding + "," + topPadding + ")");
                mindp = _.min(thedata, function(d) {
                  return d[peToUse] - d[ciToUse];
                });
                maxdp = _.max(thedata, function(d) {
                  return d[peToUse] + d[ciToUse];
                });
                yScale = d3.scale.linear().range([height - topPadding - bottomPadding, 0]).domain([mindp[peToUse] - mindp[ciToUse] - 10, maxdp[peToUse] + maxdp[ciToUse] + 10]);
                yAxis = d3.svg.axis().scale(yScale).orient("left").tickFormat(function(d) {
                  return d3.format(',f')(Math.abs(d));
                });
                items = chart.selectAll("g").data(thedata, function(d) {
                  return d.label;
                });
                yAxisDrawn = chart.append("g").attr("class", "gradient-plot-y-axis").call(yAxis);
                yPositiveLabel = yAxisDrawn.append("text").attr("class", "y-positive-label").text("Decrease").style("font-weight", "bold").attr("text-anchor", 'middle');
                yNegativeLabel = yAxisDrawn.append("text").attr("class", "y-negative-label").text("Increase").style("font-weight", "bold").attr("text-anchor", 'middle');
                yAxisLabel = yAxisDrawn.append("text").attr("class", "y-axis-label").style("font-size", "1.2em").text("Number of people out of 100").style("font-weight", "bold").attr("text-anchor", 'middle').attr("transform", "rotate(270) translate(-" + ((height - topPadding - bottomPadding) / 2) + ",-70)");
                xAxisDrawn = chart.append("g").attr("class", "gradient-plot-x-axis").attr("transform", "translate(0," + (height - topPadding - bottomPadding) + ")");
                xZeroAxisDrawn = chart.append("g").attr("class", "gradient-plot-x-axis");
                return updateChart();
              };
              win.on('resize', function() {
                return updateExistingItems();
              });
              return $timeout(function() {
                return drawChart();
              });
            }
          };
        }
      };
    }
  ]);

}).call(this);

//# sourceMappingURL=gradient_chart.js.map
