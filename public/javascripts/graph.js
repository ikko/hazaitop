var bypass = {nodes:{},edges:{}},
options = {
  swfPath: "/swf/CytoscapeWeb",
  flashInstallerPath: "/swf/playerProductInstall"
}, vis = new org.cytoscapeweb.Visualization("relationgraph", options),
maxWeight=null;

function setMaxWeight() {
  for(var i=0, edges = vis.edges(), edgesLength = edges.length; edgesLength > i; i++) {
    if (edges[i].data.weight > maxWeight) {
      console.log('bent')
      maxWeight = edges[i].data.weight;
      log('új maxWeight: '+maxWeight)
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
  log('Új node-ok befűzése')
  var bypass = {nodes:{},edges:{}};
  // hozzáadjuk az új node-okat
  for (var i=0; response.nodes.length > i;i++) {
    var node = response.nodes[i];  
    // csak akkor fűzzük be a node-ot ha még nincs a networkba
    if (!vis.node(node.id)) {
      vis.addNode(event.mouseX, event.mouseY, {id: node.id, label: node.label});
      bypass.nodes[node.id] = {shape: node.shape};
    }
    // csak akkor füzzük be az edge-t ha még nincs a networkba
    if (!vis.edge(node.relationId)) {
      vis.addEdge({id: node.relationId,
                   source: node.id, 
                   target: event.target.data.id, 
                   label: node.relationLabel,
                   weight: node.relationWeight});
      bypass.edges[node.relationId] = {width:(node.relationWeight/maxWeight)*10};
    }
  }
  console.log(bypass)
  // megrajzoljuk őket helyesen
  vis.visualStyleBypass(bypass);
}

jQuery(function($) {
  $("#search_entities").tabs();
  $(".ui-tabs .ui-widget-content").css('height', '400px');
  $(".autocomplete").autocomplete({minLength: '1', 
                                   delay: '500',
                                   select: function(event, ui) {
                                     $.ajax({url: '/search/?id='+ui.item.id+'&type='+$("#search_entities").tabs("option", "selected"),
                                             dataType: 'text',
                                             success: function(graphml) {
                                               log(graphml);
                                               vis.draw({network: graphml, 
                                                         edgeLabelsVisible: true, 
                                                         layout: 'Circle', 
                                                         visualStyle: {nodes:{size:51, labelFontSize:10}, edges:{labelFontSize:10}}});
                                               vis.ready(function() {
                                                 setMaxWeight();
                                                 vis.addListener("click", "nodes", function(event) {
                                                   $.ajax({url:'/search/?id='+event.target.data.id,
                                                           dataType: 'json',
                                                           success: function(response) {
                                                             log(response);
                                                             // ha a válaszban van olyan node-ok maxWeight-je nagyobb az aktuálisnál, 
                                                             // akkor arányosan átrajzoljuk a meglévő kapcsolati súlyozást
                                                             if (response.maxWeight>maxWeight) {
                                                               log("Refreshing weights' widths")
                                                               maxWeight = response.maxWeight;
                                                               refreshEdgesWeights();
                                                             }

                                                             // beillesztjük és össszekötjük az új node-okat a target node-al
                                                             // valamint rendesen belőjük a megjelenésüket
                                                             addNewNodes(response, event);

                                                             // újrarapozícionáltatjuk a networkot
                                                             vis.layout({name:'Circle'});
                                                           }});
                                                 });
                                               });
                                             }});
                                   }});
  $("#organization_autocomplete").autocomplete({source: '/organizations/query'});
  $("#people_autocomplete").autocomplete({source: '/people/query'});
});
