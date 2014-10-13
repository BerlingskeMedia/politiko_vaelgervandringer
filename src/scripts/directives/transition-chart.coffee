angular.module "transitionChartDirective", []
  .directive "transitionChart", ($window, $filter) ->
    restrict: "E"
    scope: false
    link: (scope, element, attr) ->
      firstRun = true
      tableWidth = 0
      retina = true if $window.devicePixelRatio > 1
      partyColors =
        first:
          "ø": "#731525"
          f: "#9c1d2a"
          a: "#e32f3b"
          b: "#e52b91"
          c: "#0f854b"
          v: "#0f84bb"
          o: "#005078"
          i: "#ef8535"
          k: "#f0ac55"
        second:
          "ø": "#93494e"
          f: "#b04b53"
          a: "#e54f5a"
          b: "#ec43a2"
          c: "#3d9a67"
          v: "#409aca"
          o: "#3a6e8f"
          i: "#f09b58"
          k: "#f5cf94"

      svg = d3.select(element[0]).append "svg"
      tip = d3.tip()
        .attr "class", "d3-tip"
        .html (d) ->
          value = $filter('number')(d.value)
          text = "mandater"
          text = "mandat" if d.mandates is 1
          html = "<p>#{value} vælgere</p>"
          html+= "<p>#{d.mandates} #{text}</p>"

          return html
      svg.call tip

      $window.onresize = -> scope.$apply()

      scope.$watch (->
        angular.element($window)[0].innerWidth
      ), ->
        tableWidth = 0
        tableWidth = 270 if angular.element($window)[0].innerWidth >= 768

        return if firstRun

        firstRun = true
        svg.selectAll("*").remove()
        render scope.transitions[scope.parti]

      scope.$watch "parti", ((newData, oldData) ->
        return if angular.equals(newData, oldData)

        render scope.transitions[newData]
      ), true

      render = (data) ->
        svgWidth = d3.select(element[0])[0][0].offsetWidth
        svgHeight = d3.select(element[0])[0][0].offsetHeight
        plusMinusMargin = 20
        drawWidth = svgWidth - tableWidth
        drawCenter = drawWidth / 2
        gianTopMargin = 40
        lostTopMargin = svgHeight - gianTopMargin
        bubbleLeftMargin = 50
        innerCircleRadius = 60
        pi = Math.PI
        arrowMargin = 10
        maxValue = 0
        minValue = 9999999999999999999999999999999999
        totalGain = 0
        totalLost = 0
        dataArray = []
        logoSize = 80

        delete data["rød_blok"]
        delete data["blå_blok"]
        delete data["nye_vælgere"]
        delete data["tvivlere"]
        delete data["andre"]

        for party, value of data
          absNettoVotes = Math.abs(value["netto_tilgang_vælgere"])
          absNettoMandates = Math.abs(value["netto_tilgang_mandater"])

          if value["netto_tilgang_vælgere"] isnt 0
            totalGain += value["netto_tilgang_vælgere"] if value["netto_tilgang_vælgere"] > 0
            totalLost += absNettoVotes if value["netto_tilgang_vælgere"] < 0
            maxValue = absNettoVotes if absNettoVotes > maxValue
            minValue = absNettoVotes if absNettoVotes < minValue
            side = "gain" if value["netto_tilgang_vælgere"] > 0
            side = "lost" if value["netto_tilgang_vælgere"] < 0

            dataArray.push
              party: party
              value: absNettoVotes
              mandates: absNettoMandates
              side: side

        if ((gianTopMargin * 2) * dataArray.length) < drawWidth
          maxBubbleRadius = gianTopMargin
        else
          maxBubbleRadius = ((drawWidth / dataArray.length) / 2) - 5

        if svgHeight < drawWidth
          maxRadius = svgHeight / 2 - (maxBubbleRadius * 2) - 10
        else
          maxRadius = drawWidth / 2 - (maxBubbleRadius * 2) - 10

        radius = d3.scale.sqrt().domain([minValue, maxValue]).range([10, maxBubbleRadius])
        xScale = d3.scale.linear().domain([0, (dataArray.length - 1)]).range([bubbleLeftMargin, (drawWidth - maxBubbleRadius)])
        gainPrecent = totalGain / (totalGain + totalLost) * 100
        lostPrecent = totalLost / (totalGain + totalLost) * 100
        calcRadius = maxRadius - innerCircleRadius
        gainRadius = (gainPrecent * calcRadius / 100) + innerCircleRadius
        lostRadius = (lostPrecent * calcRadius / 100) + innerCircleRadius
        gainArc = d3.svg.arc().innerRadius(innerCircleRadius).startAngle(-90 * (pi / 180)).endAngle(90 * (pi / 180))
        lostArc = d3.svg.arc().innerRadius(innerCircleRadius).startAngle(90 * (pi / 180)).endAngle(270 * (pi / 180))

        if firstRun
          layer3 = svg.append("g").attr("class", "layer3").attr "transform", "translate(#{tableWidth}, 0)"
          layer2 = svg.append("g").attr("class", "layer2")
          layer1 = svg.append("g").attr("class", "layer1").attr "transform", "translate(#{tableWidth}, 0)"
          centerLayer1 = layer1.append("g").attr("class", "centerLayer1").attr "transform", "translate(#{drawCenter},#{svgHeight / 2})"
          centerLayer3 = layer3.append("g").attr("class", "centerLayer3").attr "transform", "translate(#{drawCenter},#{svgHeight / 2})"

          layer2
            .append "line"
              .attr "x1", 0
              .attr "y1", svgHeight / 2
              .attr "x2", svgWidth
              .attr "y2", svgHeight / 2
              .attr "stroke", "#000"
              .attr "stroke-width", 3

          svg
            .append "marker"
              .attr "id", "arrow-head"
              .attr "viewBox", "0 0 10 10"
              .attr "refX", "0"
              .attr "refY", "5"
              .attr "markerUnits", "strokeWidth"
              .attr "markerWidth", "8"
              .attr "markerHeight", "5"
              .attr "orient", "auto"
              .attr "fill", "#808285"
              .append "path"
                .attr "d", "M 0 0 L 10 5 L 0 10 z"

          centerLayer1
            .append "circle"
              .attr "cx", 0
              .attr "cy", 0
              .attr "r", innerCircleRadius
              .attr "fill", "#ffffff"
              .attr "stroke", "#000000"
              .attr "stroke-size", 1

          centerLayer3
            .append "path"
              .attr "class", "gain"
              .attr "d", gainArc.outerRadius(0)

          centerLayer3
            .append "path"
              .attr "class", "lost"
              .attr "d", lostArc.outerRadius(0)

          centerLayer1.append "image"

          plusMinus = layer1.append "text"
            .attr "class", "plus-minus"
            .attr "x", 0
            .attr "y", svgHeight / 2
            .attr "font-weight", "bold"
            .attr "font-size", "100px"

          plusMinus
            .append "tspan"
              .attr "x", 0
              .attr "dy", -plusMinusMargin
              .text "+"

          plusMinus
            .append "tspan"
              .attr "x", 0
              .attr "dy", 55 + (plusMinusMargin * 2)
              .text "÷"
        else
          layer1 = svg.select ".layer1"
          layer3 = svg.select ".layer3"
          centerLayer1 = svg.select ".centerLayer1"
          centerLayer3 = svg.select ".centerLayer3"
          plusMinus = layer1.select(".plus-minus").selectAll "tspan"

        tooltip = d3.select "info-popup"

        centerLayer1
          .select "image"
            .attr "xlink:href", (d) ->
              return "/upload/tcarlsen/voter-transitions/img/#{scope.parti}_big@2x.png" if retina
              return "/upload/tcarlsen/voter-transitions/img/#{scope.parti}_big.png"
            .attr 'width', logoSize
            .attr 'height', logoSize
            .attr 'x', -(logoSize / 2)
            .attr 'y', -(logoSize / 2)

        centerLayer3
          .select ".gain"
            .transition().duration(800).ease("elastic", 2, 2)
              .attr "d", gainArc.outerRadius(gainRadius)
              .attr "fill", -> partyColors.first[scope.parti]

        centerLayer3
          .select ".lost"
            .transition().duration(800).ease("elastic", 2, 2)
              .attr "d", lostArc.outerRadius(lostRadius)
              .attr "fill", partyColors.second[scope.parti]

        plusOrMinus = 0
        plusMinus
          .attr "fill", partyColors.first[scope.parti]


        arrows = layer3.selectAll(".arrows").data dataArray

        arrows
          .enter()
            .append "path"
              .attr "class", "arrows"
              .attr "stroke", "#808285"
              .attr "stroke-width", "1.5"
              .attr "marker-end", -> "url(#arrow-head)"
              .attr "d", "M#{drawCenter},#{svgHeight / 2}L#{drawCenter},#{svgHeight / 2}"

        arrows
          .attr "opacity", 0.2
          .transition().duration(1000).ease("elastic", 2, 4)
            .attr "opacity", 1
            .attr "d", (d, i) ->
              bubbleX = xScale(i)
              bubbleY = gianTopMargin if d.side is "gain"
              bubbleY = lostTopMargin if d.side is "lost"
              bubbleDistance = radius(d.value) if d.side is "gain"
              bubbleDistance = radius(d.value) + arrowMargin if d.side is "lost"
              centerX = drawCenter
              centerY = svgHeight / 2
              centerDistance = gainRadius + arrowMargin if d.side is "gain"
              centerDistance = lostRadius if d.side is "lost"

              dis = Math.sqrt(Math.pow((centerX - bubbleX), 2) + Math.pow((centerY - bubbleY), 2))

              newCenterX = centerX + (-centerDistance / dis) * (centerX - bubbleX)
              newCenterY = centerY + (-centerDistance / dis) * (centerY - bubbleY)
              newBubbleX = bubbleX + (-bubbleDistance / dis) * (bubbleX - centerX)
              newBubbleY = bubbleY + (-bubbleDistance / dis) * (bubbleY - centerY)

              return "M#{newBubbleX},#{newBubbleY}L#{newCenterX},#{newCenterY}" if d.side is "gain"
              return "M#{newCenterX},#{newCenterY}L#{newBubbleX},#{newBubbleY}" if d.side is "lost"

        arrows.exit().remove()

        bubbles = layer3.selectAll(".bubbles").data dataArray

        bubbleEnter = bubbles
          .enter()
            .append "g"
              .attr "class", "bubbles"
              .attr "transform", "translate(#{drawCenter},#{svgHeight / 2})"

        bubbleEnter.append "circle"
        bubbleEnter.append "text"

        bubbles
          .attr "opacity", 0.2
          .transition().duration(1000).ease("elastic", 2, 4)
            .attr "opacity", 1
            .attr "transform", (d, i) ->
              y = gianTopMargin if d.side is "gain"
              y = lostTopMargin if d.side is "lost"
              x = xScale(i)
              return "translate(#{x},#{y})"

        bubbles
          .on "mouseover", (d, i) ->
            return tip.direction("s").show(d) if d.side is "gain"

            tip.direction("n").show(d)
          .on "mouseout", tip.hide

        bubbles
          .select("circle")
            .attr "r", (d) -> radius(d.value)
            .attr "fill", (d) ->
              return partyColors.first[scope.parti] if d.side is "gain"
              return partyColors.second[scope.parti] if d.side is "lost"

        bubbles
          .select("text")
            .attr "dy", ".4em"
            .attr "text-anchor", "middle"
            .attr "fill", "#ffffff"
            .text (d) -> d.party.toUpperCase()

        bubbles.exit().remove()

        firstRun = false
