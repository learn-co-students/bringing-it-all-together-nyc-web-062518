class Dog
  attr_accessor :id, :name, :breed
  def initialize(arg={})
    @id = arg[:id]
    @name = arg[:name]
    @breed = arg[:breed]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    hash = Hash.new 0
    hash[:id] = row[0]
    hash[:name] = row[1]
    hash[:breed] = row[2]
    self.new(hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    dog_info = DB[:conn].execute(sql, name)[0]

    self.new_from_db(dog_info)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
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

  def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL

    dog_info = DB[:conn].execute(sql, id)[0]
    self.new_from_db(dog_info)
  end

  def self.find_or_create_by(args)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, args[:name], args[:breed])
    if !dog.empty?
      dog_info = dog[0]
      self.new_from_db(dog_info)
    else
      self.create(args)
    end
  end
end
