require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(args)
    new_dog = self.new(args)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs where id = ?"
    dog_info = DB[:conn].execute(sql, id)[0]
    dog = self.new_from_db(dog_info)
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * from dogs WHERE name = ? LIMIT 1"
    dog_info = DB[:conn].execute(sql, name)[0]
    dog = self.new_from_db(dog_info)
    dog
  end

  def self.find_or_create_by(args)
    sql = "SELECT * FROM dogs WHERE name = ? and breed = ?"
    dog = DB[:conn].execute(sql, args[:name], args[:breed])
    if !dog.empty?
      dog_info = dog[0]
      dog = self.new_from_db(dog_info)
    else
      dog = self.create(args)
      dog
    end
  end


  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    dog = self.new(name: name, breed: breed, id: id)
  end



end
