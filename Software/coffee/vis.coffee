#-------------------------------------------------------------

################# ABSTRACT ANALYSIS FUNCTION333 #################

#-------------------------------------------------------------

Analysis = () ->

  width = $(document).width()
  height = $(document).height()  

  mode = "Network"

  gSelection = null
  gData = null
  gColors = d3.scale.category20()

  myNetwork = Network(width, height, gColors)
  myWorld = World(width, height, gColors)

  analysis = (selection, data) ->
    gSelection = selection
    gData = data

    if mode == "Network"
      myNetwork(selection, limitJSON(data, localStorage.getItem('limit')))
    else if mode == "World"
      myWorld(selection, limitJSON(data, localStorage.getItem('limit')))

  analysis.toggleLayout = (newLayout) ->
    if mode == "Network"
      myNetwork.toggleLayout(newLayout)

  analysis.toggleFilter = (newFilter) ->
    if mode == "Network"
      myNetwork.toggleFilter(newFilter)
    else if mode == "World"
      myWorld.toggleFilter(newFilter)

  analysis.updateSearch = (searchTerm) ->
    if mode == "Network"
      myNetwork.updateSearch(searchTerm)
    else if mode == "World"
      myWorld.updateSearch(searchTerm)

  analysis.updateData = (newData) ->
    gData = newData

    if mode == "Network"
      myNetwork.updateData(limitJSON(newData, localStorage.getItem('limit')))
    else if mode == "World"
      myWorld.updateData(limitJSON(newData, localStorage.getItem('limit')))

  analysis.getAllData = () ->
    return gData

  analysis.deleteData = () ->
    if mode == "Network"
      myNetwork.deleteData()

  analysis.isInitialized = () ->
    if mode == "Network"
      myNetwork.isInitialized()
    else if mode == "World"
      myWorld.isInitialized()

  analysis.getMode = () ->
    return mode

  analysis.setMode = (newMode) ->
    mode = newMode

  analysis.update = () ->
    if gData != null

      myNetwork.deleteData()
      myWorld.deleteData()

      if mode == "Network"
          myNetwork(gSelection, limitJSON(gData, localStorage.getItem('limit')))
      else if mode == "World"
          myWorld(gSelection, limitJSON(gData, localStorage.getItem('limit')))

  analysis.resetButtons = () ->
    if mode == "Network"
      if $('#force').hasClass('disabled')
        $('#force').removeClass 'disabled'
      if $('#radial').hasClass('disabled')
        $('#radial').removeClass 'disabled'
      if $('#cluster').hasClass('disabled')
        $('#cluster').removeClass 'disabled'

    if mode == "World"
      if !$('#force').hasClass('disabled')
        $('#force').addClass 'disabled'
      if !$('#radial').hasClass('disabled')
        $('#radial').addClass 'disabled'
      if !$('#cluster').hasClass('disabled')
        $('#cluster').addClass 'disabled'

    if $('#force').hasClass('active')
      $('#force').removeClass 'active'
    if $('#radial').hasClass('active')
      $('#radial').removeClass 'active'
    if $('#cluster').hasClass('active')
      $('#cluster').removeClass 'active'

    if $('#all').hasClass('active')
      $('#all').removeClass 'active'
    if $('#popular').hasClass('active')
      $('#popular').removeClass 'active'
    if $('#obscure').hasClass('active')
      $('#obscure').removeClass 'active'

    document.getElementById('force').click()
    document.getElementById('all').click()

  analysis.sortClicking = (object) ->
    if mode == "Network"
      if !$('.network').hasClass('active')
        $('.network').addClass 'active'
      if $('.world').hasClass('active')
        $('.world').removeClass 'active'

    if mode == "World"
      if !$('.world').hasClass('active')
        $('.world').addClass 'active'
      if $('.network').hasClass('active')
        $('.network').removeClass 'active'

    return

  return analysis

#-------------------------------------------------------------

#################        WORLD FUNCTION      #################

#-------------------------------------------------------------

