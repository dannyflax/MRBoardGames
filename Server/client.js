var socket = require('socket.io-client')('http://127.0.0.1:3901');

socket.on('connect', function(){});
socket.on('gameList', function(data){
	console.log(JSON.stringify(data));
});
socket.emit('listGames', {});