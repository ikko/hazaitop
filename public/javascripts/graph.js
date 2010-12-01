(function($) {
  var searched = false,
      network = {
    xgmmlHeader: '<graph label="Cytoscape Web" directed="0" Graphic="1" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:cy="http://www.cytoscape.org" xmlns="http://www.cs.rpi.edu/XGMML">',
    body: '',
    nodes: {arr: []},
    edges: {arr: []},
    nodeIds: [],
    maxWeight: null,
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
    }
  };

  var vis = new org.cytoscapeweb.Visualization("relationgraph", {swfPath: "/swf/CytoscapeWeb", flashInstallerPath: "/swf/playerProductInstall"});
  vis.ready(function() {
    if (!searched) {
      vis.addListener("click", "nodes", function(event) {
        var match = event.target.data.id.match(/^(.*)(\d+)$/),
            type = match[1] == 'p' ? '0' : '1',
            id = match[2];
        $.ajax({url:'/search/?id='+id+'&type='+type+'&nodes='+network.loadedNodeIds(), 
                dataType: 'json',
                success: function(response) {
                  log('Node kapcsolatai válasz: ', response);
                  network.draw(response); 
                }});
      });
      searched = true;
    }
  });

  $(function() {
    $("#search_entities").tabs();
    $(".autocomplete").autocomplete({minLength: '1', 
                                     delay: '500',
                                     select: function(event, ui) {
                                       $.ajax({url: '/search/?id='+ui.item.id+'&type='+$("#search_entities").tabs("option", "selected"),
                                               dataType: 'json',
                                               success: function(response) { 
                                                 log('Node kapcsolatai válasz: ', response);
                                                 network.draw(response); 
                                               }});
                                     }});
    $("#organization_autocomplete").autocomplete({source: '/organizations/query'});
    $("#people_autocomplete").autocomplete({source: '/people/query'});
  });
})(jQuery);
