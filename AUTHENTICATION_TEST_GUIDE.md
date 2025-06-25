// Test file to verify authentication with real backend
// Instructions:
// 1. Run the app on your device/emulator
// 2. Try to register with test data:
//    Name: Test User
//    Email: testuser@gmail.com  
//    Password: changeme123
// 3. Try to login with the provided credentials:
//    Email: admin@gmail.com
//    Password: changeme123

// Expected behavior:
// - Registration should create a new user and automatically log you in
// - Login should authenticate existing users
// - Both should save the token and user data locally
// - App should remember login state between sessions
// - Logout should clear all saved data

// API Endpoints being used:
// - Register: POST https://cuent-ai-core-sw1-656847318304.us-central1.run.app/api/v1/users/sign-up
// - Login: POST https://cuent-ai-core-sw1-656847318304.us-central1.run.app/api/v1/users/sign-in

// JSON format:
// Register: {"name": "user name", "email": "user@gmail.com", "password": "changeme123"}
// Login: {"email": "admin@gmail.com", "password": "changeme123"}

// Response should include:
// - access_token or token field
// - user object with id, name, email, created_at

// If you see any errors, check:
// 1. Internet connection
// 2. Backend API is accessible
// 3. Correct credentials are being used
// 4. Backend is returning expected JSON format
