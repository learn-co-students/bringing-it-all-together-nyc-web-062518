require 'sqlite3'
require_relative '../lib/dog.rb'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}
