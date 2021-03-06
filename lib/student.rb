require_relative "../config/environment.rb"
require 'pry'
class Student
 attr_accessor :name, :grade, :id

 ATTRIBUTES = {
  id: "INTEGER PRIMARY KEY AUTOINCREMENT", 
  name: "TEXT",
  grade: "TEXT"
 }

 def self.public_attributes
   ATTRIBUTES.keys.reject do |key|
     key == :id
   end
 end

 # def values
 #  self.class.public_attributes { |symbol| self.send(symbol) }


 def self.create_table
  sql = <<-SQL
  CREATE TABLE IF NOT EXISTS students (
  id "INTEGER PRIMARY KEY AUTOINCREMENT",
  name "TEXT",
  grade "TEXT")
  SQL

  DB[:conn].execute(sql)
 end

 def self.drop_table
  sql = <<-SQL
  DROP TABLE students
  SQL

  DB[:conn].execute(sql)
 end

 def initialize(name, grade, id = nil)
  @id = id
  @name = name
  @grade = grade

  
 end

 def self.create(name, grade)
  student = self.new(name, grade)

  student.save

 end

 def self.new_from_db(row)
  student = self.new(@id = nil, @name, @grade)
  student.id = row[0]
  student.name = row[1]
  student.grade = row[2]
  
  student
 end

 def self.find_by_name(name)

   sql = <<-SQL
     SELECT *
     FROM students
     WHERE name = ?
     LIMIT 1
   SQL

   DB[:conn].execute(sql,name).map { |row| self.new_from_db(row) }.first
 end

 def persisted?
  !!@id
 end

 def insert
   sql = <<-SQL
    INSERT INTO students (name, grade) VALUES (?, ?)
   SQL
   DB[:conn].execute(sql, self.name, self.grade)
   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
 end

 def update
   sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?;
   SQL
   DB[:conn].execute(sql, self.name, self.grade, self.id)
 end
 
 def save
  if persisted?
   update
   self
  else
   insert
   self
  end
 end


end
