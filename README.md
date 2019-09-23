# bullet

Bullet is an iOS app that allows you to post anonymously and see posts in a given area.

## Views

#### ViewController.swift
The initial view shows all posts within your area. It first prompts the user to use location services, and then displays nearby posts. If a user clicks on an existing post from the list, they will be brought to a view that shows more info about the post (ViewPostController.swift). If a user clicks the post button at the bottom of the initial view, they will be brought to a view that allows them to create a new post (NewPostController.swift).

#### ViewPostController.swift
Allows user to view a post in more detail

#### NewPostController.swift
Allows user to create a new post.

## Data

#### DataModel.swift
DataModel object allows the main view controller to populate the UI with recent posts, as well as insert posts into the database.

#### Post.swift
Post is an object representation of a Post in the app. It stores the message, timestamp, location, and unique database key of the post.

## Firebase
Bullet uses a Firebase database to populate recent posts in your area.

## GeoFire
GeoFire is an open source library that allows location-based queries. For our project, we used a GeoFire circle query, which allows you to query for documents that have values within a certain radius of a GPS coordinate.# Bullet
# Bullet
