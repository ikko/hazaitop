var vis;
(function($) {
  var network = {
    xgmmlHeader: '<graph label="Cytoscape Web" directed="0" Graphic="1" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:cy="http://www.cytoscape.org" xmlns="http://www.cs.rpi.edu/XGMML">',
    body: '',
    nodes: {arr: []},
    edges: {arr: []},
    nodeIds: [],
    maxWeight: null,
    discoveredNodes: [],
    initialized: false,
    parseNodes: function(nodes) {
      for (var i=0; nodes.length > i; i++) {
        var node = nodes[i];  
        if (!this.nodes[node.id]) {
          this.nodes.arr.push(node);
          this.nodes[node.id] = node;
          this.nodeIds.push(node.id);
          this.body += this.generateXmlFromNode(node);
        }
      }
    },
    parseEdges: function(edges) {
      for(var i=0; edges.length > i; i++) {
        var edge = edges[i];
        if (!this.edges[edge.id] && !this.edges[edge.alternateId]) {
          this.edges.arr.push(edge);
          this.edges[edge.id] = edge;
          if (edge.alternateId) {this.edges[edge.alternateId] = edge;}
          this.body += this.generateXmlFromEdge(edge);
        }
      }
    },
    generateXmlFromNode: function(node) {
      return "<node id='"+node.id+"' label='"+node.label+"'><graphics type='"+node.shape+"'/></node>"
    },
    generateXmlFromEdge: function(edge) {
      return "<edge id='"+edge.id+"' source='"+edge.sourceId+"' target='"+edge.targetId+"' label='"+edge.label+"'><att type='real' name='weight' value='"+edge.weight+"'/><graphics width='"+(edge.weight/this.maxWeight)*10+"'/></edge>"
    },
    setMaxWeight: function (edges) {
      for(var i=0; edges.length > i; i++) {
        if (edges[i].weight > this.maxWeight) {
          this.maxWeight = edges[i].weight;
        }
      }
    },
    parse: function(data) {
      this.setMaxWeight(data.edges);
      this.parseNodes(data.nodes);
      this.parseEdges(data.edges);
      log(this.toXgmml())
      return this.toXgmml();
    },
    toXgmml: function() {
      return this.xgmmlHeader + this.body + '</graph>'
    },
    draw: function(data) {
      vis.draw({network: this.parse(data), 
                edgeLabelsVisible: true, 
                layout: 'Circle', 
                visualStyle: {nodes:{size:51, labelFontSize:10}, edges:{labelFontSize:10}}});
    },
    loadedNodeIds: function() {
      var resp = '';
      for(var i=0; this.nodeIds.length > i; i++) {
        resp += this.nodeIds[i]+',';
      }
      return resp;
    },
    showNodeInfo: function(nodeData) {
      if ($.inArray(nodeData.id, this.discoveredNodes) != -1) {
        $loadNodeRelations.hide();
      } else {
        $loadNodeRelations.show();
      }
      $("#node_panel").show();
      var match = nodeData.id.match(/^(.*)(\d+)$/);
      if (match[1] == 'p') {
        $nodeAttributePanels.hide();
        $personNode.show();
        $selectedNodeType.val('p');
        $personNode.find("#name").text(nodeData.label);
      } else if (match[1] == 'o'){
        $nodeAttributePanels.hide();
        $organizationNode.show();
        $selectedNodeType.val('o');
        $organizationNode.find("#name").text(nodeData.label);
      } else if (match[1] == 'l'){
        $nodeAttributePanels.hide();
        $litigationNode.show();
        $selectedNodeType.val('l');
      }
      $selectedNodeId.val(match[2]);
    }
  };

  function getAutocompleteType() {
    var tabIndex = $("#search_entities").tabs("option", "selected");
    if (tabIndex == 0) {
      return 'p'
    } else if (tabIndex == 1) {
      return 'o'
    } else if (tabIndex == 2) {
      return 'l'
    }
  }

  $(function() {
    $selectedNodeId = $("#selected_node_id");
    $selectedNodeType = $("#selected_node_type");
    $personNode = $("#person_node");
    $organizationNode = $("#organization_node");
    $litigationNode = $("#litigation_node");
    $loadNodeRelations = $("#load_node_relations");
    $nodeAttributePanels = $(".node_attributes");

    vis = new org.cytoscapeweb.Visualization("relationgraph", {swfPath: "/swf/CytoscapeWeb", flashInstallerPath: "/swf/playerProductInstall"});
    if ($selectedNodeType.val().length > 0) {
      log('Konkrét node kapcsolati hálójának kirajzolása');
      network.discoveredNodes.push($selectedNodeType.val()+$selectedNodeId.val());
      network.draw(xmmlGraph);
    }
    vis.ready(function() {
      if (!network.initialized) {
        vis.addListener("click", "nodes", function(event) {
          log('Node clicked: ', event);
          network.showNodeInfo(event.target.data);
        });
        network.initialized = true;
      }
      vis.select('nodes', [$selectedNodeType.val()+$selectedNodeId.val()]);
      network.showNodeInfo(vis.node($selectedNodeType.val()+$selectedNodeId.val()).data);
    });

    $("#search_entities").tabs();
    $loadNodeRelations.click(function(e) {
      e.preventDefault();
      $.ajax({url:'/search/?id='+$selectedNodeId.val()+'&type='+$selectedNodeType.val()+'&nodes='+network.loadedNodeIds(), 
              dataType: 'json',
              success: function(response) {
                log('Node kapcsolatai válasz: ', response);
                network.discoveredNodes.push($selectedNodeType.val()+$selectedNodeId.val());
                network.draw(response); 
              }});
    });
    $(".autocomplete").autocomplete({minLength: '1', 
                                     delay: '500',
                                     select: function(event, ui) {
                                       $selectedNodeId.val(ui.item.id);
                                       $selectedNodeType.val(getAutocompleteType());
                                       $.ajax({url: '/search/?id='+ui.item.id+'&nodes='+network.loadedNodeIds()+'&type='+getAutocompleteType(),
                                               dataType: 'json',
                                               success: function(response) { 
                                                 log('Node kapcsolatai válasz: ', response);
                                                 $(event.target).val('');
                                                 network.discoveredNodes.push($selectedNodeType.val()+$selectedNodeId.val());
                                                 network.draw(response); 
                                               }});
                                     }});
    $("#organization_autocomplete").autocomplete({source: '/organizations/query'});
    $("#people_autocomplete").autocomplete({source: '/people/query'});
    $("#litigation_autocomplete").autocomplete({source: '/litigations/query'});
  });
})(jQuery);
