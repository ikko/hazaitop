var vis;
(function($) {
  var bypass = {nodes:{},edges:{}},
      options = {swfPath: "/swf/CytoscapeWeb", flashInstallerPath: "/swf/playerProductInstall"}, 
      maxWeight=null,
      searched=false;

  vis = new org.cytoscapeweb.Visualization("relationgraph", options),

  vis.ready(function() {
    setMaxWeight();
    if (!searched) {
      vis.addListener("click", "nodes", function(event) {
        $.ajax({url:'/search/?id='+event.target.data.id,
                dataType: 'json',
                success: function(response) {
                  // ha a válaszban van olyan node-ok maxWeight-je nagyobb az aktuálisnál, 
                  // akkor arányosan átrajzoljuk a meglévő kapcsolati súlyozást
                  if (response.maxWeight>maxWeight) {
                    maxWeight = response.maxWeight;
                    refreshEdgesWeights();
                  }

                  // beillesztjük és össszekötjük az új node-okat a target node-al
                  // valamint rendesen belőjük a megjelenésüket
                  addNewNodes(response, event);

                  // újrarapozícionáltatjuk a networkot
                  vis.layout({name:'Circle',nodes: { shape: { passthroughMapper: { attrName: "shape" } } } });
                }});
      });
      // egyszerű flag hogy új keresésnél amikor kirajzoljuk az új gráfot ne
      // bindoljuk újra a node click eseményt
      searched = true;
    }
  });

  function setMaxWeight() {
    for(var i=0, edges = vis.edges(), edgesLength = edges.length; edgesLength > i; i++) {
      if (edges[i].data.weight > maxWeight) {
        maxWeight = edges[i].data.weight;
      }
    }
  }

  function refreshEdgesWeights() {
    var bypass = {edges:{}};
    for(var i=0, edges = vis.edges(), edgesLength = edges.length; edgesLength > i; i++) {
      var obj = edges[i];
      bypass.edges[obj.data.id] = {width:(obj.data.weight/maxWeight)*10};
    }
    vis.visualStyleBypass(bypass);
  }

  function addNewNodes(response, event) {
    var bypass = {nodes:{},edges:{}};
    // hozzáadjuk az új node-okat
    for (var i=0; response.nodes.length > i;i++) {
      var node = response.nodes[i];  
      // csak akkor fűzzük be a node-ot ha még nincs a networkba
      if (!vis.node(node.id)) {
        vis.addNode(event.mouseX, event.mouseY, {id: node.id, label: node.label, shape: node.shape}, false);
        bypass.nodes[node.id] = {shape: node.shape};
      }
      // csak akkor füzzük be az edge-t ha még nincs a networkba
      if (!vis.edge(node.relationId) && !vis.edge(node.alternateRelationId)) {
        vis.addEdge({id: node.relationId,
                     source: node.id, 
                     target: event.target.data.id, 
                     label: node.relationLabel,
                     weight: node.relationWeight}, false);
        bypass.edges[node.relationId] = {width:(node.relationWeight/maxWeight)*10};
      }
    }
    // megrajzoljuk őket helyesen
    vis.visualStyleBypass(bypass);
  }

  $(function() {
    $("#search_entities").tabs();
    $(".ui-tabs .ui-widget-content").css('height', '400px');
    $(".autocomplete").autocomplete({minLength: '1', 
                                     delay: '500',
                                     select: function(event, ui) {
                                       $.ajax({url: '/search/?id='+ui.item.id+'&type='+$("#search_entities").tabs("option", "selected"),
                                               dataType: 'text',
                                               success: function(response) {
                                                 log(response);
                                                 vis.draw({network: response, 
                                                           edgeLabelsVisible: true, 
                                                           layout: 'Circle', 
                                                           visualStyle: {nodes:{size:51, labelFontSize:10}, edges:{labelFontSize:10}}});
                                               }});
                                     }});
    $("#organization_autocomplete").autocomplete({source: '/organizations/query'});
    $("#people_autocomplete").autocomplete({source: '/people/query'});
  });
})(jQuery);
