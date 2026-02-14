# 📍 Geo App — Project Documentation

## Introduction

**Geo App** is a full-stack geolocation application developed by **Dhars**. It consists of an **iOS frontend** built with Swift (UIKit) and a **Node.js backend** powered by Express and MongoDB. The app allows users to track their real-time location, navigate toward a destination using a built-in compass, and drop geolocation pins on an interactive map — all synchronized with a cloud-connected backend API.

**Author:** Dhars  
**Frontend Repo:** [Priyadharsan77/Compass-Swift](https://github.com/Priyadharsan77/Compass-Swift)  
**Backend Repo:** [Priyadharsan77/geo-app-backend](https://github.com/Priyadharsan77/geo-app-backend)

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [System Architecture](#system-architecture)
3. [Frontend — iOS App](#frontend--ios-app)
4. [Backend — Node.js API](#backend--nodejs-api)
5. [API Reference](#api-reference)
6. [Data Flow](#data-flow)
7. [Folder & File Structure](#folder--file-structure)
8. [Setup & Installation](#setup--installation)
9. [Configuration](#configuration)
10. [Running the Application](#running-the-application)
11. [Troubleshooting](#troubleshooting)

---

## Tech Stack

| Layer | Technology | Version |
|:------|:-----------|:--------|
| **Frontend** | Swift / UIKit | iOS 9+ |
| **Backend** | Node.js / Express | v4.17.1 |
| **Database** | MongoDB (via Mongoose) | v5.12.3 |
| **APIs** | RESTful JSON | — |
| **IDE** | Xcode | Latest |

---

## System Architecture

```
┌──────────────────────────────────────────────────────────┐
│                      iOS Device                          │
│                                                          │
│  ┌─────────────────┐       ┌──────────────────────────┐  │
│  │ CompassView      │──tap──▶│ MapViewController        │  │
│  │ Controller       │◀──────│ (MKMapView + Pin Drop)   │  │
│  └────────┬─────────┘       └──────────┬───────────────┘  │
│           │                            │                  │
│  ┌────────▼─────────┐                  │                  │
│  │ LocationDelegate  │                  │                  │
│  │ (GPS Tracking)    │                  │                  │
│  └────────┬──────────┘                  │                  │
└───────────┼─────────────────────────────┼─────────────────┘
            │ PUT /api/v1/user            │ GET/POST /api/v1/pins
            ▼                             ▼
┌──────────────────────────────────────────────────────────┐
│                   Backend Server (Node.js)                │
│                                                          │
│  ┌──────────┐    ┌──────────────┐    ┌────────────────┐  │
│  │ Express   │───▶│ Controllers   │───▶│ Mongoose Models│  │
│  │ Router    │    │ (pins, user)  │    │ (Pins, User)   │  │
│  └──────────┘    └──────────────┘    └───────┬────────┘  │
│                                              │           │
└──────────────────────────────────────────────┼───────────┘
                                               │
                                     ┌─────────▼─────────┐
                                     │     MongoDB        │
                                     │  (Atlas / Local)   │
                                     └───────────────────┘
```

---

## Frontend — iOS App

### Key Features
- **Real-time Compass**: A rotating arrow that always points toward the user's selected destination using `CLLocationManager` heading data.
- **Interactive Map**: An `MKMapView` where users can tap to drop pins and select destinations.
- **Live Location Tracking**: Continuously sends the device's GPS coordinates to the backend API.
- **Persistent Destination**: The selected destination is saved locally using `UserDefaults`.

### Core Components

| Component | File | Role |
|:----------|:-----|:-----|
| App Entry | `AppDelegate.swift` | App lifecycle management |
| Compass Screen | `CompassViewController.swift` | Rotating arrow UI, heading updates, tap-to-map |
| Map Screen | `MapViewController.swift` | Map display, pin dropping, API calls |
| GPS Handler | `LocationDelegate.swift` | CLLocationManager delegate, sends location to API |
| Bearing Math | `CLLocation+Extension.swift` | Calculates angle between two coordinates |
| Storage | `UserDefauts+Extensions.swift` | Saves/loads destination from UserDefaults |
| Data Models | `Models/Pin.swift`, `Pinresponse.swift`, `Location.swift` | Codable structs for JSON parsing |

---

## Backend — Node.js API

### Key Features
- **RESTful API**: Clean REST endpoints for pin and user management.
- **MongoDB Integration**: Uses Mongoose ODM with GeoJSON support (`2dsphere` index).
- **CORS Enabled**: Allows cross-origin requests from any client.
- **Environment Config**: Uses `dotenv` for secure configuration management.

### Core Components

| Component | File | Role |
|:----------|:-----|:-----|
| Server Entry | `server.js` | Express setup, middleware, route mounting |
| DB Connection | `config/db.js` | Mongoose connection to MongoDB |
| Pin Logic | `controllers/pins.js` | `getPins()` and `addPins()` handlers |
| User Logic | `controllers/user.js` | `postUser()` and `updateUser()` handlers |
| Pin Schema | `models/Pins.js` | Mongoose schema for pin data |
| User Schema | `models/User.js` | Mongoose schema for user data |
| Pin Routes | `routes/pins.js` | GET & POST at `/api/v1/pins` |
| User Routes | `routes/user.js` | POST & PUT at `/api/v1/user` |

---

## API Reference

### Pins

| Method | Endpoint | Description |
|:-------|:---------|:------------|
| `GET` | `/api/v1/pins` | Retrieve all saved pins |
| `POST` | `/api/v1/pins` | Create a new pin |

**POST Body:**
```json
{
    "pinId": "1",
    "location": {
        "coordinates": [longitude, latitude]
    }
}
```

### Users

| Method | Endpoint | Description |
|:-------|:---------|:------------|
| `POST` | `/api/v1/user` | Register a new user |
| `PUT` | `/api/v1/user` | Update user's live location |

**POST/PUT Body:**
```json
{
    "userId": "Dhars",
    "location": {
        "coordinates": [longitude, latitude]
    }
}
```

---

## Data Flow

### Flow 1: App Launch → Location Tracking
1. `AppDelegate` initializes the app.
2. `CompassViewController` loads and starts `CLLocationManager`.
3. `LocationDelegate` receives GPS updates.
4. Each update triggers a `PUT /api/v1/user` request to sync the device's location with the backend.

### Flow 2: User Taps Compass → Opens Map
1. Tap gesture on `CompassViewController` triggers `showMap()`.
2. `MapViewController` is presented via storyboard segue.
3. The map displays the user's current location with `showsUserLocation = true`.

### Flow 3: User Drops a Pin → Data Saved
1. User taps a point on the map.
2. `GET /api/v1/pins` fetches all existing pins to calculate the next `pinId`.
3. `POST /api/v1/pins` sends the new pin's coordinates to the backend.
4. The compass destination updates to the tapped location.
5. MongoDB stores the new pin with a `2dsphere`-indexed location.

---

## Folder & File Structure

### Frontend (`Compass-Swift`)
```
geo-app/
├── Compass.xcodeproj/
│   ├── project.pbxproj
│   └── project.xcworkspace/
│       ├── contents.xcworkspacedata
│       └── xcshareddata/
│           └── IDEWorkspaceChecks.plist
├── compass/
│   ├── AppDelegate.swift
│   ├── CompassViewController.swift
│   ├── MapViewController.swift
│   ├── MapViewControllerDelegate.swift
│   ├── LocationDelegate.swift
│   ├── CLLocation+Extension.swift
│   ├── UserDefauts+Extensions.swift
│   ├── Info.plist
│   ├── Models/
│   │   ├── Location.swift
│   │   ├── Pin.swift
│   │   └── Pinresponse.swift
│   ├── Assets.xcassets/
│   │   ├── Contents.json
│   │   ├── AppIcon.appiconset/
│   │   └── arrow.imageset/
│   └── Base.lproj/
│       ├── Main.storyboard
│       └── LaunchScreen.storyboard
├── LICENSE
└── README.md
```

### Backend (`geo-app-backend`)
```
geo-app-backend/
├── server.js
├── package.json
├── package-lock.json
├── .gitignore
├── README.md
├── config/
│   ├── config.env          ← Environment variables (PORT, MONGO_URI)
│   └── db.js
├── controllers/
│   ├── pins.js
│   └── user.js
├── models/
│   ├── Pins.js
│   └── User.js
└── routes/
    ├── pins.js
    └── user.js
```

---

## Setup & Installation

### Prerequisites
- **Node.js** (v14+) — [Download](https://nodejs.org/)
- **MongoDB Community Edition** — Install via Homebrew (see below)
- **Xcode** (v13+) — [App Store](https://apps.apple.com/us/app/xcode/id497799835)

### MongoDB Installation (macOS)
```bash
# 1. Tap the MongoDB Homebrew formula
brew tap mongodb/brew

# 2. Install MongoDB Community Edition
brew install mongodb-community

# 3. Start MongoDB as a background service (auto-starts on login)
brew services start mongodb-community
```

**Useful MongoDB commands:**
| Action | Command |
|:-------|:--------|
| Start MongoDB | `brew services start mongodb-community` |
| Stop MongoDB | `brew services stop mongodb-community` |
| Check status | `brew services list \| grep mongo` |
| Open Mongo shell | `mongosh` |

### Backend Setup
```bash
cd geo-app-backend
npm install
```

### Frontend Setup
Open `Compass.xcodeproj` in Xcode. No additional dependency installation is required.

---

## Configuration

### Backend Environment Variables
The file `config/config.env` inside `geo-app-backend/` contains:

```env
PORT=3000
NODE_ENV=development
MONGO_URI=mongodb://localhost:27017/geo-app
```

> **Note:** Port 3000 is used instead of 5000 because macOS AirPlay Receiver occupies port 5000 by default.

> Replace `MONGO_URI` with your MongoDB Atlas connection string for cloud deployment.

### Frontend API URL
The iOS app connects to `http://localhost:3000` by default (works with iOS Simulator).  
For **physical device** testing, update the URLs in:
- `compass/MapViewController.swift` (lines 49, 99)
- `compass/LocationDelegate.swift` (line 35)

Replace `localhost` with your Mac's local IP (e.g., `192.168.1.50`) and ensure the port matches the backend.

---

## Running the Application

### Step 1: Start MongoDB (if not already running)
```bash
brew services start mongodb-community
```

### Step 2: Start the Backend
```bash
cd geo-app-backend
npm run dev
```
Expected output:
```
Server running in development mode on port 3000
MongoDB connected: localhost
```

### Step 3: Launch the Frontend (Xcode)
1. Open `Compass.xcodeproj` in Xcode.
2. Click on the **compass** target under **TARGETS**.
3. Go to **Signing & Capabilities** tab.
4. Set **Team** to your Apple ID (Personal Team).
5. Set **Bundle Identifier** to `com.dhars.compass`.
6. Ensure **Automatically manage signing** is checked.
7. In the top device picker, choose a **Simulator** (e.g., iPhone 16 Pro).
8. Press **▶ Play** (`Cmd + R`) to build and run.

### Step 4: Test
- Grant location permissions when prompted → tap **"Allow While Using App"**.
- Set a simulated location: **Simulator menu → Features → Location → Apple**.
- Tap the compass to open the map.
- Tap anywhere on the map to drop a pin.
- Check your backend terminal for incoming API requests.
- Verify stored data: `curl http://localhost:3000/api/v1/pins`

---

## Troubleshooting

| Issue | Solution |
|:------|:---------|
| `MongoDB connected` not showing | Ensure MongoDB is running: `brew services start mongodb-community` |
| `EADDRINUSE: port 5000` | macOS AirPlay uses port 5000. Use port 3000 in `config/config.env` instead |
| App can't reach backend | Ensure backend is running on port 3000 before launching the app |
| Signing errors in Xcode | Select a **Simulator** (not "Any iOS Device") and set your Team in Signing & Capabilities |
| `kCLErrorDomain error 1` | Set a simulated location: **Simulator → Features → Location → Apple** |
| `nw_socket_set_connection_idle` | Harmless iOS Simulator noise — can be safely ignored |
| Location not updating in Simulator | Use **Features → Location → Custom Location** in the Simulator menu |
| `DUPLICATE_KEY` error on POST | The `pinId` or `userId` already exists in the database |
| Physical device can't connect | Replace `localhost` with your Mac's IP address in the Swift files |

---

*Documentation created by Dhars • February 2026*
