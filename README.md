# Smashtag

This is the 4th assignment from the course "Developing iOS 8 Apps with Swift", Stanford University, CS193p, Winter 2015.

Platform: iOS 9
Swift: 2.1

Smashtag is a Twitter based app that allows users to:

- perform Twitter search queries
- view Tweet details (including images, links, users, hashtags)
- save 100 most recent queries in a Recent tab
- browse Tweet images in Colllection View

![](https://raw.githubusercontent.com/sanjibahmad/Smashtag/master/screenshots/01-tweets-table.jpg)
![](https://raw.githubusercontent.com/sanjibahmad/Smashtag/master/screenshots/02-images-collection.jpg)
![](https://raw.githubusercontent.com/sanjibahmad/Smashtag/master/screenshots/03-recent-tweets.jpg)
![](https://raw.githubusercontent.com/sanjibahmad/Smashtag/master/screenshots/04-mentions.jpg)
![](https://raw.githubusercontent.com/sanjibahmad/Smashtag/master/screenshots/05-image-details.jpg)

All the 10 Required Tasks were completed. In addition the following Extra Credit items were implemented:

- In the Users section of your new UITableViewController, list not only users mentioned in the Tweet, but also the user who posted the Tweet in the first place.
- When you click on a user in the Users section, search not only for Tweets that mention that user, but also for Tweets which were posted by that user.
- Make the “most recent searches” table be editable (i.e. let the user swipe left to delete the ones they don’t like).
- Add some UI which displays a new view controller showing a UICollectionView of the first image (or all the images if you want) in all the Tweets that match the search. When a user clicks on an image in this UICollectionView, segue to showing them the Tweet.
