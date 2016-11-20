var socket = require('socket.io-client')('http://127.0.0.1:3901');

socket.on('connect', function(){});
socket.on('gameList', function(data){
	console.log(JSON.stringify(data));
});

socket.on('gameCreated', function(data){
	console.log("Game created: \n");
	console.log(JSON.stringify(data));
});

socket.on('gameUpdated', function(data){
	console.log("GAME UPDATED");
	console.log(data);
});

socket.on('gameJoined', function(data){
		console.log("JOINED GAME");
		console.log(JSON.stringify(data));
});


socket.on('gameLeft', function(data){
		console.log("LEFT GAME");
		console.log(JSON.stringify(data));
});

socket.on('gameStateUpdated', function(data){
	console.log("UPDATED GAME");
	console.log(JSON.stringify(data));
});

socket.on('gameState', function(data){
	console.log("GET GAME");
	console.log(JSON.stringify(data));
});

var stdin = process.openStdin();

stdin.addListener("data", function(d) {
		var input = d.toString().split(' ');
		var event = input[0];
		var rest = d.toString().substring(event.length + 1);
		socket.emit(event, JSON.parse(rest.trim()));
});