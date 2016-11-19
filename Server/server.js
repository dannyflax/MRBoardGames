//setup
var PORT = 3901;

var express = require('express'),
UUID = require('node-uuid'),
verbose = false,
app = express();

var games = {abc: null, def: null}; //object keeps track of all games;
var players = {}; //keeps track of players.

//each game has following info:
//gameID (used as keys in games)
//playerID (used in players and values in games)
//socket id.
//gamestate


//Calls
 app.get( '/', function( req, res ){ 
        console.log("Request received");
		res.send("Hello bitch");
 });

//server start
var server = app.listen(PORT, function(){
	console.log('\t :: Express :: Listening on port ' + PORT );
})
var io = require('socket.io')(server);

io.on('connection', function(client){
	console.log('User connected');
	
	client.on('listGames', function(){
		var keys = [];
		for(var k in games) keys.push(k);
		client.emit('gameList', {keys: keys})
	});
	
	client.on('createGame', function(data){
		
	
	});
	
});