# LDLARadio 

Los Locos de la Radio

## Ruby on Rails server and iOS Client

Available version 1.0 in Apple Store [https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1](https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1)

## Requirements

### Ruby On Rails

* Rails 5.0

* sqlite3 1.3.13

* OS: Darwin 17.7.0 x86_64


#### Install

* \curl -L https://get.rvm.io | bash -s stable --ruby

### [iOS](ios)

* Xcode Build Version 10.2.1 (10E1001)

* Deployment target: iOS 12.0

* Devices: Universal (iPhone / iPad)

* Rotation: all.

* [Data Model in Core Data Graph](ios/LDLA-Model.jpg)


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

## Proposal: 

* Cocoapod integration in the project

CocoaPods is the popular dependency manager for Cocoa projects. 2 alternatives: Carthage and the Swift Package Manager. CocoaPods makes managing dependencies easy and transparent.

It's hard configuring Podfile dependencies for a modular project structure
When it comes to a mixed project, having% of Swift and rest Objective-C code, CocoaPods forces all dependencies to be dynamic frameworks, even though more than a half of them are written in Objective-C. With more than 50 dynamic frameworks, our app’s startup time became very slow due to slow dynamic library loading during app startup.

Another issue was our slow build time. The root cause came via including a pods’ source code into the workspace, which often forces recompilation of the same files that very rarely change.

Probably will be good a manual approach. As it turns out, that  just with a few simple scripts that support the most common tasks for dependency management. Namely, downloading source code, compiling it into a static library or dynamic framework and integrating those products into our project. The rest of the work is done via Xcode build configuration files.

* Using Swift 5 + Storyboards + Asset Catalog 

* MVC & MVVM: Separated Logics and avoid Massive View Controller

* Completion/Closure Parameters – Implement any asynchronous task with a “completion” parameter 

* CocoaPods: CocoaPods is built with Ruby and is installable with the default Ruby available on macOS. 

* Recycling: github/fork for any needed change in a pod that is not available for tvOS but could be customized 

* Minimalism: use the SDK. Keeping and use only the features the code actually needs.

* *Core Data* is an object graph and persistence framework provided by Apple in the macOS and iOS operating systems. It was introduced in Mac OS X 10.4 Tiger and iOS with iPhone SDK 3.0. It allows data organized by the relational entity–attribute model to be serialized into XML, binary, or SQLite stores. In this aplication the persistence is done using SQLite.

* Unit tests: automatically exercise the features of your application and check the results, like JSON parsing and test asynchronous calls for REST API using expectation.

* Singleton for RestAPI and model & network management.

* Observers: KVO and Notifications

* Protocols: a very powerful feature of the Swift programming language. Protocols are used to define a “blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality.”

* *Extensions* add new functionality to an existing class, structure, enumeration, or protocol type. This includes the ability to extend types for which you do not have access to the original source code (known as retroactive modeling). Extensions are similar to categories in Objective-C. (Unlike Objective-C categories, Swift extensions do not have names.). Extensions in Swift can: add computed instance properties and computed type properties, define instance methods and type methods, provide new initializers, define subscripts, define and use new nested types, make an existing type conform to a protocol.

* *Grand Central Dispatch* or *GCD* is a low-level API for managing concurrent operations. It will make your application smooth and more responsive. Also helps for improving application performance. Sometimes we are trying to perform multiple tasks at the same time that time most of the developer-facing application hang or freezing issue this is the common issue. That’s why we are using GCD to manage multiple tasks at the same time.

* Why not using NSOperationQueue instead of DispatchQueue in the threading solution?
_NSOperationQueue uses regular background threads which have a little more overhead than GCD dispatch queues. On the other hand, NSOperationQueue gives you a lot more control over how your operations are executed. You can define dependencies between individual operations for example, which isn't possible with plain GCD queues. GCD is a low-level C API that enables developers to execute tasks concurrently. Operation queues, on the other hand, are high level abstraction of the queue model, and is built on top of GCD. Operation queues are instances of class NSOperationQueue and its tasks are encapsulated in instances of NSOperation._



### License

MIT License

Copyright (c) 2019 Mobile Patagonia. All rights reserved.

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


[Contact me](https://mobilepatagonia.wixsite.com/website)