World = (width, height, colors) ->

  feature = undefined
  circles = undefined

  m0 = undefined
  o0 = undefined

  radius = 10
  hoverRadius = 20

  wdata = undefined
  geoData = undefined

  centered = undefined

  nodeColors = colors

  initialized = false

  tooltip = Tooltip("map-tooltip", 230)

  world = (selection, data) ->

    initialize(selection, data)

  initialize = (selection, data) ->

    initialized = true

    geoData = geoJSON(data)

    projection = d3.geo.orthographic()
      .scale(240)
      .translate([width / 2, height / 2])
      .clipAngle(90)

    path = d3.geo.path()
      .projection(projection)
      .pointRadius((d, i) -> radius)

    svg = d3.select(selection)
      .append('svg:svg')
      .attr('width', width)
      .attr('height', height)

    backgroundCircle = svg.append('svg:circle')
      .attr('cx', width / 2)
      .attr('cy', height / 2)
      .attr('r', 0)
      .attr('class', 'geo-globe')

    world = svg.append('svg:g')

    zoomScale = 1

    locations = svg.append('svg:g')
      .attr('id', 'locations')

    backgroundCircle.attr 'r', projection.scale()

    features = world.selectAll('path')
      .data(wdata.features)
      .enter().append('svg:path')
      .attr('class', 'geo-path')
      .attr('d', path)
      .style('stroke-width', 1 + 'px')

    trackballAngles = (pt) ->
      r = projection.scale()
      c = projection.translate()
      x = pt[0] - (c[0])
      y = -(pt[1] - (c[1]))
      ss = x * x + y * y
      z = if r * r > 2 * ss then Math.sqrt(r * r - ss) else r * r / 2 / Math.sqrt(ss)
      lambda = Math.atan2(x, z) * 180 / Math.PI
      phi = Math.atan2(y, z) * 180 / Math.PI
      [lambda, phi]

    composedRotation = (λ, ϕ, γ, δλ, δϕ) ->
      λ = Math.PI / 180 * λ
      ϕ = Math.PI / 180 * ϕ
      γ = Math.PI / 180 * γ
      δλ = Math.PI / 180 * δλ
      δϕ = Math.PI / 180 * δϕ
      sλ = Math.sin(λ)
      sϕ = Math.sin(ϕ)
      sγ = Math.sin(γ)
      sδλ = Math.sin(δλ)
      sδϕ = Math.sin(δϕ)
      cλ = Math.cos(λ)
      cϕ = Math.cos(ϕ)
      cγ = Math.cos(γ)
      cδλ = Math.cos(δλ)
      cδϕ = Math.cos(δϕ)

      m00 = -sδλ * sλ * cϕ + (sγ * sλ * sϕ + cγ * cλ) * cδλ
      m01 = -sγ * cδλ * cϕ - (sδλ * sϕ)
      m02 = sδλ * cλ * cϕ - ((sγ * sϕ * cλ - (sλ * cγ)) * cδλ)
      m10 = -sδϕ * sλ * cδλ * cϕ - ((sγ * sλ * sϕ + cγ * cλ) * sδλ * sδϕ) - ((sλ * sϕ * cγ - (sγ * cλ)) * cδϕ)
      m11 = sδλ * sδϕ * sγ * cϕ - (sδϕ * sϕ * cδλ) + cδϕ * cγ * cϕ
      m12 = sδϕ * cδλ * cλ * cϕ + (sγ * sϕ * cλ - (sλ * cγ)) * sδλ * sδϕ + (sϕ * cγ * cλ + sγ * sλ) * cδϕ
      m20 = -sλ * cδλ * cδϕ * cϕ - ((sγ * sλ * sϕ + cγ * cλ) * sδλ * cδϕ) + (sλ * sϕ * cγ - (sγ * cλ)) * sδϕ
      m21 = sδλ * sγ * cδϕ * cϕ - (sδϕ * cγ * cϕ) - (sϕ * cδλ * cδϕ)
      m22 = cδλ * cδϕ * cλ * cϕ + (sγ * sϕ * cλ - (sλ * cγ)) * sδλ * cδϕ - ((sϕ * cγ * cλ + sγ * sλ) * sδϕ)

      if m01 != 0 or m11 != 0
        γ_ = Math.atan2(-m01, m11)
        ϕ_ = Math.atan2(-m21, if Math.sin(γ_) == 0 then m11 / Math.cos(γ_) else -m01 / Math.sin(γ_))
        λ_ = Math.atan2(-m20, m22)
      else
        γ_ = Math.atan2(m10, m00) - (m21 * λ)
        ϕ_ = -m21 * Math.PI / 2
        λ_ = λ

      [λ_ * 180 / Math.PI, ϕ_ * 180 / Math.PI, γ_ * 180 / Math.PI]

    mouseover = (d, i) ->
      if !d.filtered
        content = '<p class="main">' + d.properties.tweet + '</span></p>'
        content += '<hr class="tooltip-hr">'
        content += '<p class="main">' + d.properties.username + '</span></p>'
        tooltip.showTooltip(content,d3.event)

      path.pointRadius (d, i) ->
        hoverRadius

      circles
        .style("stroke", (n) -> if n.searched then "#555" else d3.rgb(nodeColors(n.properties[localStorage.getItem('color').toLowerCase()])).darker().toString())
        .style("stroke-width", (n) -> if n.searched then 2.0 else 1.0)
        .style("opacity", (n) -> if n.filtered then 0 else (if n.searched then 1.0 else 0.66))

      d3.select(this)
        .style("stroke","black")
        .style("stroke-width", 2.0)

      d3.select(this).attr 'd', path
      return

    mouseout = (d, i) ->
      tooltip.hideTooltip()

      path.pointRadius (d, i) ->
        radius

      circles
        .style("stroke", (n) -> if !n.searched then d3.rgb(nodeColors(n.properties[localStorage.getItem('color').toLowerCase()])).darker().toString() else "#555")
        .style("stroke-width", (n) -> if !n.searched then 1.0 else 2.0)
        .style("opacity", (n) ->if n.filtered then 0 else (if !n.searched then 0.66 else 1.0))

      d3.select(this).attr 'd', path
      return

    mousedown = ->
      m0 = trackballAngles(d3.mouse(svg[0][0]))
      o0 = projection.rotate()
      d3.event.preventDefault()
      return

    mousemove = ->
      if m0
        m1 = trackballAngles(d3.mouse(svg[0][0]))
        o1 = composedRotation(o0[0], o0[1], o0[2], m1[0] - (m0[0]), m1[1] - (m0[1]))
        projection.rotate o1
        svg.selectAll('path').attr 'd', path
      return

    mouseup = ->
      if m0
        mousemove()
        m0 = null
      return

    globeZoom = ->
      if d3.event and d3.event.sourceEvent.shiftKey
        _scale = d3.event.scale
        projection.scale _scale
        backgroundCircle.attr 'r', _scale
        path.pointRadius radius
        features.attr 'd', path
        circles.attr 'd', path
      return

    circles = locations.selectAll('path')
      .data(geoData.features)
      .enter().append('svg:path')
      .attr('class', 'geo-node')
      .attr('d', path)
      .style("fill", (d) -> nodeColors(d.properties[localStorage.getItem('color').toLowerCase()]))
      .style("stroke", (d) -> d3.rgb(nodeColors(d.properties[localStorage.getItem('color').toLowerCase()])).darker().toString())
      .style("stroke-width", 1.0)
      .style('opacity', 0.66)
      .on('mouseover', mouseover)
      .on('mouseout', mouseout)

    d3.select(window)
      .on('mousemove', mousemove)
      .on('mouseup', mouseup)

    svg.on('mousedown', mousedown)

    zoom = d3.behavior.zoom(true)
      .scale(projection.scale())
      .scaleExtent([100, 1000])
      .on('zoom', globeZoom)

    svg.call(zoom)
      .on 'dblclick.zoom', null

  world.isInitialized = () ->
    return initialized

  world.updateData = (newData) ->
    d3.select("#vis").select("svg").remove();

    feature = undefined
    circles = undefined
    m0 = undefined
    o0 = undefined
    geoData = undefined
    centered = undefined
    initialized = false

    initialize("#vis", newData)

  world.deleteData = () ->
    d3.select("#vis").select("svg").remove();

    feature = undefined
    circles = undefined
    m0 = undefined
    o0 = undefined
    geoData = undefined
    centered = undefined
    initialized = false

  world.updateSearch = (searchTerm) ->
    searchRegEx = new RegExp(searchTerm.toLowerCase())
    circles.each (d) ->
      element = d3.select(this)
      match = d.properties.tweet.toLowerCase().search(searchRegEx)
      if searchTerm.length > 0 and match >= 0
        element.style("fill", "#F38630")
          .style("stroke-width", 2.0)
          .style("stroke", "#555")
          .style("opacity", (n) -> if !n.filtered then 1.00 else 0)
        d.searched = true
      else
        d.searched = false
        element.style("fill", (d) -> nodeColors(d.properties[localStorage.getItem('color').toLowerCase()]))
          .style("stroke-width", 1.0)
          .style("opacity", (n) -> if !n.filtered then 0.66 else 0)

  world.toggleFilter = (newFilter) ->
    if newFilter == "all"
      circles.each (d) ->
        element = d3.select(this)
        element.style("opacity", (n) -> if !n.searched then 0.66 else 1.0)
        d.filtered = false
    if newFilter == "popular" or newFilter == "obscure"
      nodes = geoData.features
      counts = nodes.map((d) -> parseInt d.properties[localStorage.getItem('size').toLowerCase()]).sort(d3.ascending)
      cutoff = d3.quantile(counts, 0.5)
      if newFilter == "popular"
        circles.each (d) ->
          element = d3.select(this)
          if (parseInt d.properties[localStorage.getItem('size').toLowerCase()]) > cutoff
            element.style("opacity", (n) -> if !n.searched then 0.66 else 1.0)
            d.filtered = false
          else
            element.style("opacity", 0)
            d.filtered = true
      if newFilter == "obscure"
        circles.each (d) ->
          element = d3.select(this)
          if (parseInt d.properties[localStorage.getItem('size').toLowerCase()]) <= cutoff
            element.style("opacity", (n) -> if !n.searched then 0.66 else 1.0)
            d.filtered = false
          else
            element.style("opacity", 0)
            d.filtered = true

  d3.json 'files/world.json', (json) ->
    wdata = json

  return world

