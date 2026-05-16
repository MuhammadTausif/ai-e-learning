# AI Smart School Management System

A comprehensive, AI-powered school management system built with a modern tech stack. Separate backend API and frontend for scalability, multi-device support, and future mobile app development.

## 🎯 Architecture

```
AI Smart School
├── api/                    # PHP REST API (Port 8000)
│   ├── v1/
│   │   ├── auth/          # Authentication endpoints
│   │   ├── schools/       # School management
│   │   ├── users/         # User management
│   │   ├── classes/       # Class management
│   │   ├── students/      # Student enrollment & profiles
│   │   ├── dashboard/     # Role-based dashboards
│   │   ├── attendance/    # Attendance tracking
│   │   ├── grades/        # Grade management
│   │   ├── assignments/   # Assignment management
│   │   ├── fees/          # Fee management
│   │   └── announcements/ # Announcements
│   ├── middleware/        # Auth, CORS, validation
│   └── index.php          # API router
│
├── frontend/              # React + TypeScript (Port 3000)
│   ├── src/
│   │   ├── components/    # Reusable UI components
│   │   ├── pages/         # Page components
│   │   ├── services/      # API client
│   │   ├── stores/        # Zustand state management
│   │   ├── types/         # TypeScript types
│   │   ├── utils/         # Helper functions
│   │   └── App.tsx        # Main app component
│   └── package.json
│
├── database/
│   └── schema.sql         # PostgreSQL schema
│
├── config/                # Shared configuration
│   ├── config.php         # App config
│   ├── database.php       # DB connection
│   └── jwt.php            # JWT authentication
│
└── .env.example           # Environment variables template
```

## 🚀 Quick Start

### Prerequisites
- PHP 8.0+
- Node.js 18+
- PostgreSQL 12+
- Composer (optional, for PHP dependencies)

### 1. Setup Database

```bash
# Create database
createdb ai_school

# Load schema
psql ai_school < database/schema.sql
```

### 2. Setup API Backend

```bash
cd api

# Copy environment file
cp ../.env.example ../.env

# Edit .env with your database credentials
nano ../.env

# Start PHP development server (port 8000)
php -S localhost:8000
```

### 3. Setup React Frontend

```bash
cd frontend

# Install dependencies
npm install

# Create .env for frontend
echo "VITE_API_URL=http://localhost:8000/api" > .env

# Start development server (port 3000)
npm run dev
```

Visit `http://localhost:3000` in your browser.

## 🔐 Authentication

- **JWT-based** token authentication
- Tokens stored in localStorage
- Auto-refresh on 401 responses
- Secure CORS configuration

### Login
```
Email: admin@school.local
Password: (created during database initialization)
```

## 👥 User Roles

1. **Super Admin** — System-wide control, manage all schools
2. **Admin** — System administration
3. **School Owner** — Manage their school, staff, and students
4. **Teacher** — Manage classes, attendance, grades, assignments
5. **Student** — View own courses, grades, attendance, submit assignments
6. **Parent** — View child's progress, attendance, fees
7. **Staff** — View announcements, schedule
8. **Government** — System-wide reports and compliance
9. **Community** — Public portal access

## 📚 API Endpoints

### Authentication
- `POST /api/auth/register` — Register new user
- `POST /api/auth/login` — Login with email/password
- `POST /api/auth/logout` — Logout
- `POST /api/auth/refresh` — Refresh JWT token
- `GET /api/auth/me` — Get current user

### Dashboard
- `GET /api/dashboard` — Role-specific dashboard data

### Schools (Admin only)
- `GET /api/schools` — List schools
- `POST /api/schools` — Create school
- `PUT /api/schools/:id` — Update school
- `DELETE /api/schools/:id` — Delete school

### Users (Admin/School Owner)
- `GET /api/users` — List users
- `POST /api/users` — Create user
- `PUT /api/users/:id` — Update user
- `DELETE /api/users/:id` — Delete user

### Classes (School Owner/Teacher)
- `GET /api/classes` — List classes
- `POST /api/classes` — Create class
- `PUT /api/classes/:id` — Update class

### Students (Teacher/School Owner)
- `GET /api/students` — List students
- `POST /api/students` — Enroll student
- `PUT /api/students/:id` — Update student profile

