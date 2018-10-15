
[![Language](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://swift.org)
[![Licence](https://img.shields.io/dub/l/vibe-d.svg?maxAge=2592000)](https://opensource.org/licenses/MIT)

![PinController. Location](https://github.com/crweaver225/Virtual-Race/blob/master/screenshots/p1.jpg)
![PinController. Location](https://github.com/crweaver225/Virtual-Race/blob/master/screenshots/p2.jpg)
![PinController. Location](https://github.com/crweaver225/Virtual-Race/blob/master/screenshots/p3.jpg)
![PinController. Location](https://github.com/crweaver225/Virtual-Race/blob/master/screenshots/p4.jpg)

## About the App:

Now on the App Store!

Virtual Race is an IOS application designed to let Fitbit users race themselves and their friends across the map. This app provides users with three unique race options:

- New York City to Los Angeles
- U.S. Cellular Field to Wrigley Field in Chicago, IL
- Baton Rouge, LA to New Orleans, LA
- Boston, MA to Washington D.C.

You have the option to race yourself to see how quickly you can finish the race, or you can challenge your Fitbit friends to races to see who can finish first. 


## Requirements to Use the App:

- Upon entering the app, users will be asked for permission to access their Fitbit accounts and then temporarily redirected to Fitbit's servers to grant permission. Permission is granted for 1 year at a time and must be renewed every year.

- User's must have an iCloud account set up with Apple. Your phone must be signed into iCloud and Virtual Race must be given permission to use iCloud information in the iCloud Drive settings. Without being signed into iCloud, users will not be able to create new races, check the progress of their opponents, or update their progress against opponents. But, users will be able to check their progress in any specific race, although they will not be able to see the progress of their opponents or update their progress in the race on the servers. 

- Viewing races currently requires an internet connection in order for the app to generate the route and place user avatars on the route. If no network connection exists, the app will let the user know. 


##Other Things to Know:


- Virtual Race accesses a list of friends from a user's Fitbit account. If you wish to race someone who does not show up in the Virtual Race app, first go into your Fitbit accounts and add them as a friend there. Virutal Race will access a user's list of fitbit friends and cross-reference this to all Virutal Race users. If a fitbit friend has downloaded the Virtual Race app, they will be an available option to request a race with. 

- Virtual Race will attempt to update all multiplayer races with the users progress in the background on occasion when the user is on the View Current Races screen. 

- Virtal Race can now update current two player races in the background. 

- As of now, Virtual Race can only determine the day in which a user finishes the race and can not localize the time any further than that. If two racers finish on the same day but neither updates their race on that day, Virtual Race will declare the race a tie. This is due to the nature of the Fitbit API which only allows access to a users distance in daily increments. Fitbit does make special exceptions to this rule sometimes though, and hopefully in the future Virtual Race will be able to narrow down the finish time to a more specific increment of time. 

- I am looking to impliment a feature where Virtual Race will search the iCloud server to see if any races exists which are not currently persisted in the user's phone and then add them to the phone. This would allow user's to continue races and monitor races from multiple devices. I am having issues getting this feature to work consistently at the moment, but hope to have it implimented soon.  

MIT License

Copyright (c) [2016] [Christopher Weaver]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