#-------------------------------------------------------------

#################       RADIAL FUNCTION      #################

#-------------------------------------------------------------

RadialPlacement = () ->
  # stores the key -> location values
  values = d3.map()
  # how much to separate each location by
  increment = 20
  # how large to make the layout
  radius = 200
  # where the center of the layout should be
  center = {"x":0, "y":0}
  # what angle to start at
  start = -120
  current = start

  # Given an center point, angle, and radius length,
  # return a radial position for that angle
  radialLocation = (center, angle, radius) ->
    x = (center.x + radius * Math.cos(angle * Math.PI / 180))
    y = (center.y + radius * Math.sin(angle * Math.PI / 180))
    {"x":x,"y":y}

  radialCenterLocation = (center, angle, radius) ->
    x = (center.x)
    y = (center.y)
    {"x":x,"y":y}

  # Main entry point for RadialPlacement
  # Returns location for a particular key,
  # creating a new location if necessary.
  placement = (key) ->
    value = values.get(key)
    if !values.has(key)
      value = place(key)
    value

  # Gets a new location for input key
  place = (key) ->
    value = radialLocation(center, current, radius)
    values.set(key,value)
    current += increment
    value

  placeCenter = (key) ->
    value = radialCenterLocation(center, current, radius)
    values.set(key,value)
    current += increment
    value

   # Given a set of keys, perform some 
  # magic to create a two ringed radial layout.
  # Expects radius, increment, and center to be set.
  # If there are a small number of keys, just make
  # one circle.
  setKeys = (keys, ckeys) ->
    # start with an empty values
    values = d3.map()
  
    # number of keys to go in first circle
    firstCircleCount = 360 / increment

    # removing nodes with multiple clusters
    keys.forEach (k) ->
      i = k.indexOf(",")
      if i > -1
        index = keys.indexOf(k)
        keys.splice(index, 1);

    # centering nodes with multiple clusters
    if ckeys != null
      ckeys.forEach (k) -> placeCenter(k)

    # if we don't have enough keys, modify increment
    # so that they all fit in one circle
    if keys.length < firstCircleCount
      increment = 360 / keys.length

    # set locations for inner circle
    firstCircleKeys = keys.slice(0,firstCircleCount)
    firstCircleKeys.forEach (k) -> place(k)

    # set locations for outer circle
    secondCircleKeys = keys.slice(firstCircleCount)

    # setup outer circle
    radius = radius + radius / 1.8
    increment = 360 / secondCircleKeys.length

    secondCircleKeys.forEach (k) -> place(k)

  placement.keys = (_, ckeys) ->
    if !arguments.length
      return d3.keys(values)
    setKeys(_, ckeys)
    placement

  placement.center = (_) ->
    if !arguments.length
      return center
    center = _
    placement

  placement.radius = (_) ->
    if !arguments.length
      return radius
    radius = _
    placement

  placement.start = (_) ->
    if !arguments.length
      return start
    start = _
    current = start
    placement

  placement.increment = (_) ->
    if !arguments.length
      return increment
    increment = _
    placement

  return placement

