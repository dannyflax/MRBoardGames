var socket = require('socket.io-client')('http://127.0.0.1:3901');

socket.on('connect', function(){});
socket.on('gameList', function(data){
	console.log(JSON.stringify(data));
});
socket.emit('listGames', {});
socket.emit('createGame', {state: {abc: 'def'}});

socket.on('gameCreated', function(data){
	console.log("Game created: \n");
	console.log(JSON.stringify(data));
	socket.emit('joinGame', {gameID: 'game0'});
});

socket.on('gameUpdated', function(data){
	console.log("GAME UPDATED");
	console.log(data);
});

socket.on('gameJoined', function(data){
		console.log("JOINED GAME");
		console.log(JSON.stringify(data));
		socket.emit('leaveGame', {gameID: "game2", playerID: "player2"})
});


socket.on('gameLeft', function(data){
		console.log("LEFT GAME");
		console.log(JSON.stringify(data));
});

socket.on('gamestSteUpdated', function(data){
	console.log("UPDATED GAME");
		console.log(JSON.stringify(data));
});

socket.emit('updateGame', {gameID: "game0", playerID: "player0", state: {abc: "lmnopqrst"}});