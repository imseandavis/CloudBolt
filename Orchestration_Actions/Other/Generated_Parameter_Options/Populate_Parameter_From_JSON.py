#This will allow you to populate a parameter with a tuple list from a api that returns JSON data.

import requests
import json

def get_options_list(field, environment=None, group=None, **kwargs):
    
	#Query The API
	url = "https://some_url_that_returns_json.com"
	request_json = requests.get(url).json()

	#If The Query Returned No Results, Return Nothing And Send A Notification Email That It's Broken.
	if request_json == None:
		#Add Send Email Here
    return [None]

	#Parse The JSON Values Into A Tuple
	request_values = [(r['app_uid'], r['workgroup'] + ' - ' + r['app_name']) for r in request_json]
	return request_values
