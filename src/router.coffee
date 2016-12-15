mysql = require 'mysql'
fs = require "fs"
_ = require 'underscore'
S = require 'underscore.string'
ejs = require 'ejs'

connection =
  mysql.createConnection
    host: 'localhost'
    user: 'go_generator'
    password: 'go_generator'
    database: 'go_generator'

connection.connect()

createHierarcy = ->
  fs.exists __dirname+'/router', (router_exists) ->
    unless router_exists
      fs.mkdir __dirname+'/router', ->
    else

query = (sql, callback) ->
  connection.query sql, (err, rows, fields) ->
    if err
      console.log err
    else
      callback(rows, fields)

listTables = ->
  query 'show tables', (rows, fields) ->
    tables = _(rows).map( (r) -> r['Tables_in_humhub'])
    capitalizeTables = []
    _(tables).forEach( (t) ->
      writeRouterMethod t
      capitalizeTables.push(S(t).classify().capitalize().value())
    )
    fs.writeFileSync './router/install_router.go', ''
    file = fs.readFileSync './install_router.ejs', 'utf8'
    data = ejs.render(file, {t: capitalizeTables}, null)
    fs.appendFile './router/install_router.go', data

class Attribute
  constructor: (@name, @type, @tag) ->

class Table
  constructor: (@name) ->
    @capitalizeName = S(@name).classify().capitalize().value()
    @trace = false
    @guid = false
    @attributes = []
  addAttribtue: (name, type, tag) ->
    newAttribute = new Attribute(name, type, tag)
    @attributes.push(newAttribute)

modifyFieldType = (type) ->
    if type.indexOf("int") != -1  # type contains (int, tinyint)
      return "uint"
    else if type.indexOf("time") != -1  #type contains (date_time)
      return "time.Time"
    else  #type contains (text, varchar)
      return "string"

traceTable = (attribute) ->
  switch attribute
    when "CreatedAt", "CreatedBy", "UpdatedAt", "UpdatedBy"
      return true
    else
      return false

writeRouterMethod = (tableName) ->
  query "describe humhub.#{tableName}", (rows, fields) ->
    table = new Table(tableName)

    _(rows).forEach (r) ->
      attribute = S(r.Field).classify().capitalize().value()
      type = r.Type
      if attribute != "Id"
        if traceTable(attribute)
          table.trace = true
        else
          modelType = modifyFieldType(type)  # convert sqlType to modelType
          if (attribute == "Guid")
            table.guid = true
          jsonAttribute = attribute[0].toLowerCase() + attribute.substr(1)  # lowercase the attribute for json
          table.addAttribtue(attribute, modelType, jsonAttribute)

    fs.writeFileSync './router/'+table.name+'.go', ''
    file = fs.readFileSync './router_template.ejs', 'utf8'
    data = ejs.render(file, table, null)
    fs.appendFile './router/'+table.name+'.go', data


createHierarcy()
listTables()
