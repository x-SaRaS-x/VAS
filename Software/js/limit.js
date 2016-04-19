
function limitJSON (data, limit) {
	
	var newJSON = {
			"nodes": [ ],
			"links": [ ]
		};

	for (var i = 0; (i < data.nodes.length && i <= limit); i++) {

		newJSON.nodes.push( {
			'Row ID': data.nodes[i]['Row ID'],
	        'Tweet ID': data.nodes[i]['Tweet ID'],
	        'Username': data.nodes[i]['Username'],
	        'Tweet': data.nodes[i]['Tweet'],
	        'Time': data.nodes[i]['Time'],
	        'Tweet Type': data.nodes[i]['Tweet Type'],
	        'Retweeted by': data.nodes[i]['Retweeted by'],
	        'Number of Retweets': data.nodes[i]['Number of Retweets'],
	        'Hashtags': data.nodes[i]['Hashtags'],
	        'Mentions': data.nodes[i]['Mentions'],
	        'name': data.nodes[i]['Name'],
	        'Location': data.nodes[i]['Location'],
	        'Web': data.nodes[i]['Web'],
	        'Bio': data.nodes[i]['Bio'],
	        'Number of Tweets': data.nodes[i]['Number of Tweets'],
	        'Number of Followers': data.nodes[i]['Number of Followers'],
	        'Number Following': data.nodes[i]['Number Following'],
	        'Location Coordinates': data.nodes[i]['Location Coordinates'],
	        'Cluster': data.nodes[i]['Cluster']
		});
	};

	return newJSON;
};