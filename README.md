Schedulizer Project Documentation
Overview
Schedulizer is a cross-platform scheduling tool for team availability tracking and shift coordination.
•	Frontend: Flutter
•	Backend: Java Spring Boot
•	Database: PostgreSQL (procedural SQL, JSONB, triggers)
•	Authentication: Custom implementation with role support
Frontend (Flutter)
Login & Registration (main.dart)
•	Email/password-based login and registration.
•	Authenticated users are navigated to the main dashboard.
 
Index Dashboard (index_page.dart)
•	Links to:
o	📅 Urnik (Schedule)
o	👥 Člani (Team members)
o	⚙️ O meni (User info)
o	🛡️ Admin Panel (admin only)
Schedule Page (urnik.dart)
•	Weekly shift matrix with availability options:
o	✅ can
o	❌ cant
o	🔁 swap (requires reason)
•	Sends JSON data to backend.
•	Admins have read-only access to availability per user.
Admin Panel (admin_panel.dart)
•	User dropdown to select team member.
•	View their availability in a calendar.
•	Navigate by week.
Team Page (clani.dart)
•	Displays hardcoded list of team members.
About Me Page (o_meni.dart)
•	Displays logged-in user's email and derived username.

 
Backend (Java Spring Boot)
Key Endpoints (UserController.java)
Endpoint	Method	Description
/api/register	POST	Register user (calls register_user(...))
/api/login	POST	Login logic (calls login_user(...))
/api/availability/save	POST	Save user’s weekly availability (save_user_availability(...))
/api/availability?email&weekStart	GET	Get a user’s weekly availability
/api/users/all	GET	Returns all user emails
Models
•	User.java – Entity with id, username, email, passwordHash, role
•	AvailabilityRequest.java – JSON payload for availability
Repository
•	UserRepository.java – Queries by email, username
Security
•	SecurityConfig.java – Disables CSRF, permits public API access
PostgreSQL Procedures & Triggers
Stored Procedures
•	register_user(username, email, password_hash) – inserts new user
•	login_user(email, password) – verifies credentials & triggers login event
•	save_user_availability(user_id, week_start, jsonb) – upserts availability data
•	get_user_availability(user_id, week_start) – returns availability map
 
Triggers
Trigger Event	Table/Action	Triggered Function	Description
After Registration	On register_user	log_event('new user registered')	Logs user ID and message
After Login	On login_user	log_event('user logged in')	Logs login success
After Schedule Save	On save_user_availability	log_event('new schedule inserted')	Logs when user saves their schedule
After Password Reset	On reset_password_request(email)	log_event('password reset requested')	Logs email and request

 
Features Summary
Feature	Status	Notes
Auth (Register/Login)	✅	With validation & hashing
Availability Matrix	✅	Includes swap reasons
Admin View	✅	Read-only, per-user
Stored Procedures	✅	Encapsulate core logic
Triggered Audit Logs	✅	Registration, login, schedule save, reset
Frontend UI	✅	Responsive & role-aware

 
DATABASE
 
 
 

