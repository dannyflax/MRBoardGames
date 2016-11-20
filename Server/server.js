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
//playerID (used as key players and values in games)
//mutexLock
//gamestate

//locks
var locks = require('locks');
var gamesLock = locks.createReadWriteLock(), playersLock = locks.createReadWriteLock();

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
	
	client.on('createPlayer', function(data){
		playersLock.writeLock(function(data){
			var playerId = "player" + Object.keys(players).length;
			var socketId = client.id;
			players[playerId] = socketId;
			playersLock.unlock();
			client.emit('playerCreated', {"playerId": playerId});
		});
	});
	
	client.on('listGames', function(){
		var keys = [];
		for(var k in games) keys.push(k);
		client.emit('gameList', {keys: keys})
	});
	
	client.on('createGame', function(data){
		gamesLock.writeLock(function(){;
			var game = {state: null, players: [], lock: locks.createMutex()};
			var id = "game" + Object.keys(games).length;
			game.players.push(data.playerId);
			games[id] =  game;
			gamesLock.unlock();
			client.emit('gameCreated', {gameId: id});
		});
	});
	
	client.on('joinGame', function(data){
		if(games[data.gameID] && players[data.playerID]){
			var game = games[data.gameID];
			game.lock.lock(function(){
				game.players.push(data.playerID);
				client.emit('gameJoined', {success: true});
				game.lock.unlock();
		});
		}else{
			client.emit('gameJoined', {success: false});
		}
	});
	
	client.on('leaveGame', function(data){
		if(games[data.gameID] && players[data.playerID]){
			var game = games[data.gameID];
			game.lock.lock(function(){
				game.players = game.players.filter(function( obj ) {
					return obj !== data.playerID;
				});
				client.emit('gameLeft', {success: true});
				game.lock.unlock();
		});
		}else{
			client.emit('gameLeft', {success: false});
		}
	});
	
	
});