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

    func emisorasJSON() -> JSONDictionary {
        return [
            "data": [
                [
                    "id": "1",
                    "first_name": "LRA 1",
                    "last_name": "Buenos Aires",
                    "web": "",
                    "urlfb": "https://www.facebook.com/NacionalAM870/",
                    "urltw": "https://twitter.com/NacionalAM870",
                    "urlstreaming1": "sa.mp3.icecast.magma.edge-access.net",
                    "urlstreaming2": "sb.mp3.icecast.magma.edge-access.net",
                    "puerto": "7200",
                    "am": "/sc_rad1",
                    "fm": "",
                    "dialAM": "AM870",
                    "dialFM": "",
                    "image": "LRA1.jpg"
                ],
                [
                    "id": "2",
                    "first_name": "LRA 337",
                    "last_name": "Nacional Cl\\u00e1sica",
                    "web": "",
                    "urlfb": "https://www.facebook.com/pages/Radio-Nacional-Cl%C3%A1sica-FM-967/118404581585464",
                    "urltw": "https://twitter.com/ClasicaNacional",
                    "urlstreaming1": "sa.mp3.icecast.magma.edge-access.net",
                    "urlstreaming2": "sb.mp3.icecast.magma.edge-access.net",
                    "puerto": "7200",
                    "am": "",
                    "fm": "/sc_rad37",
                    "dialAM": "",
                    "dialFM": "FM 96.7",
                    "image": "LRA337.jpg"
                ]
            ]
        ]
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
    
    func someCrashJSON() -> JSONDictionary {
        return 
            [
                "head": [
                    "title": "Buenos Aires",
                    "status": "200"
                ],
                "body": [[
                    "element": "outline",
                    "type": "audio",
                    "text": "FM Milenium",
                    "URL": "http://opml.radiotime.com/Tune.ashx?id=s26027&filter=g3",
                    "bitrate": "128",
                    "reliability": "91",
                    "guide_id": "s26027",
                    "subtext": "DE PUNTÃN",
                    "genre_id": "g3",
                    "formats": "mp3",
                    "show_id": "p1164466",
                    "item": "station",
                    "image": "http://cdn-profiles.tunein.com/s26027/images/logoq.jpg?t=154029",
                    "current_track": "DE PUNTÃN",
                    "now_playing_id": "s26027",
                    "preset_id": "s26027"
                    ],
                         [
                            "element": "outline",
                            "type": "audio",
                            "text": "Radio Cooperativa",
                            "URL": "http://opml.radiotime.com/Tune.ashx?id=s101604&filter=g3",
                            "bitrate": "64",
                            "reliability": "99",
                            "guide_id": "s101604",
                            "subtext": "Ultima Parada",
                            "genre_id": "g3",
                            "formats": "mp3",
                            "show_id": "p1001531",
                            "item": "station",
                            "image": "http://cdn-radiotime-logos.tunein.com/s101604q.png",
                            "current_track": "Ultima Parada",
                            "now_playing_id": "s101604",
                            "preset_id": "s101604"
                    ],
                         [
                            "element": "outline",
                            "type": "audio",
                            "text": "Radio FM Aire",
                            "URL": "http://opml.radiotime.com/Tune.ashx?id=s160002&filter=g3",
                            "bitrate": "32",
                            "reliability": "10",
                            "guide_id": "s160002",
                            "subtext": "TemÃ¡tico",
                            "genre_id": "g3",
                            "formats": "wma",
                            "show_id": "p409908",
                            "item": "station",
                            "image": "http://cdn-radiotime-logos.tunein.com/s160002q.png",
                            "current_track": "TemÃ¡tico",
                            "now_playing_id": "s160002",
                            "preset_id": "s160002"
                    ],
                         [
                            "element": "outline",
                            "type": "audio",
                            "text": "Radio Rebelde",
                            "URL": "http://opml.radiotime.com/Tune.ashx?id=s171847&filter=g3",
                            "bitrate": "24",
                            "reliability": "98",
                            "guide_id": "s171847",
                            "subtext": "Rebelde se nace, no se hace",
                            "genre_id": "g3",
                            "formats": "mp3",
                            "item": "station",
                            "image": "http://cdn-radiotime-logos.tunein.com/s171847q.png",
                            "now_playing_id": "s171847",
                            "preset_id": "s171847"
                    ],
                         [
                            "element": "outline",
                            "type": "audio",
                            "text": "RSC Radio",
                            "URL": "http://opml.radiotime.com/Tune.ashx?id=s137841&filter=g3",
                            "bitrate": "96",
                            "reliability": "100",
                            "guide_id": "s137841",
                            "subtext": "Te habla de cosas buenas",
                            "genre_id": "g3",
                            "formats": "mp3",
                            "item": "station",
                            "image": "http://cdn-radiotime-logos.tunein.com/s137841q.png",
                            "now_playing_id": "s137841",
                            "preset_id": "s137841"
                    ]
                ]
        ]
    }
    
    func navegarJSON() -> JSONDictionary {
        return [
            "body": [[
                "URL": "http://opml.radiotime.com/Browse.ashx?c=local",
                "element": "outline",
                "key": "local",
                "text": "Radio Local",
                "type": "link"
                ],
                     [
                        "URL": "http://opml.radiotime.com/Browse.ashx?c=music",
                        "element": "outline",
                        "key": "music",
                        "text": "M\\U00fasica",
                        "type": "link"
                ],
                     [
                        "URL": "http://opml.radiotime.com/Browse.ashx?c=talk",
                        "element": "outline",
                        "key": "talk",
                        "text": "Hablada",
                        "type": "link"
                ],
                     [
                        "URL": "http://opml.radiotime.com/Browse.ashx?c=sports",
                        "element": "outline",
                        "key": "sports",
                        "text": "Deportes",
                        "type": "link"
                ],
                     [
                        "URL": "http://opml.radiotime.com/Browse.ashx?id=r0",
                        "element": "outline",
                        "key": "location",
                        "text": "Por Ubicaci\\U00f3n",
                        "type": "link"
                ],
                     [
                        "URL": "http://opml.radiotime.com/Browse.ashx?c=lang",
                        "element": "outline",
                        "key": "language",
                        "text": "Por Idioma",
                        "type": "link"
                ],
                     [
                        "URL": "http://opml.radiotime.com/Browse.ashx?c=podcast",
                        "element": "outline",
                        "key": "podcast",
                        "text": "P\\U00f3dcast",
                        "type": "link"
                ]
            ],
            "head": [
                "status": 200,
                "title": "Navegar"
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
