# User Guru

Customer service and issue tracking application to teach myself Ruby on Rails.

# Development Setup

1. Clone Repository

2. Setup Ruby Environment

    - This project uses ruby 2.2.3p173
    - rbenv can be used for ruby environment management https://github.com/rbenv/rbenv

3. Install bundler and bundle install (from command line in project)

    - gem install bundler
    - bundle install

4. Database creation

    1. Install MySQL
        - This project uses mysql 5.7
        - OSX use brew (https://brew.sh) to install mysql
    2. Create database.yml file (from command line in project)
        - cp config/database.yml.sample config/database.yml
        - Update root password to your root password
    3. Run database rake commands (from command line in project)
        - rake db:create
        - rake db:migrate
        - rake db:seed

5. Run tests (from command line in project)

    - rake test

6. Run rails server (from command line in project)

    - rails server

7. Log in using admin user

    - Navigate to http://localhost:3000/login
    - Login as admin
        - email: admin@user.guru
        - password: password
