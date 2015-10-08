// javascript functions called by dataset_details.asp to toggle display of attribute descriptions and show popup help
//
// by Wade Sheldon <sheldon@uga.edu>, Georgia Coastal Ecosystems LTER
// last updated 09-Dec-2010

function showDesc(strID) {
	
	//show descriptions for current entity
	var tagname = 'table' + strID;
	var table = document.getElementById(tagname);
	if (table != null) {
		var cells = table.getElementsByTagName('td');
		if (cells != null) {
			var cnt;
			var cssclass;
			var err;
			for (cnt = 0; cnt < cells.length; cnt++) {
				try {
					cssclass = cells[cnt].className;
				}
				catch(err) {
					cssclass = cells[cnt].getAttribute('class');  //IE syntax
				}
				if (cssclass == "description") {
					try {
						cells[cnt].style.display = 'table-cell';
					}
					catch(err) {				
						cells[cnt].style.setAttribute('display','block');  //IE syntax
					}
				}
			}
		}
	}

	// change show/hide link to hide
	var links = document.getElementById(strID);
	if (links != null) {
		try {
			var str = "(<a href=\"javascript:hideDesc(\'" + strID + "\')\">hide</a>)";
			links.innerHTML = str;
		}
		catch(err) {
		}
	}
	
}

function hideDesc(strID) {
	
	//hide descriptions for current entity
	var tagname = 'table' + strID;
	var table = document.getElementById(tagname);
	if (table != null) {
		var cells = table.getElementsByTagName('td');
		if (cells != null) {
			var cnt;
			var cssclass;
			var err;
			for (cnt = 0; cnt < cells.length; cnt++) {
				try {
					cssclass = cells[cnt].className;
				}
				catch(err) {
					cssclass = cells[cnt].getAttribute('class');  //IE syntax
				}
				if (cssclass == "description") {
					try {
						cells[cnt].style.display = 'none';
					}
					catch(err) {				
						cells[cnt].style.setAttribute('display','none');  //IE syntax
					}
				}
			}
		}
	}

	// change show/hide link to show
	var links = document.getElementById(strID);
	if (links != null) {
		try {
			var str = "(<a href=\"javascript:showDesc(\'" + strID + "\')\">show</a>)";
			links.innerHTML = str;
		}
		catch(err) {
		}
	}
	
}

function openWin(strUrl){
	//open pop-up window to display format help
	var conWin = window.open(strUrl, "formats", "height=700, width=800, status=no, scrollbars=yes, resizable");
}
