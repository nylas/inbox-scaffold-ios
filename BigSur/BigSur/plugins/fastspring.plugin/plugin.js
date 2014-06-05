function isAvailableForThread(thread) {
    return thread.subject.substring(0, 6) == 'Order:';
}

function actionTitleForThread(thread) {
	return "Open in FastSpring...";
}

function performForThread(thread) {
	// find the order id
    var messages = thread.messages();
    var order_id = thread.subject.substring(7);
    order_id = order_id.substring(0, order_id.indexOf(' - '));
    app.openURL("https://springboard.fastspring.com/order/search.xml?query="+order_id)
}