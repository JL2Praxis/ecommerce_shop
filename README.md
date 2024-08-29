
## Setting Up .env File
To configure environment variables for this project, follow these steps:

- Copy .env.example: Duplicate the .env.example file and rename it to .env. You can do this using the following command in your terminal:
  ```bash
  cp .env.example .env
  ```

- Edit .env File: Update the variables in .env to reflect your development environment. Ensure you do not include sensitive information in the .env file that should not be version-controlled.

## Configuring Database
After setting up your .env file with the necessary environment variables for your database configuration, follow these steps to initialize the database:

- Run Database Setup Command: In your terminal, execute the following command to create the development database specified in your .env file:

  ```bash
  rails db:create
  ```
  This command will use the database credentials provided in your .env file to create the database specified for the development environment.

- Verify Database Configuration: After running rails db:create, verify that the database has been successfully created by checking your database management tool or running:

  ```bash
  rails db:migrate
  ```

  This command ensures that any pending migrations are applied to your newly created database.

- Run Database Seeds: To populate your database with initial data, run the following command:

  ```bash
  rails db:seed
  ```

  This command will load the seed data defined in the db/seeds.rb file, which can include default records such as admin users, roles, or other necessary data for your application.

By following these steps, you ensure that your Rails application is properly configured to use the database specified in your .env file for development, and that initial data is seeded correctly.

## Using GraphiQL
GraphiQL is a graphical interactive in-browser GraphQL IDE. To access it, follow these steps:

- Start Rails Server: Ensure your Rails server is running by executing:
  ```bash
  rails server
  ```

- Open GraphiQL: In your web browser, navigate to:
  ```bash
  http://localhost:3000/graphiql
  ```
  This will open the GraphiQL interface where you can run GraphQL queries and interact with your API.


## Mail Configuration
  To set up email sending:

  - Generate an App Password:
    Visit Google App Passwords and create a new app password.
    (https://myaccount.google.com/apppasswords)
    
  - Update the .env File:
    ```bash
    GMAIL_USERNAME=your-email@gmail.com
    GMAIL_PASSWORD=your-app-password
    ```
    Replace your-email@gmail.com with your Gmail address and your-app-password with the generated app password.