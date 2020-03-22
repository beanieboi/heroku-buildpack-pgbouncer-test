require 'sinatra'
require 'sequel'
require 'pg'
require 'json'

DB = Sequel.connect(ENV['DATABASE_URL'])

unless DB.table_exists?(:items)
  DB.create_table(:items) do
    primary_key :id
    String :name
    Float :price
  end

  items = DB[:items]
  items.insert(name: 'abc', price: rand * 100)
  items.insert(name: 'def', price: rand * 100)
  items.insert(name: 'ghi', price: rand * 100)
end

get '/items' do
  JSON.dump(DB[:items].all)
end

get '/dbsettings' do
  u = URI.parse(ENV['DATABASE_URL'])
  JSON.dump(
    { host: u.host}
  )
end
