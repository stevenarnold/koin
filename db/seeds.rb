# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:

#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
admin = Users.new(username: 'admin',
                  passwd: 'gerBIL77&3++',
                  p_search_all: true,
                  p_admin: true)
admin.save
guest = Users.new(username: 'guest',
                  passwd: '',
                  p_search_all: false,
                  p_admin: false)
guest.save
thoth = Users.new(username: 'thoth',
                  passwd: 'foobar',
                  p_search_all: true,
                  p_admin: true)
thoth.save
