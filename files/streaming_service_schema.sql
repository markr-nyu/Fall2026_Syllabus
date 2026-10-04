PRAGMA foreign_keys = ON;

CREATE TABLE user (
  userId INTEGER PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE
);

CREATE TABLE playlist (
  playlistId INTEGER PRIMARY KEY,
  userId INTEGER NOT NULL,
  name TEXT NOT NULL,
  createdAt TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (userId) REFERENCES user(userId)
);

CREATE TABLE artist (
  artistId INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

CREATE TABLE track (
  trackId INTEGER PRIMARY KEY,
  artistId INTEGER NOT NULL,
  title TEXT NOT NULL,
  durationSeconds INTEGER CHECK (durationSeconds > 0),
  FOREIGN KEY (artistId) REFERENCES artist(artistId)
);

CREATE TABLE playlistTrack (
  playlistId INTEGER NOT NULL,
  trackId INTEGER NOT NULL,
  position INTEGER NOT NULL CHECK (position > 0),
  PRIMARY KEY (playlistId, trackId),
  FOREIGN KEY (playlistId) REFERENCES playlist(playlistId),
  FOREIGN KEY (trackId) REFERENCES track(trackId)
);
