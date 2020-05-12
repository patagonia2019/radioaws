# Locos de la Azotea 


Los Locos de la Azotea, it's a tribute to people that innovates and jump to the next curve.
The four locos de la azotea brought the effort for the first radio broadcast in Argentina, and subsequently established one of the earliest regular radio stations in the world. 

This is an iOS app for radio streaming, resources online and podcasts.
Here you can listen to any online radio and available podcasts around the globe in different languages: German, English, Spanish, French, etc.
There is a list of proposed radios, or you can configure your own in bookmark (My Pick).
Do you know "El Desconcierto" from Quique Pesoa, here you can listen to the stream online or the previous emissions. 
There is also a list of RNA (Radio Nacional Argentina) stations.
It included Archive.org audios and Radio Time audios.

## iOS Client

Available version 3.1 in Apple Store [https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1](https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1)

## Requirements

### iOS

* Xcode Build Version 11.3.1 (11C504)

* Deployment target: iOS 13.3

* Devices: Universal (iPhone / iPad)

* Rotation: all.

* [Data Model in Core Data Graph](LDLA-Model.jpg)



#### External resources

* Using a ios-icon-launch-generator.sh thanks to [smallmuou](https://github.com/smallmuou)/[ios-icon-generator](https://github.com/smallmuou/ios-icon-generator), it's a script to generate iOS/macOS/watchOS app icons more easier. I've added `Launch Images`, and a more customizable way to generate Landscape launch images for iPhone/iPad.

* [FontAwesome](fontawesome.com). *Font Awesome Free* is free, open source, and GPL friendly. You can use it for commercial projects, open source projects, or really almost whatever you want.

* [Quotes](https://github.com/JamesFT/Database-Quotes-JSON/blob/master/quotes.json). Thanks to [JameFT](https://github.com/JamesFT)/[Database-Quotes-JSON](https://github.com/JamesFT/Database-Quotes-JSON)

##### My Own Library 

[JFCore](https://github.com/patagonia2019/jfcore)
_Some interesting Core elements to reuse in my own projects in iOS / macOS / tvOS / watchOS: CoreDataManager, Location Manager and others._


##### External Libraries / Frameworks

[Alamofire](https://cocoapods.org/pods/Alamofire)
_Alamofire is an HTTP networking library written in Swift._

[Groot](https://cocoapods.org/pods/Groot)
_Groot provides a simple way of serializing Core Data object graphs from or into JSON._

[AlamofireCoreData](https://cocoapods.org/pods/AlamofireCoreData)
_A nice Alamofire serializer that convert JSON into NSManagedObject instances. Using a fork for now until tvOS is fully supported https://github.com/southfox/AlamofireCoreData_

[AlamofireImage](https://cocoapods.org/pods/AlamofireImage)
_AlamofireImage is an image component library for Alamofire_

[SwiftSpinner](https://cocoapods.org/pods/SwiftSpinner)
_SwiftSpinner is an extra beautiful activity indicator with plain and bold style fitting iOS 8 design very well. It uses dynamic blur and translucency to overlay the current screen contents and display an activity indicator with text (or the so called “spinner”)._


####  Install

1. Clone repository
`git clone https://github.com/southfox/radioaws.git
2. Enter inside the folder of the project
`cd ios`
3. Install pods
`pod install`
4. Open workspace 
`open LDLARadio.xcworkspace`
5. Clean and build project with Xcode.

#### Endpoints 

* The Rails server with Suggestions.

* Radio Time: it's the RestAPI used by [TuneIn](https://tunein.com)

* Radio Nacional Argentina

* Archive Org: [JSON](https://archive.org/help/json.php)
_Using JSON api example: [https://archive.org/advancedsearch.php?q=<TEXT_TO_SEARCH>&sort%5B%5D=&sort%5B%5D=&sort%5B%5D=&rows=50&page=1&output=json&save=yes#raw](https://archive.org/advancedsearch.php?q=harry+potter+audiobook&sort%5B%5D=&sort%5B%5D=&sort%5B%5D=&rows=50&page=1&output=json&save=yes#raw). And access a particular metadata of the search using the identifier: [https://archive.org/details/HarryPotterAndThePhilosophersStoneAudiobookSample&output=json](https://archive.org/details/<IDENTIFIER>&output=json). We can query by meditype audio: [https://archive.org/services/collection-rss.php?mediatype=audio&output=json](https://archive.org/services/collection-rss.php?mediatype=audio&output=json). More info: https://archive.readme.io/docs/getting-started_

# MIT License

## Copyright (c) 2019 Mobile Patagonia. All rights reserved.

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


### [Contact me](https://mobilepatagonia.wixsite.com/website)

