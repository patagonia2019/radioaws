//
//  BaseTests.swift
//  LDLARadioTests
//
//  Created by fox on 14/07/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import XCTest
import CoreData
import Groot

class BaseTests: XCTestCase {
    
    var store: GRTManagedStore?
    var context: NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
        
        store = try? GRTManagedStore(model: NSManagedObjectModel.testModel)
        context = store?.context(with: .mainQueueConcurrencyType)
        
        RestApi.instance.context = context
    }
    
    override func tearDown() {
        store = nil
        context = nil
        
        super.tearDown()
    }

    func streamsJSON() -> JSONArray {
        return [
            [
                "id": 1,
                "name": "http://95.154.202.117:14142",
                "url_type": "Stream",
                "station_id": 1,
                "head_is_working": false,
                "listen_is_working": true,
                "use_web": false,
                "source_type": "",
                "url": "http://adminradio.serveftp.com:35111/streams/1.json"
            ],
            [
                "id": 2,
                "name": "http://sa.mp3.icecast.magma.edge-access.net:7200/sc_rad30",
                "url_type": "Stream",
                "station_id": 4,
                "head_is_working": false,
                "listen_is_working": true,
                "use_web": false,
                "source_type": "audio/mpeg",
                "url": "http://adminradio.serveftp.com:35111/streams/2.json"
            ],
            [
                "id": 7,
                "name": "http://200.58.118.108:8304/stream",
                "url_type": "Stream",
                "station_id": 6,
                "head_is_working": false,
                "listen_is_working": true,
                "use_web": nil,
                "source_type": nil,
                "url": "http://adminradio.serveftp.com:35111/streams/7.json"
            ]
        ]
    }
    
    func catalogJSON() -> JSONDictionary {
        return
            [
                "head": [
                    "title": "Browse",
                    "status": "200"
                ],
                "body": [
                    [
                        "element": "outline",
                        "type": "link",
                        "text": "Local Radio",
                        "URL": "http://opml.radiotime.com/Browse.ashx?c=local",
                        "key": "local"
                    ],
                    [
                        "element": "outline",
                        "type": "link",
                        "text": "Music",
                        "URL": "http://opml.radiotime.com/Browse.ashx?c=music",
                        "key": "music"
                    ]
                ]
        ]
        
    }
    
    func sectionJSON() -> JSONDictionary {
        return
            [
                "head":
                    [
                        "title": "Music",
                        "status": "200"
                ],
                "body":
                    [
                        [
                            "element": "outline",
                            "type": "link",
                            "text": "00's",
                            "URL": "http://opml.radiotime.com/Browse.ashx?id=g2754",
                            "guide_id": "g2754"
                        ],
                        [
                            "element": "outline",
                            "type": "link",
                            "text": "50's",
                            "URL": "http://opml.radiotime.com/Browse.ashx?id=g390",
                            "guide_id": "g390"
                        ]
                ]
        ]
    }
    
    func station1JSON() -> JSONDictionary {
        return [
            "head": [
                "title": "Chon Mix Stations - 2h, 34m left",
                "status": "200"
            ],
            "body": [
                [
                    "element": "outline",
                    "type": "audio",
                    "text": "Drive home show-CHON-FM (Whitehorse, Canada)",
                    "URL": "http://opml.radiotime.com/Tune.ashx?id=s12582&sid=p334299&filter=l169",
                    "bitrate": "160",
                    "guide_id": "s12582",
                    "subtext": "The Beat of a different Drummer",
                    "image": "http://cdn-radiotime-logos.tunein.com/s12582q.png",
                    "now_playing_id": "s12582"
                ]
            ]
        ]

    }

    func stationsJSON() -> JSONDictionary {
        return
            [
                "head":
                    [
                        "title": "00's",
                        "status": "200"
                ],
                "body":
                    [
                        [
                            "element": "outline",
                            "text": "Stations",
                            "key": "stations",
                            "children":
                                [
                                    [
                                        "element": "outline",
                                        "type": "audio",
                                        "text": "1.FM- Top Hits 2000 Radio (Switzerland)",
                                        "URL": "http://opml.radiotime.com/Tune.ashx?id=s306583",
                                        "bitrate": "45",
                                        "reliability": "87",
                                        "guide_id": "s306583",
                                        "subtext": "Jessie J Ft. B.O.B - Laserlight",
                                        "genre_id": "g2754",
                                        "formats": "mp3",
                                        "playing": "Jessie J Ft. B.O.B - Laserlight",
                                        "item": "station",
                                        "image": "http://cdn-profiles.tunein.com/s306583/images/logoq.png?t=152880",
                                        "now_playing_id": "s306583",
                                        "preset_id": "s306583"
                                    ],
                                    [
                                        "element": "outline",
                                        "type": "audio",
                                        "text": "Hotmixradio 2000 (France)",
                                        "URL": "http://opml.radiotime.com/Tune.ashx?id=s216185",
                                        "bitrate": "320",
                                        "reliability": "66",
                                        "guide_id": "s216185",
                                        "subtext": "POWTER - Bad Day",
                                        "genre_id": "g2754",
                                        "formats": "mp3",
                                        "playing": "POWTER - Bad Day",
                                        "item": "station",
                                        "image": "http://cdn-radiotime-logos.tunein.com/s216185q.png",
                                        "now_playing_id": "s216185",
                                        "preset_id": "s216185"
                                    ]
                            ],
                        ],
                        [
                            "element": "outline",
                            "text": "Shows",
                            "key": "shows",
                            "children":
                                [
                                    [
                                        "element": "outline",
                                        "type": "link",
                                        "text": "Absolute Radio 00s Podcasts",
                                        "URL": "http://opml.radiotime.com/Tune.ashx?c=pbrowse&id=p565418",
                                        "guide_id": "p565418",
                                        "subtext": "Hear the best interviews from Absolute Radio...",
                                        "genre_id": "g2754",
                                        "item": "show",
                                        "image": "http://cdn-radiotime-logos.tunein.com/p565418q.png",
                                        "current_track": "Hear the best interviews from Absolute Radio...",
                                        "preset_id": "p565418"
                                    ],
                                    [
                                        "element": "outline",
                                        "type": "link",
                                        "text": "Airplay 100 with Cristi Nitzu",
                                        "URL": "http://opml.radiotime.com/Tune.ashx?c=pbrowse&id=p632907",
                                        "guide_id": "p632907",
                                        "subtext": "Clasamentul celor mai difuzate 100 de hituri...",
                                        "genre_id": "g2754",
                                        "item": "show",
                                        "image": "http://cdn-radiotime-logos.tunein.com/p632907q.png",
                                        "current_track": "Clasamentul celor mai difuzate 100 de hituri...",
                                        "preset_id": "p632907"
                                    ]
                            ]
                        ]
                ]
        ]
    }
    

}

extension NSManagedObjectModel {
    
    static var testModel: NSManagedObjectModel {
        let bundle = Bundle(for: BaseTests.self)
        return NSManagedObjectModel.mergedModel(from: [bundle])!
    }
}
