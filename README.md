How To Get
==========

### 1. Install dependencies: [PTImageAlbumViewController](https://github.com/exalted/PTImageAlbumViewController) and  [Nimbus](https://github.com/jverkoey/nimbus)

If your project uses [CocoaPods](http://cocoapods.org) to manage its dependencies, easiest way to install [Nimbus](https://github.com/jverkoey/nimbus) is to add the following in your `Podfile`:

```ruby
pod 'Nimbus/NetworkImage', :podspec => 'https://gist.github.com/exalted/7655606/raw/ce27220c457984ecd30fb800503b4c299159ace0/Nimbus.podspec'
```

### 2. Copy `PTShowcaseViewController` directory into your own project

Instead of manually downloading files, you could use git submodules:

```bash
git submodule add https://github.com/exalted/PTShowcaseViewController.git
```

### 3. `#import` headers

```objectivec
#import <Nimbus/NimbusCore.h>
#import <Nimbus/NimbusPhotos.h>
#import <Nimbus/NimbusNetworkImage.h>
```

### 4. Build & run

If you have trouble, check out `Showcase` project in `Examples` directory for a working example.


Screenshots
===========

> :information_source: Please note: screenshots below are outdated. On devices that run iOS 7 navigationbars and toolbars are actually "flat" and translucent as you would expect.

Screenshot 1.

![Screenshot 1.](http://exalted.github.com/PTShowcaseViewController/iPad/ss1.png "Screenshot 1.")
![Screenshot 1.](http://exalted.github.com/PTShowcaseViewController/iPhone/ss1.png "Screenshot 1.")

Screenshot 2.

![Screenshot 2.](http://exalted.github.com/PTShowcaseViewController/iPad/ss2.png "Screenshot 2.")
![Screenshot 2.](http://exalted.github.com/PTShowcaseViewController/iPhone/ss2.png "Screenshot 2.")

Screenshot 3.

![Screenshot 3.](http://exalted.github.com/PTShowcaseViewController/iPad/ss3.png "Screenshot 3.")
![Screenshot 3.](http://exalted.github.com/PTShowcaseViewController/iPhone/ss3.png "Screenshot 3.")

Screenshot 4.

![Screenshot 4.](http://exalted.github.com/PTShowcaseViewController/iPad/ss4.png "Screenshot 4.")
![Screenshot 4.](http://exalted.github.com/PTShowcaseViewController/iPhone/ss4.png "Screenshot 4.")

Screenshot 5.

![Screenshot 5.](http://exalted.github.com/PTShowcaseViewController/iPad/ss5.png "Screenshot 5.")
![Screenshot 5.](http://exalted.github.com/PTShowcaseViewController/iPhone/ss5.png "Screenshot 5.")

Screenshot 6.

![Screenshot 6.](http://exalted.github.com/PTShowcaseViewController/iPad/ss6.png "Screenshot 6.")
![Screenshot 6.](http://exalted.github.com/PTShowcaseViewController/iPhone/ss6.png "Screenshot 6.")

Screenshot 7.

![Screenshot 7.](http://exalted.github.com/PTShowcaseViewController/iPad/ss7.png "Screenshot 7.")
![Screenshot 7.](http://exalted.github.com/PTShowcaseViewController/iPhone/ss7.png "Screenshot 7.")

Screenshot 8.

![Screenshot 8.](http://exalted.github.com/PTShowcaseViewController/iPad/ss8.png "Screenshot 8.")
![Screenshot 8.](http://exalted.github.com/PTShowcaseViewController/iPhone/ss8.png "Screenshot 8.")

Screenshot 9.

![Screenshot 9.](http://exalted.github.com/PTShowcaseViewController/iPad/ss9.png "Screenshot 9.")
![Screenshot 9.](http://exalted.github.com/PTShowcaseViewController/iPhone/ss9.png "Screenshot 9.")

Screenshot 10.

![Screenshot 10.](http://exalted.github.com/PTShowcaseViewController/iPad/ss10.png "Screenshot 10.")
![Screenshot 10.](http://exalted.github.com/PTShowcaseViewController/iPhone/ss10.png "Screenshot 10.")


How To Contribute
=================

This project uses [CocoaPods](http://cocoapods.org) to manage dependencies. Installing it is as easy as running the following commands in the terminal:

```bash
$ sudo gem install cocoapods
```

If you have any trouble during the installation, please read [CocoaPods documentation](http://docs.cocoapods.org/).

When you've installed CocoaPods, then:

```bash
$ git clone https://github.com/exalted/PTShowcaseViewController.git PTShowcaseViewController-exalted
$ cd PTShowcaseViewController-exalted/Examples/ShowcaseDemo/
$ pod install
$ open ShowcaseDemo.xcworkspace
```
