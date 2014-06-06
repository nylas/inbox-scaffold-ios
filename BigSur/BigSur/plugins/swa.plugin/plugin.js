function isAvailableForMessage(message) {
    return (message.from[0].email.indexOf('luv.southwest.com') != -1);
}

function initialHTMLForMessage(message) {
    return "<div style='background-color:#fcfcfc; padding:15px; border:1px solid #eee; color:#333;'><img src='./swa_flight.png' style='width:40px; height:40px; float:right; padding-left:15px;'>Loading flight status...</div>";
}

function finalHTMLForMessage(message, callback) {
    $ = cheerio.load(message.body);
    
    var passengerName = $('table tbody tr td table tbody tr td table tbody tr td tbody tr td div').eq(4).text().trim()
    var flightNumber = $('table tbody tr td table tbody tr td table tbody tr td tbody tr td div').eq(10).text().trim()
    var dateString = $('table tbody tr td table tbody tr td table tbody tr td tbody tr td div').eq(9).text().trim()
    var dateYear = (new Date).getFullYear();
    var date = new Date(Date.parse(dateString + " " + dateYear))
    var dateMonth = date.getMonth() + 1;
    var dateDay = date.getDate();
    
    
    var url = "https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/SWA/"+flightNumber+"/dep/"+dateYear+"/"+dateMonth+"/"+dateDay+"?appId=b16bee5a&appKey=8027de581e3af06afab756d41b50c935&utc=false";
    
    app.getJSONWithCallback(url, function(json, error) {
        var result = ""
        if (json['error']) {
            result = json.error.errorMessage;
        } else {
            var flight = json.flightStatuses[0];
            var departTerminal = flight.airportResources.departureTerminal;
            var departAirport = flight.departureAirportFsCode;
            var publishedDeparture = flight.operationalTimes.publishedDeparture.dateLocal;
            var scheduledDeparture = flight.operationalTimes.scheduledGateDeparture.dateLocal;
            result = "Departing from "+departAirport+" Terminal "+departTerminal+" at "+scheduledDeparture;
        
        }
        app.log(JSON.stringify(json));
        var html = "<div style='background-color:#fcfcfc; padding:15px; border:1px solid #eee; color:#333;'><img src='./swa_flight.png' style='width:40px; height:40px; float:right; padding-left:15px;'>"+result+"</div>";
        callback(html);
    });
}