
#Virtual Race

## About the App:

Virtual Race is an IOS application designed to let Fitbit users race themselves and their friends across the map. This app provides users with three unique race options:

- New York City to Los Angeles
- U.S. Cellular Field to Wrigley Field in Chicago, IL
- Philadelphia, PA to Washington, D.C.

You have the option to race yourself to see how quickly you can finish the race, or you can challenge your Fitbit friends to races to see who can finish first. 


## Requirements to Use the App:

- Upon entering the app, users will be asked for permission to access their Fitbit accounts and then temporarily redirected to Fitbit's servers to grant permission. Permission is granted for 1 year at a time and must be renewed every year.

- User's must have an iCloud account set up with Apple. Your phone must be signed into iCloud and Virtual Race must be given permission to use iCloud information in the iCloud Drive settings. Without being signed into iCloud, users will not be able to create new races, check the progress of their opponents, or update their progress against opponents. But, users will be able to check their progress in any specific race, although they will not be able to see the progress of their opponents or update their progress in the race on the servers. 

- Viewing races currently require an internet connection in order for the app to generate the route and place user avatars on the route. If no network connection exists, the app will let the user know. 


##Other Things to Know:


- Virtual Race access a list of friends from a user's Fitbit account. If you wish to race someone who does not show up in the Virtual Race app, first go into your Fitbit accounts and add them as a friend there.

- Virtual Race will detect races started by the user on any device and automatically update the device they are currently logged into with all those races. 

- Virtual Race will attempt to update all multiplayer races with the users progress in the background on occasion when the user is on the View Current Races screen. 

- Virtual Race requires a network connection to view races. 

- As of now, Virtual Race can only determine the day in which a user finishes the race and can not localize the time any further than that. If two racers finish on the same day but at different times, Virtual Race will declare the race a tie. This is due to the nature of the Fitbit API which only allows access to a users distance in daily increments. Fitbit does make special exceptions to this rule sometimes though, and hopefully in the future Virtual Race will be able to narrow down the finish time to a more specific increment of time. 


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
