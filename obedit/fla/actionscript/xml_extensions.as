// Case insensitive recursive search for XML nodes
// that have str as a nodeName.
XMLNode.prototype.getElementsByTagName = function (str)
{
	var nodeArr = new Array();
	var searchNode;
	
	// No child nodes? Return blank array.
	if (!this.hasChildNodes()) return nodeArr;

	// Descend and search children.
	searchNode = this.firstChild;
	while (searchNode != null) 
	{
		// Search for matches
		if (searchNode.nodeType == 1 && searchNode.nodeName.toLowerCase() == str.toLowerCase()) 
		{
			nodeArr.push( searchNode );
		}
		// Search child nodes
    	if (searchNode.nodeType == 1 && searchNode.hasChildNodes()) 
		{
	  		subNodes = new Array();
	  		subNodes = searchNode.getElementsByTagName(str);
	  		if (subNodes.length > 0) 
		  	{
		      	nodeArr = nodeArr.concat( subNodes );
		  	}
		}
		searchNode = searchNode.nextSibling;
	}    
  	return nodeArr;
};

XMLNode.prototype.findTextNode = function (str)
{
	var nodeArr = new Array();
	var searchNode;
	
	// No child nodes? Return blank array.
	if (!this.hasChildNodes()) return nodeArr;

	// Descend and search children.
	searchNode = this.firstChild;
	while (searchNode != null) 
	{
		// Search for matches
		if (searchNode.nodeType == 3 && searchNode.nodeValue.indexOf(str) > 0) 
		{
			nodeArr.push( searchNode );
		}
		// Search child nodes
    	if (searchNode.nodeType == 1 && searchNode.hasChildNodes()) 
		{
	  		subNodes = new Array();
	  		subNodes = searchNode.findTextNode(str);
	  		if (subNodes.length > 0) 
		  	{
		      	nodeArr = nodeArr.concat( subNodes );
		  	}
		}
		searchNode = searchNode.nextSibling;
	}    
  	return nodeArr;
};