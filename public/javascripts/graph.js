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
      return "<node id='"+node.id+"' label='"+node.label+"'><graphics type='"+node.shape+"' "+(node.shape=='DIAMOND' ? "w='35'":"")+"/>"+this.generateNodeAttributes(node)+"</node>"
    },
    generateXmlFromEdge: function(edge) {
      return "<edge id='"+edge.id+"' source='"+edge.sourceId+"' target='"+edge.targetId+"' label='"+edge.label+"'><att type='real' name='weight' value='"+edge.weight+"'/><graphics width='"+(edge.weight/this.maxWeight)*10+"'/></edge>"
    },
    generateNodeAttributes: function(node) {
      if (node.shape == 'CIRCLE') {
        return "<att name='bornAt' value='"+node.bornAt+"'/><att name='mothersName' value='"+node.mothersName+"'/>"
      } else if (node.shape == 'RECTANGLE') {
        return "<att name='foundedAt' value='"+node.foundedAt+"'/><att name='address' value='"+node.address+"'/>"
      } else if (node.shape == 'DIAMOND') {
        return "<att name='startTime' value='"+node.startTime+"'/><att name='endTime' value='"+node.endTime+"'/>"
      }
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
        $personNode.find("#person_name").text(nodeData.label);
        $personNode.find("#mothers_name").text(nodeData.mothersName);
        $personNode.find("#born_at").text(nodeData.bornAt);
      } else if (match[1] == 'o'){
        $nodeAttributePanels.hide();
        $organizationNode.show();
        $selectedNodeType.val('o');
        $organizationNode.find("#organization_name").text(nodeData.label);
        $organizationNode.find("#address").text(nodeData.address);
        $organizationNode.find("#founded_at").text(nodeData.foundedAt);
      } else if (match[1] == 'l'){
        $nodeAttributePanels.hide();
        $litigationNode.show();
        $selectedNodeType.val('l');
        $litigationNode.find("#litigation_name").text(nodeData.label);
        $litigationNode.find("#start_time").text(nodeData.startTime);
        $litigationNode.find("#end_time").text(nodeData.endTime);
      }
      $selectedNodeId.val(match[2]);
    },
    showAjaxLoader: function() {
      $relationgraph.html('<img src="/images/network-ajax-loader.gif" class="ajax-loader"/>');
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
    $relationgraph = $("#relationgraph");
    $searchTabPeopleLoader = $("#search_tab_people .ajax_loader");
    $searchTabOrganizationLoader = $("#search_tab_organizations .ajax_loader");
    $searchTabLitigationLoader = $("#search_tab_litigations .ajax_loader");
    $searchAjaxLoaders = $("#search_entities .ajax_loader");

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
      network.showAjaxLoader();
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
                                     open: function() {
                                       $searchAjaxLoaders.hide()
                                     },
                                     select: function(event, ui) {
                                       network.showAjaxLoader();
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
    $("#organization_autocomplete").autocomplete({source: '/organizations/query', 
                                                  search: function() {
                                                  log('lofi')
                                                    $searchAjaxLoaders.hide()
                                                    $searchTabOrganizationLoader.show();
                                                  }});
    $("#people_autocomplete").autocomplete({source: '/people/query', 
                                            search: function() {
                                              $searchAjaxLoaders.hide()
                                              $searchTabPeopleLoader.show();
                                            }}); 
    $("#litigation_autocomplete").autocomplete({source: '/litigations/query', 
                                                search: function() {
                                                  $searchAjaxLoaders.hide()
                                                  $searchTabLitigationLoader.show();
                                                }});
  });
})(jQuery);
