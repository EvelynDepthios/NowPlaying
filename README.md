# NowPlaying - Movie Watchlist & Discovery App

NowPlaying is a Flutter-based mobile application that allows users to explore movies, manage their personal watchlist, and view detailed movie information. The app fetches movie data from The Movie Database (TMDb) API and provides an intuitive user experience with a modern UI.

## Features (Per Page Screen)

### Home Screen
- Browse movies categorized as **Now Showing**, **Upcoming**, and **Popular**.
- View paginated lists of movies fetched from TMDb.
- Quick access to other app sections via the bottom navigation bar.

### All Movies Screen
- Display a complete list of movies.
- Search for movies by title with a responsive search feature.
- Instantly fetch and display search results from TMDb.

### Watchlist Screen
- Save favorite movies to a personal watchlist.
- Remove movies from the watchlist with a confirmation dialog.
- Persistent storage using SharedPreferences to retain watchlist data.

### Movie Detail Screen
- View complete movie details including title, release date, rating, and overview.
- Fetch genre dynamically from the API if not available.
- Toggle favorite status with a **bookmark icon**, saved persistently.

### Profile Screen
- Edit and save user details such as **full name, nickname, and hobbies**.
- Upload and update a **profile picture**.
- Manage **social media links** and favorite **movie preferences**.

## Packages & Dependencies Used
-  **http** : Fetches movie data from TMDb API
- **shared_preferences** : Stores watchlist data & user info persistently
- **image_picker** : Allows users to select a profile picture from the gallery

## Short Lesson Learned Essay
Before working on this project, I had already learned Flutter back in semester 3, but at that time, I didn’t really understand it deeply. I originally thought that Flutter couldn’t store data unless it was connected to Django as the backend, so I never really explored how much it could actually do on its own. Turns out, Flutter has ways to store data locally without needing a backend connection, which was something completely new to me.

One of the most valuable things I discovered was SharedPreferences. Before this, I assumed that saving user data would require integrating Django or another backend service, but I learned that SharedPreferences allows Flutter to store simple data persistently on the device itself. This was a new experience to me, especially when implementing the watchlist and about me feature in this app.

Another major learning point was working with APIs in Flutter. Since this was my first time handling APIs properly, I struggled a lot in the beginning. Understanding how to fetch data, handle responses, deal with errors, and display it dynamically in the UI was challenging. I spent a lot of time reading The Movie Database API documentation, watching Youtube, and debugging various issues. Even though it was frustrating at times, I really enjoyed the process and the challenge, constantly experimenting and searching for solutions until everything worked as expected. Of course, ChatGPT also helped a lot in guiding me through API integration.

Through this project, I improved a lot in Flutter, especially in managing API data, handling UI state, and implementing persistent storage. It also made me grow my interest even more in mobile development, realizing how powerful and flexible Flutter is. Additionally, I learned how to structure code better, making it more readable and maintainable.