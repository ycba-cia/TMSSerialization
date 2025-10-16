require 'sqlite3'
db1 = SQLite3::Database.new 'tms_serialization.db'

#reset database and autoincrement
db1. execute "delete from record_set_map"
db1.execute "UPDATE sqlite_sequence SET seq = 0 WHERE name = 'record_set_map'"

key = "5011"
setspec = "ycba:ps"

stmt = db1.prepare "INSERT INTO record_set_map (local_identifier, set_spec) VALUES (?,?)"
stmt.bind_param 1, key
stmt.bind_param 2, setspec
stmt.execute
stmt.close

#check output
db1.execute "SELECT * FROM record_set_map" do |row|
  puts row.join("\t")
end

db1.close
