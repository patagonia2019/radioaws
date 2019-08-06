# LDLARadio 

Los Locos de la Radio

## iOS Client

Available version 1.0 in Apple Store [https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1](https://apps.apple.com/us/app/los-locos-de-la-azotea/id1474338334?ls=1)

## Requirements

### iOS

* Xcode Build Version 10.2.1 (10E1001)

* Deployment target: iOS 12.0

* Devices: Universal (iPhone / iPad)

* Rotation: all.

* [Data Model in Core Data Graph](LDLA-Model.jpg)

* Screenshots: 



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
_Using [JSON api example](https://archive.org/advancedsearch.php?q=harry+potter+audiobook&sort%5B%5D=&sort%5B%5D=&sort%5B%5D=&rows=50&page=1&output=json&save=yes#raw)_


## Proposal: 

### Cocoapod integration in the project

CocoaPodss built with Ruby and is installable with the default Ruby available on macOS. 

CocoaPods is the popular dependency manager for Cocoa projects. 2 alternatives: Carthage and the Swift Package Manager. CocoaPods makes managing dependencies easy and transparent.

It's hard configuring Podfile dependencies for a modular project structure
When it comes to a mixed project, having of Swift and rest Objective-C code, CocoaPods forces all dependencies to be dynamic frameworks, even though more than a half of them are written in Objective-C. With more than 50 dynamic frameworks, our app’s startup time became very slow due to slow dynamic library loading during app startup.

Another issue was our slow build time. The root cause came via including a pods’ source code into the workspace, which often forces recompilation of the same files that very rarely change.

Probably will be good a manual approach. As it turns out, that  just with a few simple scripts that support the most common tasks for dependency management. Namely, downloading source code, compiling it into a static library or dynamic framework and integrating those products into our project. The rest of the work is done via Xcode build configuration files.

### Using Swift 5

#### Reference type vs Value type
Reference types share a single copy of their data while value types keep a unique copy of their data. Swift represents a reference type as a class, and a value type as a struct, enum, and tuples.

##### Copy semantics
In Swift, we have reference types(Classes) and value types (Structs, Tuples, enums). The value types have a copy semantic. That means if you assign a value type to a variable or pass it as a parameter to a function(unless it is an inout parameter), the underlying data of this value is going to be copied.

#### Access control levels: open, public, internal, fileprivate and private

* open and public — (least restrictive) Enable an entity to be used outside the defining module (target). ...
_Enable an entity to be used outside the defining module (target). You typically use open or public access when specifying the public interface to a framework._

* Public. ...
_Like open access level, public access level enable an entity to be used outside the defining module (target). But open access level allows us to subclass it from another module where in public access level, we can only subclass or override it from within the module it is defined_
`
//module 1
public func A(){}
open func B(){}
//module 2
override func A(){} // error
override func B(){} // success
`

* internal (default access level) ...
_internal is the default access level. Internal classes and members can be accessed anywhere within the same module(target) they are defined. You typically use internalaccess when defining an app’s or a framework’s internal structure._

* fileprivate. ...
_Restricts the use of an entity to its defining source file._

* private — (most restrictive)
_Private access restricts the use of an entity to the enclosing declaration, and to extensions of that declaration that are in the same file._
__Before swift 4, private access level didn’t allow the use of a class member inside the extension of same class.__

_Ex: If you are creating a framework for facebook login in swift. The developer will import the framework you created and try to call the login() function. if you want the developer to call this method, it should be declared as public inside the framework. If you want the developer to call the function and override the login() function, it should be declared as open. Simple!!_

### Storyboards
### Asset Catalog 

### MVC & MVVM: Separated Logics and avoid Massive View Controller

### Completion/Closure Parameters
Implement any asynchronous task with a “completion” parameter 

### Recycling

Github/fork for any needed change in a pod that is not available for tvOS but could be customized 

### Minimalism

Use the SDK. Keeping and use only the features the code actually needs.

### Core Data

It is an object graph and persistence framework provided by Apple in the macOS and iOS operating systems. It was introduced in Mac OS X 10.4 Tiger and iOS with iPhone SDK 3.0. It allows data organized by the relational entity–attribute model to be serialized into XML, binary, or SQLite stores. In this aplication the persistence is done using SQLite.

### Code Testing

Automatically exercise the features of the application and check the results, like JSON parsing and test asynchronous calls for REST API using expectations.
Code testing serves as great documentation, confidence to constantly refactor, architecture health, perspective on the API design, but it is not realistic to achieve high coverage.
Here there are 4 classes to make Unit Testing: __LDLARadioTests__, __RTCatalogTests__, __RNATests__ and __BookmarkTests__. They inherit setup and json helpers from __BaseTests__ class.


### Singleton for RestAPI and model & network management.

### Observers: KVO and Notifications

### Protocols

A very powerful feature of the Swift programming language. Protocols are used to define a “blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality.”

### Extensions

They add new functionality to an existing class, structure, enumeration, or protocol type. This includes the ability to extend types for which you do not have access to the original source code (known as retroactive modeling). Extensions are similar to categories in Objective-C. (Unlike Objective-C categories, Swift extensions do not have names.). Extensions in Swift can: add computed instance properties and computed type properties, define instance methods and type methods, provide new initializers, define subscripts, define and use new nested types, make an existing type conform to a protocol.

### Grand Central Dispatch or GCD

GCD is a low-level API for managing concurrent operations. It will make your application smooth and more responsive. Also helps for improving application performance. Sometimes we are trying to perform multiple tasks at the same time that time most of the developer-facing application hang or freezing issue this is the common issue. That’s why we are using GCD to manage multiple tasks at the same time.

#### Why not using NSOperationQueue instead of DispatchQueue in the threading solution?

NSOperationQueue uses regular background threads which have a little more overhead than GCD dispatch queues. On the other hand, NSOperationQueue gives you a lot more control over how your operations are executed. You can define dependencies between individual operations for example, which isn't possible with plain GCD queues. GCD is a low-level C API that enables developers to execute tasks concurrently. Operation queues, on the other hand, are high level abstraction of the queue model, and is built on top of GCD. Operation queues are instances of class NSOperationQueue and its tasks are encapsulated in instances of NSOperation.

## Don't Repeat Yourself
Don’t Repeat Yourself (DRY) is a principle in software development that helps you reduce the amount of repetition in your code and apps. This has a number of advantages, for example, code that’s easier to maintain.

## GRASP (object-oriented design)
_General Responsibility Assignment Software Patterns: controller, creator, indirection, information expert, high cohesion, low coupling, polymorphism, protected variations, and pure fabrication._
## KISS
It's a principle of design. The phrase has been associated with aircraft engineer Kelly Johnson. The term "KISS principle" was in popular use by 1970. Variations on the phrase include: "Keep it simple, silly", "keep it short and simple", "keep it simple and straightforward", "keep it small and simple", or "keep it stupid simple".
## YAGNI
_You aren't gonna need it. Not add functionality until deemed necessary_

## SOLID
_ 6 principles for OOP_:
### SRP: Single responsibility principle
_A class should only have a single responsibility, that is, only changes to one part of the software's specification should be able to affect the specification of the class._
### OCP: Open/closed principle
_"Software entities ... should be open for extension, but closed for modification."_
### L: Liskov substitution principle
_"Objects in a program should be replaceable with instances of their subtypes without altering the correctness of that program." ._
### Interface segregation principle
_"Many client-specific interfaces are better than one general-purpose interface."_
### Dependency inversion principle
_One should "depend upon abstractions, [not] concretions."_
#### Dependency injection principle


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

