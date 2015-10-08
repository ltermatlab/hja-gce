function r12_axistitles
%Updates axis titles in R11-saved figures to support zooming in R12
%
%syntax: r12_axistitles
%
%input:
%  none
%
%output:
%  none
%
%(c)2002,2003,2004 Wade M. Sheldon and the Georgia Coastal Ecosystems LTER Project
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
%last modified: 25-Jul-2008


f = [{'title'},{'xlabel'},{'ylabel'},{'zlabel'}];

for n = 1:length(f)
    h = get(gca,f{n});
    str = get(h,'String');
    fn = get(h,'FontName');
    fa = get(h,'FontAngle');
    fs = get(h,'FontSize');
    fw = get(h,'FontWeight');
    rot = get(h,'Rotation');
    ha = get(h,'HorizontalAlignment');
    va = get(h,'VerticalAlignment');
    interp = get(h,'Interpreter');
    delete(h)
    eval([f{n},'(str,''Fontname'',fn,''FontAngle'',fa,''FontSize'',fs,''FontWeight'',fw,', ...
            '''Rotation'',rot,''HorizontalAlignment'',ha,''VerticalAlignment'',va,', ...
            '''Interpreter'',interp,''ButtonDownFcn'',''textedit'')'])

end


