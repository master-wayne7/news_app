## News App
A modern news application built with Flutter and GetX. The app fetches and displays news from various sources, allowing users to browse headlines, search for specific topics, filter by categories, and save favorite articles.
## Features

- Latest News: Browse trending news articles
- Category Filtering: Filter news by different categories (Business, Sports, Tech, etc.)
- Search Functionality: Search for specific news articles by keyword
- Article Details: View full article details with options to read the complete article online
- Favorites: Save and manage favorite articles using local storage
- Dark/Light Theme: Support for system theme

## Technology Stack

### Frontend (Flutter)

- Flutter: UI framework
- GetX: State management, dependency injection, and routing
- Hive: Local storage for favorite articles
- HTTP: API communication
- Cached Network Image: Efficient image loading and caching

### Backend (Node.js)

- Express: Web server framework
- Axios: HTTP client for API requests
- Node-Cache: Caching layer for API responses
- Helmet: Security middleware
- Cors: Cross-Origin Resource Sharing middleware

##  Project Structure

### Flutter App

```
news_app/
  ├── lib/
  │   ├── main.dart
  │   ├── app_binding.dart
  │   ├── core/
  │   │   ├── constants/
  │   │   ├── theme/
  │   │   └── utils/
  │   ├── data/
  │   │   ├── models/
  │   │   ├── providers/
  │   │   └── repositories/
  │   ├── presentation/
  │   │   ├── controllers/
  │   │   ├── widgets/
  │   │   └── pages/
  │   └── routes/
  │       └── app_pages.dart
  ├── pubspec.yaml
  └── test/
```

### Node.js Backend

```
node_backend/
  ├── src/
  │   ├── controllers/
  │   ├── models/
  │   ├── routes/
  │   └── services/
  ├── index.js
  ├── package.json
  └── .env
```

## Getting Started

### Prerequisites

- Flutter (latest stable version)
- Node.js and npm
- News API key (from newsapi.org)

### Installation

#### Flutter App

1. Clone the repository
2. Navigate to the project directory
3. Create a `.env` file in the root folder with your API URLs:
```
CUSTOM_API_URL=http://localhost:3000/api
```

4. Install dependencies:
```
flutter pub get
```

5. Run the app:
```
flutter run
```


#### Node.js Backend 

1. Navigate to the node_backend directory
2. Create a .env file with your API keys:
```
PORT=3000
NEWS_API_KEY=your_newsapi_org_key_here
```

3. Install dependencies:
```
npm install
```

4. Start the server:
```
npm run dev
```


## Architecture
The app follows a clean architecture approach with the following layers:

1. Data Layer:

- Models: Data classes representing news articles
- Providers: API communication
- Repositories: Data management and business logic


2. Presentation Layer:

- Controllers: Manage UI state with GetX
- Pages: Screen layouts
- Widgets: Reusable UI components


3. Routes: Navigation management

4. Core: Utilities, constants, and themes

## State Management

The app uses GetX for state management which provides:

- Reactive state variables (Rx)
- Dependency injection
- Route management
- Reactive programming with minimal boilerplate

## Local Storage

Favorite articles are stored locally using Hive, a lightweight and fast key-value database that works well with Flutter.

## API Integration

The app integrates with:

- News API (newsapi.org) as the primary source of news
- Custom Node.js API as a fallback and for additional features

## Build & Deployment

### Building APK
```
flutter build apk --release
```

### Building for iOS
```
flutter build ios --release
```

## License

This project is licensed under the MIT License
