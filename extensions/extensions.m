function extensions(op,data)
%GCE Data Toolbox custom extension handler
%
%syntax: extensions(op,data,argument)
%
%input:
%  op = operation to perform
%  data = data to be passed to the extension operator
%  argument = additional argument or data to be passed to the extension operator
%
%output
%  none
%
%(c)2012-2013 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 15-Apr-2013

%Customization Notes:
%  1. create entries in the 'menus' code block to add menu items to the Data Set Editor,
%     defining a callback using the pattern: 'ui_editor(''extension'',''myfunc'')'),
%     where myfunc is the name of a case in extensions.m for handling data sent from the editor
%  2. create a case statement (i.e. handler) for each menu item that contains code for
%     performing the desired operations on the 'data' variable returned from the editor
%  3. if your custom code requires data be passed back to the calling editor instance,
%     use the command: ui_editor('extension_return',data), where data is the updated data
%     structure to return (note: set focus to the editor using figure(h_editor) before issuing
%     the command to ensure the data are returned to the correct editor instance)
%  4. save the updated m-file as [gce toolbox]/extensions/extensions.m to automatically 
%     load your extensions in new Dataset Editor windows

%set defaults for omitted input
if exist('op','var') ~= 1
   op = '';
end

if exist('data','var') ~= 1
   data = [];
end

%check for calls from an open Dataset Editor instance
if length(findobj) > 1 && strcmp(get(gcf,'Tag'),'dlgDSEditor')
   
   %cache handle of calling editor window
   h_editor = gcf;
   
   %handle operations
   switch op
      
      case 'menus'  %create menu items in Dataset Editor
         
         %add specialized workflows to Tools > Specialized menu
         h_mnuSpecialized = findobj(h_editor,'Type','uimenu','Label','Specialized');
      
         if ~isempty(h_mnuSpecialized)
            
            %GCE-LTER example to add a workflow for calculating plant biomass from site, zone, species
            %uimenu('Parent',h_mnuSpecialized, ...
            %   'Label','Add Plant Biomass', ...
            %   'Callback','ui_editor(''extension'',''add_plant_biomass'')', ...
            %   'Tag','mnuSpecializedPlantBiomass');            
            
         end
         
      %
      % add handlers for custom menu items here as 'case' blocks
      %
      % to return data to the editor instance use:
      %    figure(h_editor)
      %    ui_editor('extension_return',data)
      %
         
      case 'add_plant_biomass'  %add calculated plant biomass
         
         set(h_editor,'Pointer','watch')
         drawnow
         
         [data,msg] = plant_biomass(data);
         
         set(h_editor,'Pointer','arrow')
         drawnow
         
         if ~isempty(data)
            figure(h_editor)  %force focus to calling figure
            ui_editor('extension_return',data)
         end
         
         if ~isempty(msg)
            messagebox('init',msg,'','Warning',[0.9 0.9 0.9]);
         end
         
   end
         
end
return

%
%include specialized subfunctions called by case handlers here as function blocks
%

%function output = myfunction(input)

%end