#-------------------------------------------------------------

#################      NETWORK FUNCTION      #################

#-------------------------------------------------------------

Network = (width, height, colors) ->
  # allData will store the unfiltered data
  allData = []
  curLinksData = []
  curNodesData = []
  linkedByIndex = {}
  # these will hold the svg groups for
  # accessing the nodes and links display
  nodesG = null
  linksG = null
  # these will point to the circles and lines
  # of the nodes and links
  node = null
  link = null
  # variables to refect the current settings
  # of the visualization
  layout = "force"
  filter = "all"
  # groupCenters will store our radial layout for
  # the group by username layout.
  groupCenters = null

  # our force directed layout
  force = d3.layout.force()
  # color function used to color nodes
  nodeColors = colors
  # tooltip used to display details
  tooltip = Tooltip("vis-tooltip", 230)

  # charge used in username layout
  charge = (node) -> -Math.pow(node.radius, 2.0) / 2

  # used in highlighting nodes
  toggled = 0

  # used for initializing network
  initialized = false

  # Starting point for network visualization
  # Initializes visualization and starts force layout
  network = (selection, data) ->

    initialized = true

    # format our data
    allData = setupData(data)

    redraw = ->
      if d3.event.sourceEvent.shiftKey
        vis.attr "transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")"
      return

    # create our svg and groups
    vis = d3.select(selection).append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("pointer-events", "all")
      .call(d3.behavior.zoom().scaleExtent([0, 10]).on("zoom", redraw))
      .append("svg:g")

    linksG = vis.append("g").attr("id", "links")
    nodesG = vis.append("g").attr("id", "nodes")

    # setup the size of the force environment
    force.size([width, height])

    setLayout("force")
    setFilter("all")

    # perform rendering and start force layout
    update()

  reset = () ->
    node.style 'opacity', 1
    link.style 'opacity', 1
    toggled = 0

  # The update() function performs the bulk of the
  # work to setup our visualization based on the
  # current layout/sort/filter.
  #
  # update() is called everytime a parameter changes
  # and the network needs to be reset.
  update = () ->
    # filter data to show based on current filter settings.
    curNodesData = filterNodes(allData.nodes)
    curLinksData = filterLinks(allData.links, curNodesData)

    # sort nodes based on current sort and update centers for
    # radial layout
    if layout == "radial"
      usernames = sortedUsernames(curNodesData, curLinksData)
      updateCenters(usernames)

    if layout == "cluster"
      clusters = sortedClusters(curNodesData, curLinksData)
      cClusters = centeredClusters(curNodesData, curLinksData)
      updateClusterCenters(clusters, cClusters)

    # reset nodes in force layout
    force.nodes(curNodesData)

    # enter / exit for nodes
    updateNodes()

    # always show links in force layout
    if layout == "force"
      force.links(curLinksData)
      updateLinks()
    else
      # reset links so they do not interfere with
      # other layouts. updateLinks() will be called when
      # force is done animating.
      force.links([])
      # if present, remove them from svg 
      if link
        link.data([]).exit().remove()
        link = null

    # start me up!
    force.start()

  network.getAllData = () ->
    return allData

  # Public function to switch between layouts
  network.toggleLayout = (newLayout) ->
    force.stop()
    setLayout(newLayout)
    update()
    reset()

  # Public function to switch between filter options
  network.toggleFilter = (newFilter) ->
    force.stop()
    setFilter(newFilter)
    update()
    reset()

  # Public function to switch between sort options
  network.toggleSort = (newSort) ->
    force.stop()
    setSort(newSort)
    update()

  # Public function to update highlighted nodes
  # from search
  network.updateSearch = (searchTerm) ->
    searchRegEx = new RegExp(searchTerm.toLowerCase())
    node.each (d) ->
      element = d3.select(this)
      match = d["Tweet"].toLowerCase().search(searchRegEx)
      if searchTerm.length > 0 and match >= 0
        element.style("fill", "#F38630")
          .style("stroke-width", 2.0)
          .style("stroke", "#555")
        d.searched = true
      else
        d.searched = false
        element.style("fill", (d) -> nodeColors(d[localStorage.getItem('color')]))
          .style("stroke-width", 1.0)

  network.updateData = (newData) ->
    allData = setupData(newData)
    link.remove()
    node.remove()
    update()

  network.deleteData = () ->
    d3.select("#vis").select("svg").remove();
    allData = []
    initialized = false

  network.isInitialized = () ->
    return initialized

  # called once to clean up raw data and switch links to
  # point to node instances
  # Returns modified data
  setupData = (data) ->
    # initialize circle radius scale
    countExtent = d3.extent(data.nodes, (d) -> parseInt d[localStorage.getItem('size')])
    circleRadius = d3.scale.sqrt().range([3, 12]).domain(countExtent)

    data.nodes.forEach (n) ->
      # set initial x/y to values within the width/height
      # of the visualization
      n.x = randomnumber=Math.floor(Math.random()*width)
      n.y = randomnumber=Math.floor(Math.random()*height)
      # add radius to the node so we can use it later
      n.radius = circleRadius(parseInt n[localStorage.getItem('size')])

    # id's -> node objects
    nodesMap  = mapNodes(data.nodes)

    # switch links to point to node objects instead of id's
    data.links.forEach (l) ->
      l.source = nodesMap.get(l.source)
      l.target = nodesMap.get(l.target)

      # linkedByIndex is used for link sorting
      linkedByIndex["#{l.source["Tweet ID"]},#{l.target["Tweet ID"]}"] = 1

    data

  # Helper function to map node id's to node objects.
  # Returns d3.map of ids -> nodes
  mapNodes = (nodes) ->
    nodesMap = d3.map()
    nodes.forEach (n) ->
      nodesMap.set(n["Tweet ID"], n)
    nodesMap

  # Helper function that returns an associative array
  # with counts of unique attr in nodes
  # attr is value stored in node, like 'username'
  nodeCounts = (nodes, attr) ->
    counts = {}
    nodes.forEach (d) ->
      counts[d[attr]] ?= 0
      counts[d[attr]] += 1
    counts

  # Given two nodes a and b, returns true if
  # there is a link between them.
  # Uses linkedByIndex initialized in setupData
  neighboring = (a, b) ->
    linkedByIndex[a["Tweet ID"] + "," + b["Tweet ID"]] or
      linkedByIndex[b["Tweet ID"] + "," + a["Tweet ID"]]

  # Removes nodes from input array
  # based on current filter setting.
  # Returns array of nodes
  filterNodes = (allNodes) ->
    filteredNodes = allNodes
    if filter == "popular" or filter == "obscure"
      playcounts = allNodes.map((d) -> parseInt d[localStorage.getItem('size')]).sort(d3.ascending)
      cutoff = d3.quantile(playcounts, 0.5)
      filteredNodes = allNodes.filter (n) ->
        if filter == "popular"
          n[localStorage.getItem('size')] > cutoff
        else if filter == "obscure"
          n[localStorage.getItem('size')] <= cutoff

    filteredNodes

  # Returns array of usernames sorted based on
  # current sorting method.
  sortedUsernames = (nodes,links) ->
    usernames = []

    counts = nodeCounts(nodes, "Username")
    usernames = d3.entries(counts).sort (a,b) ->
      b.value - a.value
    usernames = usernames.map (v) -> v.key

    usernames

  updateCenters = (usernames) ->
    if layout == "radial"
      groupCenters = RadialPlacement().center({"x":width/2, "y":height / 2 + 50})
        .radius(300).increment(18).keys(usernames,null)

  sortedClusters = (nodes,links) ->
    clusters = []

    counts = nodeCounts(nodes, localStorage.getItem('cluster'))
    clusters = d3.entries(counts).sort (a,b) ->
      b.value - a.value

    clusters = clusters.map (v) -> v.key

    clusters

  centeredClusters = (nodes,links) ->
    clusters = []

    nodes.forEach (n) ->
      if n[localStorage.getItem('cluster')].indexOf(",") != -1
        clusters.push(n[localStorage.getItem('cluster')]);

    clusters

  updateClusterCenters = (clusters, cClusters) ->
    if layout == "cluster"
      groupCenters = RadialPlacement().center({"x":width/2, "y":height / 2 + 50})
        .radius(300).increment(18).keys(clusters, cClusters)

  # Removes links from allLinks whose
  # source or target is not present in curNodes
  # Returns array of links
  filterLinks = (allLinks, curNodes) ->
    curNodes = mapNodes(curNodes)
    allLinks.filter (l) ->
      curNodes.get(l.source["Tweet ID"]) and curNodes.get(l.target["Tweet ID"])

  # Highlights related nodes
  connectedNodes = ->
    if toggled == 0
      d = d3.select(this).node().__data__
      node.style 'opacity', (o) ->
        if o != d
          if neighboring(d, o) then 1 else 0.1
      link.style 'opacity', (o) ->
        if o != d
          if d.index == o.source.index | d.index == o.target.index then 1 else 0.1
      toggled = 1
    else
      node.style 'opacity', 1
      link.style 'opacity', 1
      toggled = 0
    return

  # enter/exit display for nodes
  updateNodes = () ->
    node = nodesG.selectAll("circle.node")
      .data(curNodesData, (d) -> d["Tweet ID"])

    node.enter().append("circle")
      .attr("class", "node")
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)
      .attr("r", (d) -> d.radius)
      .style("fill", (d) -> nodeColors(d[localStorage.getItem('color')]))
      .style("stroke", (d) -> strokeFor(d))
      .style("stroke-width", 1.0)

    node.on("mouseover", showDetails)
      .on("mouseout", hideDetails)
      .on('dblclick', connectedNodes);

    node.exit().remove()

  # enter/exit display for links
  updateLinks = () ->
    link = linksG.selectAll("line.link")
      .data(curLinksData, (d) -> "#{d.source["Tweet ID"]}_#{d.target["Tweet ID"]}")
    link.enter().append("line")
      .attr("class", "link")
      .attr("stroke", "#ddd")
      .attr("stroke-opacity", 0.8)
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr("y2", (d) -> d.target.y)

    link.exit().remove()

  # switches force to new layout parameters
  setLayout = (newLayout) ->
    layout = newLayout
    if layout == "force"
      force.on("tick", forceTick)
        .charge(-200)
        .linkDistance(50)
    else if layout == "radial"
      force.on("tick", radialTick)
        .charge(charge)
    else if layout == "cluster"
      force.on("tick", clusterTick)
        .charge(charge)

  # switches filter option to new filter
  setFilter = (newFilter) ->
    filter = newFilter

  # switches sort option to new sort
  setSort = (newSort) ->
    sort = newSort

  # tick function for force directed layout
  forceTick = (e) ->
    node
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)

    link
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr("y2", (d) -> d.target.y)

  # tick function for radial layout
  radialTick = (e) ->
    node.each(moveToRadialLayout(e.alpha))

    node
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)

    if e.alpha < 0.03
      force.stop()
      updateLinks()

  # Adjusts x/y for each node to
  # push them towards appropriate location.
  # Uses alpha to dampen effect over time.
  moveToRadialLayout = (alpha) ->
    k = alpha * 0.1
    (d) ->
      centerNode = groupCenters(d["Username"])
      d.x += (centerNode.x - d.x) * k
      d.y += (centerNode.y - d.y) * k

  clusterTick = (e) ->
    node.each(moveToClusterLayout(e.alpha))

    node
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)

    if e.alpha < 0.03
      force.stop()
      updateLinks()

  moveToClusterLayout = (alpha) ->
    k = alpha * 0.1
    (d) ->
      centerNode = groupCenters(d[localStorage.getItem('cluster')])
      d.x += (centerNode.x - d.x) * k
      d.y += (centerNode.y - d.y) * k

  # Helper function that returns stroke color for
  # particular node.
  strokeFor = (d) ->
    d3.rgb(nodeColors(d[localStorage.getItem('color')])).darker().toString()

  clusterStrokeFor = (d) ->
    d3.rgb(nodeColors(d[localStorage.getItem('cluster')])).darker().toString()

  # Mouseover tooltip function
  showDetails = (d,i) ->
    content = '<p class="main">' + d["Tweet"] + '</span></p>'
    content += '<hr class="tooltip-hr">'
    content += '<p class="main">' + d["Username"] + '</span></p>'
    if d[localStorage.getItem('cluster')].trim() != ""
      content += '<hr class="tooltip-hr-extra">'
      content += '<p class="extra">' + d[localStorage.getItem('cluster')] + '</span></p>'
    tooltip.showTooltip(content,d3.event)

    # higlight connected links
    if link
      link.attr("stroke", (l) ->
        if l.source == d or l.target == d then "#555" else "#ddd"
      )
        .attr("stroke-opacity", (l) ->
          if l.source == d or l.target == d then 1.0 else 0.5
        )

      # link.each (l) ->
      #   if l.source == d or l.target == d
      #     d3.select(this).attr("stroke", "#555")

    # highlight neighboring nodes
    # watch out - don't mess with node if search is currently matching
    node.style("stroke", (n) ->
      if (n.searched or neighboring(d, n)) then "#555" else strokeFor(n))
      .style("stroke-width", (n) ->
        if (n.searched or neighboring(d, n)) then 2.0 else 1.0)
  
    # highlight the node being moused over
    d3.select(this).style("stroke","black")
      .style("stroke-width", 2.0)

  # Mouseout function
  hideDetails = (d,i) ->
    tooltip.hideTooltip()
    # watch out - don't mess with node if search is currently matching
    node.style("stroke", (n) -> if !n.searched then strokeFor(n) else "#555")
      .style("stroke-width", (n) -> if !n.searched then 1.0 else 2.0)
    if link
      link.attr("stroke", "#ddd")
        .attr("stroke-opacity", 0.8)


  # Final act of Network() function is to return the inner 'network()' function.
  return network

