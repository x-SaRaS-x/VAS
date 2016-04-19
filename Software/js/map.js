
function geoJSON (data) {
	
	var gJSON = {
			'type': 'FeatureCollection',
			'features': [ ]
		};

	for (var i = 0; i < data.nodes.length; i++) {

		var string = data.nodes[i]['Location Coordinates'];

		if (string == undefined) {
			continue;
		}

		string = string.trim().substring(0, string.length - 1);

		var latitude = getLatitude(string);
		var longitude = getLongitude(string);

		if (latitude == "" || longitude == "") {
			continue;
		}

		gJSON.features.push( {
			'type': 'Feature',
			'geometry': {
				'type': 'Point',
				'coordinates': [longitude, latitude]
			}, 
			'properties': {
				'row id': data.nodes[i]['Row ID'],
		        'tweet id': data.nodes[i]['Tweet ID'],
		        'username': data.nodes[i]['Username'],
		        'tweet': data.nodes[i]['Tweet'],
		        'time': data.nodes[i]['Time'],
		        'tweet type': data.nodes[i]['Tweet Type'],
		        'retweeted by': data.nodes[i]['Retweeted by'],
		        'number of retweets': data.nodes[i]['Number of Retweets'],
		        'hashtags': data.nodes[i]['Hashtags'],
		        'mentions': data.nodes[i]['Mentions'],
		        'name': data.nodes[i]['Name'],
		        'location': data.nodes[i]['Location'],
		        'web': data.nodes[i]['Web'],
		        'bio': data.nodes[i]['Bio'],
		        'number of tweets': data.nodes[i]['Number of Tweets'],
		        'number of followers': data.nodes[i]['Number of Followers'],
		        'number following': data.nodes[i]['Number Following'],
		        'location coordinates': data.nodes[i]['Location Coordinates'],
		        'cluster': data.nodes[i]['Cluster']
			}
		});
	};

	return gJSON;
};

function getLatitude (string) {

	var latitude = "";

	var str = string.substring(3);

    if (str.indexOf("-") > -1) {
    	if (string.split("-").length == 2) {
    		latitude = string.split("-")[0];
    	} else if (string.split("-").length == 3) {
    		latitude = "-" + string.split("-")[1];
    	}
    } else if (str.indexOf("+") > -1) {
    	if (string.split("+").length == 2) {
    		latitude = string.split("+")[0];
    	} else if (string.split("+").length == 3) {
    		latitude = "+" + string.split("+")[1];
    	}
    }

	return latitude;
}

function getLongitude (string) {

	var longitude = "";

	var str = string.substring(3);

    if (str.indexOf("-") > -1) {
    	if (string.split("-").length == 2) {
    		longitude = "-" + string.split("-")[1];
    	} else if (string.split("-").length == 3) {
    		longitude = "-" + string.split("-")[2];
    	}
    } else if (str.indexOf("+") > -1) {
    	if (string.split("+").length == 2) {
    		longitude = "+" + string.split("+")[1];
    	} else if (string.split("+").length == 3) {
    		longitude = "+" + string.split("+")[2];
    	}
    }

	return longitude;
}