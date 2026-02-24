# Hubby - Study Planner App

Hubby is a modern mobile study planner application designed to help students manage their timetables, track subjects, use a Pomodoro timer, and monitor their progress effectively.

- **Frontend**: Flutter (cross-platform mobile app for Android & iOS)  
- **Backend**: Python (Django or FastAPI) — handles APIs, user authentication, study plan storage, notifications, etc.

## Features (Planned / In Progress)
- User registration & login  
- Create, edit, and delete study timetables & plans  
- Subject-wise progress tracking  
- Built-in Pomodoro timer with customizable work/break intervals  
- Reminders and push notifications  
- Dark / Light theme support  
- Offline support with cloud sync  

## Project Structure
study_planner/
├── frontend/               # Flutter mobile app (Hubby)
│   ├── lib/                # Dart source code
│   ├── assets/             # Images, fonts, etc.
│   ├── pubspec.yaml
│   └── ...
├── hubby_backend/          # Python backend
│   ├── manage.py           # (if using Django)
│   ├── requirements.txt
│   ├── .env                # Secrets (ignored in git)
│   ├── hubby/              # Django project folder (settings.py, urls.py, etc.) or FastAPI main.py
│   └── ...
├── .gitignore
└── README.md
text## Getting Started

### Prerequisites
- Flutter SDK (latest stable) → [flutter.dev](https://flutter.dev)
- Python 3.10 or higher
- Git
- Android Studio (for Android emulator) or Xcode (for iOS simulator)

### Step 1: Clone the Repository
```bash
git clone https://github.com/Sangampal11/study_planner.git
cd study_planner
Step 2: Frontend Setup (Flutter App)
Bashcd frontend

# Install dependencies
flutter pub get

# Run the app (on emulator or connected device)
flutter run
Flutter connection notes:

For Android emulator: Use http://10.0.2.2:8000 as backend base URL
For real device: Use your computer's local IP (e.g. http://192.168.1.100:8000)

Step 3: Backend Setup
Bashcd ../hubby_backend

# Create and activate virtual environment
python -m venv venv

# Windows:
venv\Scripts\activate

# Linux / macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create and configure .env file (example contents):
# SECRET_KEY=your-secret-key-here
# DEBUG=True
# ALLOWED_HOSTS=*
# DATABASE_URL=sqlite:///db.sqlite3   # or your database URL

# If using Django:
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser   # Optional: create admin user

# Start the server (accessible on local network)
python manage.py runserver 0.0.0.0:8000
Backend will be available at:

Locally: http://localhost:8000
From other devices: http://<your-pc-ip>:8000
