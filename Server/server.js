//setup
var PORT = 3901;

var express = require('express'),
UUID = require('node-uuid'),
verbose = false,
app = express();

var games = {}; //object keeps track of all games;
var players = {}; //keeps track of players.

//each game has following info:
//gameID (used as keys in games)
//playerID (used as key players and values in games)
//mutexLock
//gamestate


//gamestate
//data includes serialized version of all objects + 

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
	console.log('socket id : ' + client.id);
	
	client.on('listGames', function(){
		var keys = {};
		for(var k in games){
			keys[k] = games[k].players.length;
			
		}
		client.emit('gameList', keys);
	});
	
	client.on('createGame', function(data){
		
		console.log("CREATE GAME\n" + JSON.stringify(data));
		
		playersLock.writeLock(function(){
			var playerId = "player" + Object.keys(players).length;
			while((playerId in players)){
					playerId = "player" + Object.keys(players).length + Math.floor((Math.random() * 10) + 1);
			}
			
			var socketId = client.id;
			players[playerId] = socketId;
			playersLock.unlock();
			gamesLock.writeLock(function(){
				var game = {state: data.state, players: [playerId], lock: locks.createMutex()};
				var id = "game" + Object.keys(games).length;
				
				while(id in games){
					id = "game" + Object.keys(games).length + Math.floor((Math.random() * 10) + 1);
				}
			
				games[id] =  game;
				gamesLock.unlock();
				client.emit('gameCreated', {gameID: id, playerID: playerId});
			});
		});
		
	});
	
	client.on('joinGame', function(data){
		
		console.log("JOIN GAME\n" + JSON.stringify(data));
		console.log(data.gameID);
		if(games[data.gameID]){
			
			playersLock.writeLock(function(){
				var playerId = "player" + Object.keys(players).length;
				while((playerId in players)){
					playerId = "player" + Object.keys(players).length + Math.floor((Math.random() * 10) + 1);
				}
				var socketId = client.id;
				players[playerId] = socketId;
				playersLock.unlock();
			
				var game = games[data.gameID];
				game.lock.lock(function(){
					game.players.push(playerId);
					client.emit('gameJoined', {success: true, playerID: playerId});
					game.lock.unlock();
				});
			});
		}else{
			client.emit('gameJoined', {success: false});
		}
	});
	
	client.on('leaveGame', function(data){
		
		console.log("LEAVE GAME\n" + JSON.stringify(data));
		
		if(games[data.gameID] && players[data.playerID]){
			var game = games[data.gameID];
			game.lock.lock(function(){
				game.players = game.players.filter(function( obj ) {
					return obj !== data.playerID;
				});
				delete players[data.playerID];
				if(game.players.length == 0){
					delete games.data.gameID;
				}
				client.emit('gameLeft', {success: true});
				console.log("removing player " + data.playerID);
				console.log(players);
				game.lock.unlock();
			});
		}else{
			client.emit('gameLeft', {success: false});
		}
	});
	
	
	client.on('updateGameState', function(data){
		console.log("UPDATE GAME STATE\n" + JSON.stringify(data));
		
		if(games[data.gameID] && players[data.playerID] && games[data.gameID].players.indexOf(data.playerID) >= 0){
			var game = games[data.gameID];
			game.lock.lock(function(){
				game.state = data.state;
				game.lock.unlock();
				var playersInGame = game.players;
				console.log(playersInGame);
				for(var i = 0; i < playersInGame.length; i++){
					var player = playersInGame[i];
					console.log(JSON.stringify(players) + "\n" + player);
					//console.log(io.sockets.connected[players[player]]);
					io.sockets.connected[players[player]].emit('gameStateUpdated', {player: data.playerID, state: data.state});
				}
			});
		}else{
			client.emit('gameStateUpdated', {gameState: "Fuck you for trying to update state of game that you are not in"});
		}
	});
	
	client.on('getGameState', function(data){
		console.log("GET GAME STATE \n" + JSON.stringify(data));
		client.emit('gameState', {state: games[data.gameID].state});
	});
});