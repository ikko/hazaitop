class SearchController < ApplicationController

  hobo_controller

  def organization_node(resource)
    "<node id='o#{resource.id}'><data key='label'>#{resource.name}</data><data key='shape'>DIAMOND</data></node>"
  end

  def person_node(resource)
    "<node id='p#{resource.id}'><data key='label'>#{resource.last_name}, #{resource.first_name}</data></node>"
  end

  def index
    # type 0: person, 1: organization
    if params[:id] && params[:type]
      graphml = <<-GRAPHML
<graphml>
  <key id='shape' for='node' attr.name='shape' attr.type='string'><default>RECTANGLE</default></key>
  <key id='label' for='node' attr.name='label' attr.type='string'/>
  <graph>  
GRAPHML
      if params[:type]=='0' && resource = Person.find_by_id(params[:id])
        graphml << person_node(resource)
        personal_relations = resource.personal_relations
        organizations = resource.organizations
        personal_relations.each do |person|
          graphml << person_node(person)
        end
        organizations.each do |org|
          graphml << organization_node(org)
        end
      else resource = Organization.find_by_id(params[:id])
        graphml << organization_node(resource)
        persons = resource.persons
      end
      render :text => (graphml << "</graph></graphml>")
    end
    @graphml = '
<graphml xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd" xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <key id="weight" for="node" attr.name="weight" attr.type="double">
    <default>0.2</default>
  </key>
  <key id="label" for="node" attr.name="label" attr.type="string"/>
  <key id="shape" for="node" attr.name="shape" attr.type="string">
    <default>DIAMOND</default>
  </key>
  <key id="network" for="edge" attr.name="network" attr.type="string">
    <default>2</default>
  </key>
  <key id="weight" for="edge" attr.name="weight" attr.type="double"/>
  <key id="label" for="edge" attr.name="label" attr.type="string"/>
  <key id="sourceArrowShape" for="edge" attr.name="sourceArrowShape" attr.type="string"/>
  <key id="targetArrowShape" for="edge" attr.name="targetArrowShape" attr.type="string"/>
  <graph edgedefault="undirected">
    <node id="a01">
      <data key="shape">ELLIPSE</data>
      <data key="weight">0.45</data>
      <data key="label">A01</data>
    </node>
    <node id="a02">
      <data key="shape">TRIANGLE</data>
      <data key="weight">0.22</data>
      <data key="label">A02</data>
    </node>
    <node id="a03">
      <data key="shape">OCTAGON</data>
      <data key="weight">0.09</data>
      <data key="label">A03</data>
    </node>
    <node id="a04">
      <data key="weight">0.03</data>
      <data key="label">A04</data>
    </node>
    <node id="a05">
      <data key="shape">PARALLELOGRAM</data>
      <data key="weight">0.1</data>
      <data key="label">A05</data>
    </node>
    <node id="a06">
      <data key="shape">ROUNDRECT</data>
      <data key="weight">0.12</data>
      <data key="label">A06</data>
    </node>
    <node id="a07">
      <data key="shape">RECTANGLE</data>
      <data key="weight">0.07</data>
      <data key="label">A07</data>
    </node>
    <node id="a08">
      <data key="shape">HEXAGON</data>
      <data key="weight">0.16</data>
      <data key="label">A08</data>
    </node>
    <node id="a09">
      <data key="shape">VEE</data>
      <data key="weight">0.45</data>
      <data key="label">A09</data>
    </node>
    <edge source="a02" id="e1" directed="true" target="a01">
      <data key="network">25</data>
      <data key="weight">0.4</data>
      <data key="targetArrowShape">diamond</data>
      <data key="sourceArrowShape">diamond</data>
      <data key="label">a01 (25) a02</data>
    </edge>
    <edge source="a01" id="e2" directed="true" target="a02">
      <data key="network">14</data>
      <data key="weight">0.6</data>
      <data key="targetArrowShape">T</data>
      <data key="sourceArrowShape">delta</data>
      <data key="label">a02 (14) a01</data>
    </edge>
    <edge source="a01" id="e3" directed="true" target="a04">
      <data key="network">25</data>
      <data key="weight">0.2</data>
      <data key="targetArrowShape">circle</data>
      <data key="sourceArrowShape">circle</data>
      <data key="label">a01 (25) a04</data>
    </edge>
    <edge source="a03" id="e4" directed="true" target="a02">
      <data key="network">15</data>
      <data key="weight">0.8</data>
      <data key="targetArrowShape">circle</data>
      <data key="sourceArrowShape">diamond</data>
      <data key="label">a02 (15) a03</data>
    </edge>
    <edge source="a06" id="e5" target="a02">
      <data key="weight">0.2</data>
      <data key="targetArrowShape">none</data>
      <data key="sourceArrowShape">none</data>
      <data key="label">a02 (2) a06</data>
    </edge>
    <edge source="a02" id="e6" target="a06">
      <data key="weight">0.2</data>
      <data key="targetArrowShape">none</data>
      <data key="sourceArrowShape">none</data>
      <data key="label">a06 (2) a02</data>
    </edge>
    <edge source="a04" id="e7" directed="true" target="a03">
      <data key="network">15</data>
      <data key="weight">0.1</data>
      <data key="targetArrowShape">T</data>
      <data key="sourceArrowShape">diamond</data>
      <data key="label">a03 (24) a04</data>
    </edge>
    <edge source="a01" id="e8" target="a05">
      <data key="weight">0.1</data>
      <data key="targetArrowShape">delta</data>
      <data key="sourceArrowShape">circle</data>
      <data key="label">a05 (2) a01</data>
    </edge>
    <edge source="a01" id="e9" target="a05">
      <data key="network">24</data>
      <data key="weight">0.2</data>
      <data key="targetArrowShape">delta</data>
      <data key="sourceArrowShape">delta</data>
      <data key="label">a05 (24) a01</data>
    </edge>
    <edge source="a01" id="e10" target="a05">
      <data key="network">14</data>
      <data key="weight">0.4</data>
      <data key="targetArrowShape">none</data>
      <data key="sourceArrowShape">none</data>
      <data key="label">a05 (14) a01</data>
    </edge>
    <edge source="a07" id="e11" target="a03">
      <data key="weight">0.3</data>
      <data key="targetArrowShape">delta</data>
      <data key="sourceArrowShape">T</data>
      <data key="label">a03 (2) a07</data>
    </edge>
    <edge source="a08" id="e12" target="a04">
      <data key="network">14</data>
      <data key="weight">0.2</data>
      <data key="targetArrowShape">T</data>
      <data key="sourceArrowShape">T</data>
      <data key="label">a04 (14) a08</data>
    </edge>
    <edge source="a04" id="e13" target="a09">
      <data key="weight">0.8</data>
      <data key="targetArrowShape">arrow</data>
      <data key="sourceArrowShape">T</data>
      <data key="label">a09 (2) a04</data>
    </edge>
  </graph>