### Attendance (Teacher)
- `GET /api/attendance` — Get attendance records
- `POST /api/attendance` — Mark attendance
- `PUT /api/attendance/:id` — Update attendance

### Grades (Teacher)
- `GET /api/grades` — Get grades
- `POST /api/grades` — Create grade
- `PUT /api/grades/:id` — Update grade

### Assignments (Teacher/Student)
- `GET /api/assignments` — List assignments
- `POST /api/assignments` — Create assignment
- `POST /api/assignments/:id/submit` — Submit assignment

### Fees (School Owner)
- `GET /api/fees` — List fee invoices
- `POST /api/fees` — Create fee
- `PUT /api/fees/:id` — Update fee status

### Announcements
- `GET /api/announcements` — Get announcements
- `POST /api/announcements` — Create announcement
- `PUT /api/announcements/:id` — Update announcement

## 📱 Mobile Development (Future)

The API is fully REST-based, making it compatible with:
- **React Native** — Shared business logic with web app
- **Android Native** — Kotlin/Java
- **iOS Native** — Swift
- **Flutter** — Dart

## 🛠 Development

### Frontend Development

```bash
cd frontend

# Development with hot reload
npm run dev

# Build for production
npm build

# Type checking
npm run type-check

# Linting
npm run lint
```

### Backend Development

```bash
# Restart API on changes (requires entr or similar)
entr -r php -S localhost:8000 < <(find api -name '*.php')

# Or use a tool like Laravel Valet, Docker, etc.
```

## 🔄 API Response Format

All API responses follow this format:

**Success (2xx)**
```json
{
  "data": { ... },
  "message": "Success message"
}
```

**Error (4xx/5xx)**
```json
{
  "error": "Error description"
}
```

## 🔒 Security Features

- ✅ JWT token authentication
- ✅ Password hashing (bcrypt)
- ✅ CORS protection
- ✅ CSRF protection (in forms)
- ✅ Input sanitization
- ✅ SQL injection prevention (prepared statements)
- ✅ Role-based access control (RBAC)
- ✅ HttpOnly session cookies

## 📊 Database Schema

PostgreSQL tables:
- `users` — User accounts and credentials
- `schools` — School information
- `classes` — Class definitions
- `subjects` — Subject listings
- `student_profiles` — Student additional info
- `attendance` — Attendance records
- `grades` — Student grades
- `assignments` — Assignment definitions
- `assignment_submissions` — Student submissions
- `timetable` — Class schedule
- `fee_types` — Fee definitions
- `fee_invoices` — Fee payments
- `announcements` — System announcements
- `community_posts` — Community forum posts

See `database/schema.sql` for full details.

## 🚢 Deployment

### PHP API (on shared hosting)

1. Upload `api/`, `config/`, `database/` to your hosting
2. Set `.env` file with database credentials
3. Make sure `php -S` is allowed or configure with your host
4. Point domain to `api/index.php`

### React Frontend

```bash
# Build
npm run build

# Upload `dist/` folder to your hosting
# Configure server to serve index.html for all routes
```

For hosting, see:
- **API**: Deploy to any PHP 8.0+ hosting (yours)
- **Frontend**: Netlify, Vercel, GitHub Pages, or your hosting

## 📝 Environment Variables

Create `.env` in root:

```env
# API
API_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ai_school
DB_USER=postgres
DB_PASS=yourpassword
JWT_SECRET=change-this-in-production

# Frontend
VITE_API_URL=http://localhost:8000/api

# CORS
FRONTEND_URL=http://localhost:3000
```

## 🤝 Contributing

This is a full-stack system. Follow these conventions:

**Backend:**
- Use prepared statements for all queries
- Return JSON responses
- Implement proper error handling
- Add JWT auth checks where needed

**Frontend:**
- Use functional components & hooks
- Keep components small & reusable
- Use TypeScript strictly
- Handle loading/error states

## 📄 License

This project is open source and available under the MIT License.

## 🎓 Built with AI

This system was designed to support AI-powered features:
- AI tutoring chatbots
- Automated grading
- Personalized learning paths
- Smart attendance analysis
- Predictive student performance
- Natural language assignments

API is ready for Claude/OpenAI integration.

---

**Questions?** Check the docs or create an issue!
