function c = evalXpath(doc,xpaths)
%Evaluates xpath expressions on an XML document nodeset and returns an array of text contents
%
%syntax: c = evalXpath(xml,xpaths)
%
%input:
%  doc = parsed XML document nodeset (from 'readxml')
%  xpaths = nx1 cell array of xpath expressions to evaluate
%
%output:
%  c = cell array containing node values for each xpath
%
%notes:
%  1) the dimension of c matches doc, with one cell per xpath
%  2) only text nodes are returned - if the xpath matches a node with child elements
%     then empty strings will be returned
%  3) if multiple text nodes are matched then the element of c will contain a cell array of strings
%
%(c)2012 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
%
%This file is part of the GCE Data Toolbox for MATLAB(r) software library.
%
%The GCE Data Toolbox is free software: you can redistribute it and/or modify it under the terms
%of the GNU General Public License as published by the Free Software Foundation, either version 3
%of the License, or (at your option) any later version.
%
%The GCE Data Toolbox is distributed in the hope that it will be useful, but WITHOUT ANY
%WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
%PURPOSE. See the GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License along with The GCE Data Toolbox
%as 'license.txt'. If not, see <http://www.gnu.org/licenses/>.
%
%contact:
%  Wade Sheldon
%  GCE-LTER Project
%  Department of Marine Sciences
%  University of Georgia
%  Athens, GA 30602-3636
%  sheldon@uga.edu
%
%last modified: 18-Feb-2012

%init output
c = [];

%check for required arguments
if nargin == 2
   
   %check for character array xpath, convert to cell
   if ischar(xpaths)
      xpaths = cellstr(xpaths);
   end
   
   %load Java xpath classes and create an xpath expression factory instance
   try
      import javax.xml.xpath.*
      factory = XPathFactory.newInstance;
      xpath = factory.newXPath;      
   catch
      factory = [];
      xpath = [];
   end
   
   if ~isempty(factory) && ~isempty(xpath)
      
      %init cell array for output
      c = cell(length(xpaths),1);
   
      %loop through xpaths
      for n = 1:length(xpaths)
         
         %compile expression
         expression = xpath.compile(xpaths{n});
         
         %apply the expression to the DOM and return a nodeset
         nodeList = expression.evaluate(doc,XPathConstants.NODESET);
         
         %get number of nodes
         numnodes = nodeList.getLength;
         
         %init temp cell array
         tmp = repmat({''},numnodes,1);
         
         %iterate through the nodes that are returned.
         for i = 1:numnodes
            node = nodeList.item(i-1);  %get node item from node list
            tmp{i} = char(node.getFirstChild.getNodeValue);  %convert node contents to character array
         end
         
         %update master array
         c{n} = tmp;
         
      end
      
      %clean up objects
      clear factory xpath
      
   else
      warning('this function requires Java javax.xml.xpath.* classes with an XpathFactory method')
   end
   
end