</graphml>'.gsub("\n", '')


=begin
  <key id='weight' for='node' attr.name='weight' attr.type='double'>
      <default>0.2</default>
  </key>
  <key id='label' for='node' attr.name='label' attr.type='string'/>
  <key id='shape' for='node' attr.name='shape' attr.type='string'>
      <default>DIAMOND</default>
  </key>
  
  <key id='network' for='edge' attr.name='network' attr.type='string'>
      <default>2</default>
  </key>
  <key id='weight' for='edge' attr.name='weight' attr.type='double'/>
  <key id='label' for='edge' attr.name='label' attr.type='string'/>
  <key id='sourceArrowShape' for='edge' attr.name='sourceArrowShape' attr.type='string'/>
  <key id='targetArrowShape' for='edge' attr.name='targetArrowShape' attr.type='string'/>
  
  <graph edgedefault='undirected'>  
    <node id='a01'>
      <data key='weight'>0.45</data>
      <data key='label'>A01</data>
      <data key='shape'>ELLIPSE</data>
    </node>
    <node id='a02'>
      <data key='weight'>0.22</data>
      <data key='label'>A02</data>
      <data key='shape'>TRIANGLE</data>
    </node>
    <node id='a03'>
      <data key='weight'>0.09</data>
      <data key='label'>A03</data>
      <data key='shape'>OCTAGON</data>
    </node>
    <node id='a04'>
      <data key='weight'>0.03</data>
      <data key='label'>Árvíztűrőtükörfúrógép</data>
      <data key='shape'>DIAMOND</data>
    </node>
    <node id='a05'>
      <data key='weight'>0.10</data>
      <data key='label'>A05</data>
      <data key='shape'>PARALLELOGRAM</data>
    </node>
    <node id='a06'>
      <data key='weight'>0.12</data>
      <data key='label'>A06</data>
      <data key='shape'>ROUNDRECT</data>
    </node>
    <node id='a07'>
      <data key='weight'>0.07</data>
      <data key='label'>A07</data>
      <data key='shape'>RECTANGLE</data>
    </node>
    <node id='a08'>
      <data key='weight'>0.16</data>
      <data key='label'>A08</data>
      <data key='shape'>HEXAGON</data>
    </node>
    <node id='a09'>
      <data key='weight'>0.45</data>
      <data key='label'>A09</data>
      <data key='shape'>VEE</data>
    </node>
 
    <edge target='a01' source='a02' directed='true'>
      <data key='network'>25</data>
      <data key='weight'>0.4</data>
      <data key='label'>a01 (25) a02</data>
      <data key='sourceArrowShape'>diamond</data>
      <data key='targetArrowShape'>diamond</data>
    </edge>
    <edge target='a02' source='a01' directed='true'>
      <data key='network'>14</data>
      <data key='weight'>0.6</data>
      <data key='label'>a02 (14) a01</data>
      <data key='sourceArrowShape'>delta</data>
      <data key='targetArrowShape'>T</data>
    </edge>
    <edge target='a04' source='a01' directed='true'>
      <data key='network'>25</data>
      <data key='weight'>0.2</data>
      <data key='label'>a01 (25) a04</data>
      <data key='sourceArrowShape'>circle</data>
      <data key='targetArrowShape'>circle</data>
    </edge>
    <edge target='a02' source='a03' directed='true'>
      <data key='network'>15</data>
      <data key='weight'>0.8</data>
      <data key='label'>a02 (15) a03</data>
      <data key='sourceArrowShape'>diamond</data>
      <data key='targetArrowShape'>circle</data>
    </edge>
    <edge target='a02' source='a06'>
      <data key='network'>2</data>
      <data key='weight'>0.2</data>
      <data key='label'>a02 (2) a06</data>
      <data key='sourceArrowShape'>none</data>
      <data key='targetArrowShape'>none</data>
    </edge>
    <edge target='a06' source='a02'>
      <data key='network'>2</data>
      <data key='weight'>0.2</data>
      <data key='label'>a06 (2) a02</data>
      <data key='sourceArrowShape'>none</data>
      <data key='targetArrowShape'>none</data>
    </edge>
    <edge target='a03' source='a04' directed='true'>
      <data key='network'>15</data>
      <data key='weight'>0.1</data>
      <data key='label'>a03 (24) a04</data>
      <data key='sourceArrowShape'>diamond</data>
      <data key='targetArrowShape'>T</data>
    </edge>
    <edge target='a05' source='a01'>
      <data key='network'>2</data>
      <data key='weight'>0.1</data>
      <data key='label'>a05 (2) a01</data>
      <data key='sourceArrowShape'>circle</data>
      <data key='targetArrowShape'>delta</data>
    </edge>
    <edge target='a05' source='a01'>
      <data key='network'>24</data>
      <data key='weight'>0.2</data>
      <data key='label'>a05 (24) a01</data>
      <data key='sourceArrowShape'>delta</data>
      <data key='targetArrowShape'>delta</data>
    </edge>
    <edge target='a05' source='a01'>
      <data key='network'>14</data>
      <data key='weight'>0.4</data>
      <data key='label'>a05 (14) a01</data>
      <data key='sourceArrowShape'>none</data>
      <data key='targetArrowShape'>none</data>
    </edge>
    <edge target='a03' source='a07'>
      <data key='network'>2</data>
      <data key='weight'>0.3</data>
      <data key='label'>a03 (2) a07</data>
      <data key='sourceArrowShape'>T</data>
      <data key='targetArrowShape'>delta</data>
    </edge>
    <edge target='a04' source='a08'>
      <data key='network'>14</data>
      <data key='weight'>0.2</data>
      <data key='label'>a04 (14) a08</data>
      <data key='sourceArrowShape'>T</data>
      <data key='targetArrowShape'>T</data>
    </edge>
    <edge target='a09' source='a04'>
      <data key='network'>2</data>
      <data key='weight'>0.8</data>
      <data key='label'>a09 (2) a04</data>
      <data key='sourceArrowShape'>T</data>
      <data key='targetArrowShape'>arrow</data>
    </edge>
  </graph>
