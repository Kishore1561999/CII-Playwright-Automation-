# README

This README would normally document whatever steps are necessary to get the
application up and running.

* create a new file under config folder named database.yml and copy paste the content from database.sample.yml

* Install nvm and use version 14

* Install yarn and run command: yarn install

* rake assets:precompile

* rake db:create

* rake db:migrate

* rake db:seed

* create a new .env and copy paste the content from .env.example and update the needed data.

* bundle install

* bundle exec rails questionaire:load_questionaire_data

* rails s -p 3002

To Import User Data, fill the Users data in Users.xlsx file located in lib folder and run the below command:

* bundle exec rails users:load_users_data