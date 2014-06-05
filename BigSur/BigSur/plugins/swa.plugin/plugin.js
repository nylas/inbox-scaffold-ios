function isAvailableForMessage(message) {
    return (message.subject.indexOf('Maniphest') != -1);
}

function initialHTMLForMessage(message) {
    return "<div style='background-color:#fcfcfc; padding:15px; border:1px solid #eee; color:#333;'><img src='./swa_flight.png' style='width:40px; height:40px; float:right; padding-left:15px;'>Loading flight status...</div>";
}

function finalHTMLForMessage(message) {
    var json = app.getJSON("https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/SWA/2536/dep/2014/6/7?appId=b16bee5a&appKey=8027de581e3af06afab756d41b50c935&utc=false");
    return "<div style='background-color:#fcfcfc; padding:15px; border:1px solid #eee; color:#333;'><img src='./swa_flight.png' style='width:40px; height:40px; float:right; padding-left:15px;'>"+json.error.errorMessage+"</div>";
}