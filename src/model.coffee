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
  fs.exists __dirname+'/model', (model_exists) ->
    unless model_exists
      fs.mkdir __dirname+'/model'
    file = fs.readFileSync './init_model.ejs', 'utf8'
    data = ejs.render(file)
    fs.writeFile './model/models.go', data

query = (sql, callback) ->
  connection.query sql, (err, rows, fields) ->
    if err
      console.log err
    else
      callback(rows, fields)

listTables = () ->
  query 'show tables', (rows, fields) ->
    tables = _(rows).map( (r) -> r['Tables_in_go_generator'])
    _(tables).forEach( (t) -> writeTableStruct t)

class Attribute
  constructor: (@name, @type, @tag) ->

class Table
  constructor: (@name) ->
    @trace = false
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

writeTableStruct = (tableName) ->

  query "describe go_generator.#{tableName}", (rows, fields) ->
    table = new Table(S(tableName).classify().capitalize().value())

    _(rows).forEach (r) ->
      attribute = S(r.Field).classify().capitalize().value()
      type = r.Type
      if attribute != "Id"
        if traceTable(attribute)
          table.trace = true
        else
          modelType = modifyFieldType(type)  # convert sqlType to modelType
          jsonAttribute = attribute[0].toLowerCase() + attribute.substr(1)  # lowercase the attribute for json
          table.addAttribtue(attribute, modelType, jsonAttribute)

    file = fs.readFileSync './model_template.ejs', 'utf8'
    data = ejs.render(file, table)

    fs.appendFile './model/models.go', data

createHierarcy()

listTables()