# Activate selector button
activate = (group, link) ->
  d3.selectAll("##{group} a").classed("active", false)
  d3.select("##{group} ##{link}").classed("active", true)

convertToJSON = (workbook) ->
  result = {,links:[]}
  workbook.SheetNames.forEach (sheetName) ->
    roa = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName])
    if roa.length > 0
      result["nodes"] = roa
    return

  result

#-------------------------------------------------------------

#################             START          #################

#-------------------------------------------------------------

$ ->
  myAnalysis = Analysis()

  #-------------------------------------------------------------
  #TOP NAVIGATION
  #-------------------------------------------------------------

  d3.selectAll("#layouts label").on "click", (d) ->
    newLayout = d3.select(this).attr("id")
    activate("layouts", newLayout)
    myAnalysis.toggleLayout(newLayout)

  d3.selectAll("#filters label").on "click", (d) ->
    newFilter = d3.select(this).attr("id")
    activate("filters", newFilter)
    myAnalysis.toggleFilter(newFilter)
  
  $("#search").keyup () ->
    searchTerm = $(this).val()
    myAnalysis.updateSearch(searchTerm)

  #-------------------------------------------------------------
  #BOTTOM LEFT NAVIGATION
  #-------------------------------------------------------------

  d3.select('#upload-graph').on 'click', ->
    document.getElementById('hidden-file-upload').click()
    return
    
  d3.select('#hidden-file-upload').on 'change', ->
    if window.File and window.FileReader and window.FileList and window.Blob
      uploadFile = @files[0]
      if uploadFile != undefined
        try
          fileExtension = uploadFile.name.split('.').pop();

          # Support for the json data
          if fileExtension == "json"
            reader = new FileReader

            reader.onload = (e) ->
              data = e.target.result
              json = JSON.parse(data);
              if myAnalysis.isInitialized()
                myAnalysis.updateData(json)
              else
                myAnalysis("#vis", json)
              return

            reader.readAsText uploadFile

          # Support for the spreadsheet data
          else if fileExtension == "xlsx" || fileExtension == "xls"
            reader = new FileReader

            reader.onload = (e) ->
              data = e.target.result
              workbook = XLSX.read(data, type: 'binary')
              json = convertToJSON(workbook)
              if myAnalysis.isInitialized()
                myAnalysis.updateData(json)
              else
                myAnalysis("#vis", json)
              return

            reader.readAsBinaryString uploadFile

          myAnalysis.resetButtons()
        catch err
          window.alert 'Error parsing uploaded file\nerror message: ' + err.message
          return
        return
    else
      alert 'Your browser won\'t let you save this graph -- try upgrading your browser to IE 10+ or Chrome or Firefox.'
    return

  d3.select('#download-graph').on 'click', ->
    data = myAnalysis.getAllData()
    saveLinks = []
    saveNodes = []

    data.links.forEach (val, i) ->
      saveLinks.push
        "source": val.source["Tweet ID"]
        "target": val.target["Tweet ID"]
      return

    data.nodes.forEach (val, i) ->
      saveNodes.push
        "Row ID": val["Row ID"]  
        "Tweet ID": val["Tweet ID"]
        "Username": val["Username"]
        "Tweet": val["Tweet"]
        "Time": val["Time"]
        "Tweet Type": val["Tweet Type"] 
        "Retweeted By": val["Retweeted By"]
        "Number of Retweets": val["Number of Retweets"]
        "Hashtags": val["Hashtags"]
        "Mentions": val["Mentions"]
        "Name": val["Name"]
        "Location": val["Location"]
        "Web": val["Web"]
        "Bio": val["Bio"]
        "Number of Tweets": val["Number of Tweets"]
        "Number of Followers": val["Number of Followers"]
        "Number Following": val["Number Following"]
        "Location Coordinates": val["Location Coordinates"]
        "Cluster": val["Cluster"]
      return

    blob = new Blob([ window.JSON.stringify('nodes': saveNodes, 'links': saveLinks) ], type: 'text/plain;charset=utf-8')
    saveAs blob, 'mygraph.json'

  d3.select('#share-graph').on 'click', ->
    $('#confirmation-modal').modal('show')

  d3.select('#confirmation-yes').on 'click', ->
    if myAnalysis.getAllData() != null
      jsonData = myAnalysis.getAllData()
      $.ajax
        url: 'upload.php'
        type: 'POST'
        data: { json: JSON.stringify(jsonData) }

  #-------------------------------------------------------------
  #BOTTOM RIGHT NAVIGATION
  #-------------------------------------------------------------

  d3.select('#graph-mode').on 'click', ->
    myAnalysis.setMode("Network")
    myAnalysis.sortClicking('.network')
    myAnalysis.resetButtons()
    myAnalysis.update()

  d3.select('#map-mode').on 'click', ->
    myAnalysis.setMode("World")
    myAnalysis.sortClicking('.world')
    myAnalysis.resetButtons()
    myAnalysis.update()

  d3.select('#cloud-mode').on 'click', ->
    $('#full-search').addClass 'open'
    $('#full-search > form > input[type="search"]').focus()

    $('#full-search, #full-search button.close').on 'click keyup', (event) ->
      if event.target == this or event.target.className == 'close' or event.keyCode == 27
        $('#full-search').removeClass 'open'
      return

    $('#full-search-button').click (event) ->
      event.preventDefault()

      searchTerm = $('#full-search-field').val().toLowerCase().trim()

      if searchTerm != ""
        $.ajax
          url: 'data'
          success: (data) ->
            files = []
            count = 0

            searchJSON = 
              'nodes': []
              'links': []

            $(data).find('a:contains(.json)').each ->
              file = $(this).attr('href')
              if file != ".$fileName.json"
                files.push file
              return
            
            if files.length != 0
              $('#wait-modal').modal('show')
              files.forEach (f) ->
                count++
                d3.json 'data/' + f, (json) ->
                  if JSON.stringify(json).toLowerCase().indexOf(searchTerm) != -1
                    json.nodes.forEach (val) ->
                      if JSON.stringify(val).toLowerCase().indexOf(searchTerm) != -1
                        searchJSON.nodes.push
                          "Row ID": val["Row ID"]  
                          "Tweet ID": val["Tweet ID"]
                          "Username": val["Username"]
                          "Tweet": val["Tweet"]
                          "Time": val["Time"]
                          "Tweet Type": val["Tweet Type"] 
                          "Retweeted By": val["Retweeted By"]
                          "Number of Retweets": val["Number of Retweets"]
                          "Hashtags": val["Hashtags"]
                          "Mentions": val["Mentions"]
                          "Name": val["Name"]
                          "Location": val["Location"]
                          "Web": val["Web"]
                          "Bio": val["Bio"]
                          "Number of Tweets": val["Number of Tweets"]
                          "Number of Followers": val["Number of Followers"]
                          "Number Following": val["Number Following"]
                          "Location Coordinates": val["Location Coordinates"]
                          "Cluster": val["Cluster"]
                if count == files.length
                  setTimeout (->
                    $('#wait-modal').modal('hide')
                    if myAnalysis.isInitialized()
                      myAnalysis.updateData(searchJSON)
                    else
                      myAnalysis("#vis", searchJSON)
                    myAnalysis.resetButtons()
                    return
                  ), 3000

      $('#full-search-field').val("")
      $('#full-search').removeClass 'open'

  #-------------------------------------------------------------
  #HIDDEN BUTTON
  #-------------------------------------------------------------

  d3.select("#hidden-settings-button").on 'click', ->
    myAnalysis.resetButtons()
    myAnalysis.update()