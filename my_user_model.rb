require 'sqlite3'

$created_table = false
class User
  DB_FILENAME = 'db.sql'
  attr_accessor :id, :firstname, :lastname, :age, :password, :email


  def self.create_table(dd)
    dd.execute <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstname TEXT,
        lastname TEXT,
        age INTEGER,
        password TEXT,
        email TEXT
      );
    SQL
  end
  def initialize(id, firstname, lastname, age, password, email)
    @id = id
    @firstname = firstname
    @lastname = lastname
    @age = age
    @password = password
    @email = email
  end

  def to_h
    {
        id: @id,
        firstname: @firstname,
        lastname: @lastname,
        age: @age,
        password: @password,
        email: @email
    }
    end
  def self.create(user_info)
    init_dbs = SQLite3::Database.new(DB_FILENAME)
    create_table(init_dbs)
    init_dbs.execute("INSERT INTO users (firstname, lastname, age, password, email) VALUES (?, ?, ?, ?, ?)", user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:password], user_info[:email])
    
    id = init_dbs.last_insert_row_id
    init_dbs.close()
    
    find(id)
  end

  def self.find(user_id)
    init_dbs = SQLite3::Database.new(DB_FILENAME)
    init_dbs.results_as_hash = true 
    create_table(init_dbs)
    row = init_dbs.get_first_row("SELECT * FROM users WHERE id = ?", user_id)
    init_dbs.close()
    User.new(row["id"], row["firstname"], row["lastname"], row["age"], row["password"], row["email"])
  end

  def self.all
    init_dbs = SQLite3::Database.new(DB_FILENAME)
    init_dbs.results_as_hash = true 
    users = init_dbs.execute("SELECT * FROM users").map do |row|
      User.new(row["id"], row["firstname"], row["lastname"], row["age"], row["password"], row["email"])
    end
    init_dbs.close()
    users
  end

  def self.findCredential(user_mail, user_password)
    init_dbs = SQLite3::Database.new(DB_FILENAME)
    init_dbs.results_as_hash = true 
    row = init_dbs.get_first_row("SELECT id FROM users WHERE email = ? AND password = ?", user_mail, user_password)
    return nil unless row
    init_dbs.close()
    row["id"]
  end

  def self.update(user_id, attribute, value)
    init_dbs = SQLite3::Database.new(DB_FILENAME)
    init_dbs.execute("UPDATE users SET #{attribute} = ? WHERE id = ?", value, user_id)
    init_dbs.close()
  end

  def self.destroy(user_id)
    init_dbs = SQLite3::Database.new(DB_FILENAME)
    init_dbs.results_as_hash = true 
    init_dbs.execute("DELETE FROM users WHERE id = ?", user_id)
    init_dbs.close()
  end  
  
end