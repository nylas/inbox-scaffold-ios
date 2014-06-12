var app = {};
app.alert = function(msg) {
	window.parent.postMessage('{"command":"alert", "param":"'+msg+'"}', '*');
}

app.log = function(msg) {
	window.parent.postMessage('{"command":"log", "param":"'+msg+'"}', '*');
}

app.openURL = function(url) {
	window.parent.postMessage('{"command":"openURL", "param":"'+url+'"}', '*');
}

window.addEventListener('message', function (e) {
	var result = '';
	try {
		result = eval(e.data);
	} catch (e) {
		result = 'eval() threw an exception.';
	}
	var mainWindow = e.source;
	mainWindow.postMessage(result, event.origin);
});

var plugin = {};
window.plugin = plugin;

// END OF PLUGIN_BASE //

