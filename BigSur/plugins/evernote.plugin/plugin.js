
plugin.isAvailableForThread = function(thread) {
	return true;
}

plugin.actionTitleForThread = function(thread) {
	return "Send to Evernote";
}

plugin.performForThread = function(thread) {
    app.alert("HIi");
}