</graphml>".gsub("\n", "")

=begin
  <key id='weight' for='node' attr.name='weight' attr.type='double'>
      <default>0.2</default>
  </key>
  
  <key id='network' for='edge' attr.name='network' attr.type='string'>
      <default>2</default>
  </key>
  <key id='weight' for='edge' attr.name='weight' attr.type='double'/>
  <key id='label' for='edge' attr.name='label' attr.type='string'/>
  <key id='sourceArrowShape' for='edge' attr.name='sourceArrowShape' attr.type='string'/>
  <key id='targetArrowShape' for='edge' attr.name='targetArrowShape' attr.type='string'/>
  
  <graph edgedefault='undirected'>  
    <node id='a01'>
      <data key='weight'>0.45</data>
      <data key='label'>A01</data>
      <data key='shape'>ELLIPSE</data>
    </node>
    <node id='a02'>
      <data key='weight'>0.22</data>
      <data key='label'>A02</data>
      <data key='shape'>TRIANGLE</data>
    </node>
    <node id='a03'>
      <data key='weight'>0.09</data>
      <data key='label'>A03</data>
      <data key='shape'>OCTAGON</data>
    </node>
    <node id='a04'>
      <data key='weight'>0.03</data>
      <data key='label'>Árvíztűrőtükörfúrógép</data>
      <data key='shape'>DIAMOND</data>
    </node>
    <node id='a05'>
      <data key='weight'>0.10</data>
      <data key='label'>A05</data>
      <data key='shape'>PARALLELOGRAM</data>
    </node>
    <node id='a06'>
      <data key='weight'>0.12</data>
      <data key='label'>A06</data>
      <data key='shape'>ROUNDRECT</data>
    </node>
    <node id='a07'>
      <data key='weight'>0.07</data>
      <data key='label'>A07</data>
      <data key='shape'>RECTANGLE</data>
    </node>
    <node id='a08'>
      <data key='weight'>0.16</data>
      <data key='label'>A08</data>
      <data key='shape'>HEXAGON</data>
    </node>
    <node id='a09'>
      <data key='weight'>0.45</data>
      <data key='label'>A09</data>
      <data key='shape'>VEE</data>
    </node>
 
    <edge target='a01' source='a02' directed='true'>
      <data key='network'>25</data>
      <data key='weight'>0.4</data>
      <data key='label'>a01 (25) a02</data>
      <data key='sourceArrowShape'>diamond</data>
      <data key='targetArrowShape'>diamond</data>
    </edge>
    <edge target='a02' source='a01' directed='true'>
      <data key='network'>14</data>
      <data key='weight'>0.6</data>
      <data key='label'>a02 (14) a01</data>
      <data key='sourceArrowShape'>delta</data>
      <data key='targetArrowShape'>T</data>
    </edge>
    <edge target='a04' source='a01' directed='true'>
      <data key='network'>25</data>
      <data key='weight'>0.2</data>
      <data key='label'>a01 (25) a04</data>
      <data key='sourceArrowShape'>circle</data>
      <data key='targetArrowShape'>circle</data>
    </edge>
    <edge target='a02' source='a03' directed='true'>
      <data key='network'>15</data>
      <data key='weight'>0.8</data>
      <data key='label'>a02 (15) a03</data>
      <data key='sourceArrowShape'>diamond</data>
      <data key='targetArrowShape'>circle</data>
    </edge>
    <edge target='a02' source='a06'>
      <data key='network'>2</data>
      <data key='weight'>0.2</data>
      <data key='label'>a02 (2) a06</data>
      <data key='sourceArrowShape'>none</data>
      <data key='targetArrowShape'>none</data>
    </edge>
    <edge target='a06' source='a02'>
      <data key='network'>2</data>
      <data key='weight'>0.2</data>
      <data key='label'>a06 (2) a02</data>
      <data key='sourceArrowShape'>none</data>
      <data key='targetArrowShape'>none</data>
    </edge>
    <edge target='a03' source='a04' directed='true'>
      <data key='network'>15</data>
      <data key='weight'>0.1</data>
      <data key='label'>a03 (24) a04</data>
      <data key='sourceArrowShape'>diamond</data>
      <data key='targetArrowShape'>T</data>
    </edge>
    <edge target='a05' source='a01'>
      <data key='network'>2</data>
      <data key='weight'>0.1</data>
      <data key='label'>a05 (2) a01</data>
      <data key='sourceArrowShape'>circle</data>
      <data key='targetArrowShape'>delta</data>
    </edge>
    <edge target='a05' source='a01'>
      <data key='network'>24</data>
      <data key='weight'>0.2</data>
      <data key='label'>a05 (24) a01</data>
      <data key='sourceArrowShape'>delta</data>
      <data key='targetArrowShape'>delta</data>
    </edge>
    <edge target='a05' source='a01'>
      <data key='network'>14</data>
      <data key='weight'>0.4</data>
      <data key='label'>a05 (14) a01</data>
      <data key='sourceArrowShape'>none</data>
      <data key='targetArrowShape'>none</data>
    </edge>
    <edge target='a03' source='a07'>
      <data key='network'>2</data>
      <data key='weight'>0.3</data>
      <data key='label'>a03 (2) a07</data>
      <data key='sourceArrowShape'>T</data>
      <data key='targetArrowShape'>delta</data>
    </edge>
    <edge target='a04' source='a08'>
      <data key='network'>14</data>
      <data key='weight'>0.2</data>
      <data key='label'>a04 (14) a08</data>
      <data key='sourceArrowShape'>T</data>
      <data key='targetArrowShape'>T</data>
    </edge>
    <edge target='a09' source='a04'>
      <data key='network'>2</data>
      <data key='weight'>0.8</data>
      <data key='label'>a09 (2) a04</data>
      <data key='sourceArrowShape'>T</data>
      <data key='targetArrowShape'>arrow</data>
    </edge>
  </graph>
</graphml>".gsub("\n", "")
=end
  end
end
