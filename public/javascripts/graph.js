var vis;
var network;
(function($) {
  network = {
    xgmmlHeader: '<graph label="Cytoscape Web" directed="0" Graphic="1" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:cy="http://www.cytoscape.org" xmlns="http://www.cs.rpi.edu/XGMML">',
    body: '',
    nodes: {arr: []},
    edges: {arr: []},
    nodeIds: [],
    layout: 'Tree', 
    maxWeight: 1,
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
        // újra parse-olásnál mindig üres edge tömbel kezdünk
        node.edges = [];
      }
    },
    parseEdges: function(edges) {
      for(var i=0; edges.length > i; i++) {
        var edge = edges[i];
        if (!this.edges[edge.id] && edge.alternateId && !this.edges[edge.alternateId]) {
          // ezt az attributot nem toljuk át szerverről mivel mindig defaultba visible
          edge.visible = true;
          this.edges.arr.push(edge);
          this.edges[edge.id] = edge;
          this.nodes[edge.sourceId].edges.push(edge.id);
          this.nodes[edge.targetId].edges.push(edge.id);
          if (edge.alternateId) {this.edges[edge.alternateId] = edge;}
          this.body += this.generateXmlFromEdge(edge);
        }
      }
    },
    generateXmlFromNode: function(node) {
      return "<node id='"+node.id+"' label='"+node.label+"'><graphics type='CIRCLE' outline='#"+this.generateNodeColor(node)+"'  fill='#"+this.generateNodeColor(node)+"'/>"+this.generateNodeAttributes(node)+"</node>"
    },
    generateXmlFromEdge: function(edge) {
      return "<edge id='"+edge.id+"' source='"+edge.sourceId+"' target='"+edge.targetId+"' label='"+edge.label+"'><att type='real' name='weight' value='"+edge.weight+"'/><graphics width='1'/></edge>"; /* "+(edge.weight/this.maxWeight)*10+" */
    },
    generateNodeColor: function(node) {
      if (node.shape == 'CIRCLE') {
        return "7b9d3a";
      } else if (node.shape == 'RECTANGLE') {
        return "cd3403";
        //return "cbff67";
      } else if (node.shape == 'DIAMOND') {
        return "66ccff";
      }
    },
    generateNodeAttributes: function(node) {
      if (node.shape == 'CIRCLE') {
        return "<att name='bornAt' value='"+node.bornAt+"'/><att name='mothersName' value='"+node.mothersName+"'/>"
      } else if (node.shape == 'RECTANGLE') {
        return "<att name='foundedAt' value='"+node.foundedAt+"'/><att name='address' value='"+node.address+"'/><att name='balance' value='"+node.balance+"'/><att name='turnover' value='"+node.turnover+"'/><att name='year' value='"+node.year+"'/>"
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
    clean: function() {
      $("#node_details_tab a").remove();
      $("#map_node_details > .section").remove();
      network.body = '';
      network.nodes = {arr: []};
      network.edges = {arr: []};
      network.nodeIds = [];
      network.discoveredNodes = [];
      network.maxWeight = 1;
      vis.draw({network:[], visualStyle: {global:{backgroundColor: "#010101"}}})
    },
    draw: function(data) {
      vis.draw({network: this.parse(data), 
                edgeLabelsVisible: true, 
                layout: {name: network.layout/*, options:{breadthSpace:50}*/},
                visualStyle: {global:{backgroundColor: "#010101"},nodes:{labelFontColor: "#ffffff", size:65, labelFontSize:11, labelFontWeight:'bold'}, edges:{labelFontColor: "#ffffff", labelFontSize:11, labelFontWeight:'bold'}}});
    },
    loadedNodeIds: function() {
      var resp = '';
      for(var i=0; this.nodeIds.length > i; i++) {
        resp += this.nodeIds[i]+',';
      }
      return resp;
    },
    nodeClicked: function(event) {
      log('Node clicked: ', event);
      var match = event.target.data.id.match(/(.*?)(\d+)$/);
      network.showNodeInfo(network.nodes[event.target.data.id]);
      $selectedElemType.val(match[1]);
      $selectedElemId.val(match[2]);
    },
    edgeClicked: function(event) {
      log('Edge clicked: ', event);
      var match = event.target.data.id.match(/(.*?)(\d+)$/);
      network.showNodeInfo(network.edges[event.target.data.id]);
      $selectedElemType.val(match[1]);
      $selectedElemId.val(match[2]);
    },
    nodeDblClicked: function(event) {
      var label = arguments[1] || event.target.data.label;
      log('Node dblclicked: ', event);
      var id = $selectedElemType.val()+$selectedElemId.val();
      $("#map_node_details > .section").hide();
      $("#node_details_tab a").removeClass('active');
      // ha már betöltöttük akkor mutatjuk, egyébként ajaxos lekérés
      if ($("#"+id+"_content.section").length > 0) {
        $("#"+id+"_content.section").show();
        $("#"+id+"_tab_label").addClass('active');
      } else {
        // létrehozunk egy új tabot és content containert hozzá
        $('#node_details_tab').append("<a href='#' id='"+id+"_tab_label' class='active'>"+label+"</a>");
        $('#map_node_details').append("<div class='section' id='"+id+"'></div>");
        $.ajax({url:'/site_search/node_show?id='+$selectedElemId.val()+'&type='+$selectedElemType.val(), 
                success: function(response) {
                  log('Node részletes infó: ', response);
                  $('#map_node_details .temp').replaceWith(response); 
                  $('#map_node_details').append($('#map_node_details .temp body').html()); 
                }});
      }
      // a tabhoz ugrunk
      window.scrollTo(0, $('#'+id+'_tab_label').position().top)
    },
    showNodeInfo: function(nodeData) {
      if ($.inArray(nodeData.id, this.discoveredNodes) != -1) {
        $loadNodeRelations.hide();
      } else {
        $loadNodeRelations.show();
      }
      $('#profil_link').click();
      
      // ha még nem látszana..
      $('#load_node_details').show();

      $("#node_panel").show();

      var match = nodeData.id.match(/(.*?)(\d+)$/);
      $nodeAttributePanels.hide();
      if (match[1] == 'p') {
        $personNode.show();
        $loadNodeRelations.show();
        $personNode.find(".name").html("<a href='/people/"+nodeData.id.match(/\d+$/)+"'>"+nodeData.label+"</a>");
        $personNode.find(".mothers_name").text(nodeData.mothersName);
        $personNode.find(".born_at").text(nodeData.bornAt);
      } else if (match[1] == 'o'){
        $organizationNode.show();
        $loadNodeRelations.show();
        $organizationNode.find(".name").html("<a href='/organizations/"+nodeData.id.match(/\d+$/)+"'>"+nodeData.label+"</a>");
        $organizationNode.find(".address").text(nodeData.address);
        $organizationNode.find(".founded_at").text(nodeData.foundedAt);
        $organizationNode.find(".year").text(nodeData.year);
        $organizationNode.find(".turnover").text(nodeData.turnover);
        $organizationNode.find(".balance").text(nodeData.balance);
      } else if (match[1] == 'l'){
        $litigationNode.show();
        $loadNodeRelations.show();
        $litigationNode.find(".name").html("<a href='/litigations/"+nodeData.id.match(/\d+$/)+"'>"+nodeData.label+"</a>");
        $litigationNode.find(".start_time").text(nodeData.startTime);
        $litigationNode.find(".end_time").text(nodeData.endTime);
      } else if (match[1] == 'o2o'){
        $o2oEdge.show();
        $loadNodeRelations.hide();
        $o2oEdge.find(".name").text(nodeData.label);
        $o2oEdge.find(".org:first").text(nodeData.org);
        $o2oEdge.find(".org:last").text(nodeData.relatedOrg);
        $o2oEdge.find(".issued_at").text(nodeData.issuedAt);
        $o2oEdge.find(".source").text(nodeData.source);
        $o2oEdge.find(".value").text(nodeData.value);
        if (nodeData.contractOrTender) {
          $o2oEdge.find(".contract").html("<a href='/"+nodeData.contractOrTender+"s/"+nodeData.contractId+"' target='_blank'>"+nodeData.contractName+"</a>");
        } else {
          // ha nincs contract simán 'nincs adat' lesz benne
          $o2oEdge.find(".contract").text(nodeData.contractName);
        }
      } else if (match[1] == 'p2p'){
        $p2pEdge.show();
        $loadNodeRelations.hide();
        $p2pEdge.find(".name").text(nodeData.label);
        $p2pEdge.find(".person:first").text(nodeData.person);
        $p2pEdge.find(".person:last").text(nodeData.relatedPerson);
        $p2pEdge.find(".start_time").text(nodeData.startTime);
        $p2pEdge.find(".end_time").text(nodeData.endTime);
        $p2pEdge.find(".source").text(nodeData.source);
      } else if (match[1] == 'p2o' || match[1] == 'o2p'){
        $p2oEdge.show();
        $loadNodeRelations.hide();
        $p2oEdge.find(".name").text(nodeData.label);
        $p2oEdge.find(".person").text(nodeData.person);
        $p2oEdge.find(".org").text(nodeData.org);
        $p2oEdge.find(".start_time").text(nodeData.startTime);
        $p2oEdge.find(".end_time").text(nodeData.endTime);
        $p2oEdge.find(".source").text(nodeData.source);
      } else if (match[1] == 'o2l'){
        $o2lEdge.show();
        $loadNodeRelations.hide();
        $o2lEdge.find(".name").text(nodeData.label);
        $o2lEdge.find(".org").text(nodeData.org);
        $o2lEdge.find(".litigation").text(nodeData.litigation);
        $o2lEdge.find(".start_time").text(nodeData.startTime);
        $o2lEdge.find(".end_time").text(nodeData.endTime);
        $o2lEdge.find(".source").text(nodeData.source);
      } else if (match[1] == 'p2l'){
        $p2lEdge.show();
        $loadNodeRelations.hide();
        $p2lEdge.find(".person").text(nodeData.person);
        $p2lEdge.find(".litigation").text(nodeData.litigation);
        $p2lEdge.find(".start_time").text(nodeData.startTime);
        $p2lEdge.find(".end_time").text(nodeData.endTime);
        $p2lEdge.find(".source").text(nodeData.source);
      }
    },
    select: function() {
      vis.deselect();
      vis.select($selectedType.val() + 's', [$selectedElemType.val()+$selectedElemId.val()]);
    },
    filter: function() {
      vis.filter('edges', function(edge) {
        var networkEdge = network.edges[edge.data.id],
            visible = $('input[value='+networkEdge.relationTypeId+']').is(':checked');
        networkEdge.visible = visible;   
        return visible;
      });
      vis.filter('nodes', function(node) {
        var nodeEdges = network.nodes[node.data.id].edges,
            visible = false;
        // node annak függvényében látható hogy van e látható kapcsolata
        for (var i=0; nodeEdges.length > i; i++) {
          if (network.edges[nodeEdges[i]].visible) {
            visible = true;
            break;
          }
        }
        return visible;
      });
    },
    showAjaxLoader: function() {
      $relationgraph.html('<img src="/images/network-ajax-loader.gif" class="ajax-loader"/>');
    }
  };

  function setSearchType() {
    $this = $(this);
    if ($this.attr('id') == 'people_autocomplete') {
      $searchType.val('p');
    } else if ($this.attr('id') == 'organization_autocomplete') {
      $searchType.val('o');
    } else {
      $searchType.val('l');
    }
  }

  $(function() {
    var query = location.href.split('#');
    console.log(query)
    if (query[1] == "search_content") {
      $(".tab_content").hide();
      $(".tab").removeClass("active");
      $("#search_content").show();
      $("a[href='#search_content']").parent().addClass("active");
    }

    $selectedElemId = $("#selected_elem_id");
    $selectedElemType = $("#selected_elem_type");
    $selectedType = $("#selected_type");
    $searchType = $("#search_type");
    $personNode = $("#person_node");
    $organizationNode = $("#organization_node");
    $litigationNode = $("#litigation_node");
    $o2oEdge = $("#o2o_edge");
    $p2pEdge = $("#p2p_edge");
    $p2oEdge = $("#p2o_edge");
    $o2lEdge = $("#o2l_edge");
    $p2lEdge = $("#p2l_edge");
    $loadNodeRelations = $("#load_node_relations");
    $nodeAttributePanels = $(".node_attributes");
    $relationgraph = $("#relationgraph");
    $peopleSearchLoader = $("#people_search_ajax_loader");
    $organizationSearchLoader = $("#organizations_search_ajax_loader");
    $litigationSearchLoader = $("#litigations_search_ajax_loader");

    $('#organization_autocomplete').change(setSearchType);
    $('#people_autocomplete').change(setSearchType);
    $('#litigation_autocomplete').change(setSearchType);

    vis = new org.cytoscapeweb.Visualization("relationgraph", {swfPath: "/swf/CytoscapeWeb", flashInstallerPath: "/swf/playerProductInstall"});
    if ($selectedElemType.val().length > 0) {
      log('Konkrét node kapcsolati hálójának kirajzolása');
      network.discoveredNodes.push($selectedElemType.val()+$selectedElemId.val());
      network.draw(xmmlGraph);
    }
    vis.ready(function() {
      if (!network.initialized) {
        vis.addListener("click", "nodes", network.nodeClicked)
        vis.addListener("click", "edges", network.edgeClicked)
        vis.addListener('dblclick', 'nodes', network.nodeDblClicked);
        network.initialized = true;
      }
      // filterezni csak ready eseménykor lehet
      network.filter();
      network.select();
    });

    $loadNodeRelations.click(function(e) {
      e.preventDefault();
      network.showAjaxLoader();
      $.ajax({url:'/site_search/?id='+$selectedElemId.val()+'&type='+$selectedElemType.val()+'&nodes='+network.loadedNodeIds(), 
              dataType: 'json',
              success: function(response) {
                log('Node kapcsolatai válasz: ', response);
                network.discoveredNodes.push($selectedElemType.val()+$selectedElemId.val());
                network.draw(response); 
              }});
    });
    $(".autocomplete").autocomplete({minLength: '1', 
                                     delay: '500',
                                     open: function() {
                                       $searchAjaxLoaders.hide()
                                     },
                                     select: function(event, ui) {
                                       var id;
                                       $selectedElemId.val(ui.item.id);
                                       $selectedElemType.val($searchType.val());
                                       id = $selectedElemType.val()+$selectedElemId.val();
                                       // lehet eddig edge is de most mi mindenképp nodeot fogunk lekérni
                                       $selectedType.val('node');
                                       // ha már felfedeztük  
                                       if ($.inArray(id, network.discoveredNodes) != -1) {
                                         network.select();
                                         network.showNodeInfo(vis.node(id).data);
                                       } else {
                                         network.showAjaxLoader();
                                         $.ajax({url: '/site_search/?id='+ui.item.id+'&nodes='+network.loadedNodeIds()+'&type='+$searchType.val(),
                                                 dataType: 'json',
                                                 success: function(response) { 
                                                   log('Node kapcsolatai válasz: ', response);
                                                   $(event.target).val('');
                                                   network.discoveredNodes.push($selectedElemType.val()+$selectedElemId.val());
                                                   network.draw(response); 
                                                 }});
                                       }
                                     }});

    // hack autocompletehez
    // http://stackoverflow.com/questions/4718968/detecting-no-results-on-jquery-ui-autocomplete
    var __response = $.ui.autocomplete.prototype._response;
    $.ui.autocomplete.prototype._response = function(content) {
        __response.apply(this, [content]);
        this.element.trigger("autocompletesearchcomplete", [content]);
    };

    $("#organization_autocomplete").autocomplete({source: '/organizations/query', 
                                                  search: function() {
                                                    $organizationSearchLoader.show();
                                                  },
                                                  open: function() {
                                                    $organizationSearchLoader.hide();
                                                  }}).bind("autocompletesearchcomplete", function() { $organizationSearchLoader.hide(); });

    $("#people_autocomplete").autocomplete({source: '/people/query', 
                                            search: function() {
                                              $peopleSearchLoader.show();
                                            },
                                            open: function() {
                                              $peopleSearchLoader.hide();
                                            }}).bind("autocompletesearchcomplete", function() { $peopleSearchLoader.hide(); });; 

    $("#litigation_autocomplete").autocomplete({source: '/litigations/query', 
                                                search: function() {
                                                  $litigationSearchLoader.show();
                                                },
                                                open: function() {
                                                  $litigationSearchLoader.hide();
                                                }}).bind("autocompletesearchcomplete", function() { $litigationSearchLoader.hide(); });;
    $("#network_clean").click(function(e) {
      e.preventDefault();
      network.clean();
    });
    $("#checkbox_list input").click(function() {
      network.filter();
    });

    $("#load_node_details").click(function(event) {
      event.preventDefault();
      network.nodeDblClicked(event, $('#person_node ul span:first').text());
    });

    $("#node_details_tab a").live('click', function(e) {
      var id, match = $(this).attr('id').match(/(p|o|l)(\d+)_tab/);
      e.preventDefault();
      $selectedElemType.val(match[1]);
      $selectedElemId.val(match[2]);
      id = $selectedElemType.val() + $selectedElemId.val();

      // lehet edge is de most mi mindenképp nodeot fogunk lekérni
      $selectedType.val('node');
      network.select();
      $("#node_details_tab a").removeClass('active');
      $("#"+id+"_tab_label").addClass('active');
      $("#map_node_details > .section").hide();
      $("#"+id+"_content.section").show();
      network.showNodeInfo(vis.node(id).data);
    });

    $('#graphtype').click( function() {
      network.layout = $(this).val();
      network.draw(network);
    });

    // key event capture lehetőségének visszaállítása html-re (ha esetleg flashen lenne)
    setInterval(function(){
     if ($('#cytoscapeWeb1:focus').length > 0) $('body').attr('tabIndex', 0).focus();
    }, 300);
  });
})(jQuery);
