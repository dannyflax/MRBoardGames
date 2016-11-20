var socket = require('socket.io-client')('http://127.0.0.1:3901');

socket.on('connect', function(){});
socket.on('gameList', function(data){
	console.log(JSON.stringify(data));
});
socket.emit('listGames', {});
socket.emit('createGame', {playerID: "Viral Patel"});
socket.on('gameCreated', function(data){
	console.log("Game created: \n");
	console.log(JSON.stringify(data));
});
socket.emit('createPlayer', {});
socket.on('playerCreated', function(data){
	console.log("player created: \n");
	console.log(JSON.stringify(data));
})

