require 'sinatra'
require 'sequel'
require 'pg'

DB = Sequel.connect(ENV['DATABASE_URL'])

DB.create_table :items do
  primary_key :id
  String :name
  Float :price
end

items = DB[:items]
items.insert(name: 'abc', price: rand * 100)
items.insert(name: 'def', price: rand * 100)
items.insert(name: 'ghi', price: rand * 100)

get '/' do
  "Hello World!"
end
