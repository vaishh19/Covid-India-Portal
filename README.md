COVID-19 India Portal

A secure RESTful API built using Node.js and Express to manage and retrieve COVID-19 statistics for Indian states and districts with JWT-based authentication.

🚀 Features

User authentication using JWT

Secure password handling with bcrypt

CRUD operations for district data

Retrieve state-wise COVID statistics

Protected routes using middleware

Data persistence using SQLite

🛠️ Tech Stack

Node.js

Express.js

SQLite

JWT (JSON Web Token)

bcrypt

JavaScript (ES6)

📂 Project Structure
.
├── app.js
├── covid19IndiaPortal.db
├── package.json
└── package-lock.json

🔐 Authentication

Login endpoint generates a JWT token

Token must be passed in the Authorization header as:

Authorization: Bearer <jwt_token>


All routes except /login/ are protected

📌 API Endpoints
Login

POST /login/
Authenticates user and returns JWT token.

States

GET /states/ → Get all states

GET /states/:stateId/ → Get specific state details

Districts

POST /districts/ → Add a new district

GET /districts/:districtId/ → Get district details

PUT /districts/:districtId/ → Update district details

DELETE /districts/:districtId/ → Delete a district

State Statistics

GET /states/:stateId/stats/
Returns total cases, cured, active, and deaths for a state

⚙️ Key Concepts Used

REST API design

Middleware for authentication

JWT token validation

Password hashing with bcrypt

SQL queries and joins

Async/Await

▶️ How to Run Locally
git clone <repository-url>
cd covid19-india-portal
npm install
node app.js


Server runs at:

http://localhost:3000/

📌 Future Enhancements

Role-based access control (Admin/User)

Input validation and error handling

Pagination for large datasets

Deployment to cloud platform
