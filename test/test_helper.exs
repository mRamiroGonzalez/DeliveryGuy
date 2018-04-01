ExUnit.start()

# > json-server --watch test/db.json
#
#filename = "test/db.json"
#defaultDatabase = "
#  {
#    \"events\": [
#      {
#        \"type\": \"FIRST_EVENT\",
#        \"startDate\": \"2030-01-01T01:00Z[UTC]\",
#        \"endDate\": \"2030-01-01T03:00Z[UTC]\",
#        \"id\": 1
#      }
#    ]
#  }"
#File.write(filename, defaultDatabase)