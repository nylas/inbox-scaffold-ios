express = require("express")
http = require("http")
path = require("path")
global.fs = require("fs")

app = express()

# all environments
app.set "port", process.env.PORT or 3000
app.use express.favicon()
app.use express.json()
app.use express.urlencoded()
app.use express.multipart(defer: false)
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))
app.use express.errorHandler()  if "development" is app.get("env")

plugin_root = '../BigSur/plugins'
app.get  "/plugin-frame/:name", (req, res) ->
  res.write("<script type='text/javascript' src=\"/plugin/#{req.params.name}\"></script>")
  res.end()

app.get  "/plugin/:name", (req, res) ->
  fs.readFile "public/plugin_base.js", (err, base_data) ->
    path = "#{plugin_root}/#{req.params.name}.plugin/plugin.js"
    fs.readFile path, (err, data) ->
      if data
        res.write(base_data)
        res.write(data)
        res.end()
      else
        res.end(404)

server = http.createServer(app)
server.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
