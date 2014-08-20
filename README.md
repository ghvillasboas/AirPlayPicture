AirPlay Picture
=============

This is concept test of iOS 7/8 using a secondary screen on a AppleTV to display content.

It works both in single screen (device only) and multi screen (device + AppleTV)

The AppleTV screen is loaded using a proposed file architecture where it has its own storyboard file.

The app connects to Flickr and downloads the most recent photos from all over the world displaying them on a **UICollectionView**. If you're not connected to a AppleTV, the app will work as expected. You tap a cell and it displays the content.

If you're on a AppleTV, it will display the full size picture on the big screen and your device will be abel to control it.

Reacts to display connection and disconnection seamlessly.

![iOS + AppleTV](https://raw.github.com/ghvillasboas/AirPlayPicture/master/images/airplay1.png)


## How to get it working

1. Clone and open this repository with XCode 5/6.

2. Install the pod dependencies using ``` pod install ```. Only for the FlickrAPI.

3. Run on the simulator or device.

4. To activate the second display:

  - **Simulator:** Menu Hardware > External Displays > Desired screen size (usually 720p)
  - **AppleTV:** Just activate AirPlay and mirror your device's screen. Voilá!

## Questions?

Just fire an Issue.

## Contributions?

Send me a pull request!

Enjoy!