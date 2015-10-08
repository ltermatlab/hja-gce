function meta = meta_fields(style)
%Returns an array of metadata categories and fields for a named metadata style
%
%syntax: meta = meta_fields(style)
%
%input:
%  style = named metadata style in 'metastyles.mat' (default = 'FLED')
%
%output:
%  meta = nx3 array of metadata categories, fields, and empty values
%
%(c)2002-2014 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 08-Sep-2014

%init output
meta = [];

%check for style file in path
if exist('metastyles.mat','file') == 2
    
    %set default style if omitted
    if exist('style','var') ~= 1
        style = 'FLED';
    end
    
    %load styles file
    try
        v = load('metastyles.mat');
    catch
        v = struct('null','');
    end
    
    %check for valid file with styles structure
    if isfield(v,'styles')
        
        %match style specification
        styles = v.styles;
        Istyle = find(strcmp({styles.name},style));
        
        if ~isempty(Istyle)
            
            %extract metadata fields for style
            flds = styles(Istyle(1)).metafields;
            
            %init runtime vars
            numflds = length(flds);
            meta = repmat({''},numflds,3);
            Ivalid = zeros(numflds,1);
            
            %loop through fields and parse into categories, fields
            for n = 1:numflds
                fld = flds{n};
                Isep = strfind(fld,'_');
                if ~isempty(Isep)
                    meta{n,1} = fld(1:Isep(1)-1);  %split category
                    meta{n,2} = fld(Isep(1)+1:end);  %grab remainder as field
                    Ivalid(n) = 1;  %set valid flag
                end
            end
            
            %get index of valid entries
            Ivalid = Ivalid == 1;
            
            %filter metadata array to only include valid entries
            meta = meta(Ivalid,:);
            
            %call external function to add supported subfields
            meta = meta_subfields(meta);
            
        end
        
    end
    
end