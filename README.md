# README

Application stack:

- Postgres for main data store
- Redis to manage the worker that updates the exclusions list 

- Rails for web interface and exclusions worker

Development is done via Docker and deployments via Heroku.

## Behaviour / limitations / assumptions made

- Uploading the CSV data file to a folder is not feasible. This functionality is instead achieved via a form upload on the web interface.
  - The data file sample is delimited by pipes, not commas. Therefore the application only accepts pipe-delimited 'csv' files.
  - The data file must contain a header row.
  - Uploading further CSV files does not delete any previous entries. Any existing records with the same website and date will have its visit count replaced. 

- The application ignores any leading 'www.' in the domain name when comparing websites from the data set to the exclusions list.
  - The website name is inserted in the original format into the database

- A worker is scheduled to run every 5 minutes to fetch the list of exclusions.
  - The worker updates the exclusion dates on existing records
  - The exclusions API endpoint does not have different development / staging / production endpoints so support for this is not provided.

- Additional user accounts have to be added manually via a Rails console.
  - See `db/seeds.rb` for the command to do so.

## Local development:
Pre-requisites: 
- [Docker](https://www.docker.com/community-edition)
- Git 

Clone the repo.

Copy `app.env.sample` to `app.env`.

Create the services with
```
docker-compose create
```

Set up the database with the following:
```
docker-compose run app rake db:create db:migrate db:seed
```

Sidekiq is not configured to run locally.
Manually update the exclusions list via:
```
docker-compose run app rails runner "ExclusionsWorker.new.perform"
```

Start the services with:
```
docker-compose up
```

The web interface should be available via `http://localhost:3000`

## Deployment
Live site: https://website-report.herokuapp.com/

The application is deployed to Heroku on free instances - it will take longer to initialise after a period of inactivity.

### Steps
Pre-requisites:
- Heroku app with the Postgres and Redis add-ons enabled

Set all required environment variables manually:
```
heroku config:set RAILS_ENV=production
heroku config:set RAILS_SERVE_STATIC_FILES=true
heroku config:set SECRET_KEY_BASE=(secret)*
heroku config:set USER_EMAIL=user@example.com 
heroku config:set USER_PASSWORD=(password)
```
\* Generate a new secret key via `docker-compose run app rake secret`


Deploy with
```
heroku container:push --recursive
```

Run migrations manually and create the user:
```
heroku run rake db:migrate
heroku run rake db:seed
```

## Improvements

- Support to view top site report over a date range
- Allow for more filtering of the data set; top N websites (not just 5), sort by visits ascending.
- Export reports as csv / pdf
- `<input type="date">` has [poor support in Firefox](https://caniuse.com/#feat=input-datetime). This could be improved with a fallback to dropdowns
- A complete user registration / confirmation workflow
- User roles could be implemented to allow users to view reports without the ability to upload new data. 
