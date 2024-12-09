//
//  ContentView.swift
//
//  Created by Ralf Kulik (c) 2024

import SwiftUI;
import CommonCrypto;
import UIKit;
import SwiftSoup

/* TODO
 * Auf der Tracklist Seite braucht es noch die Non-Contextmenüs Save Tracklist as Playlist und Clear Tracklist
 * Die List-spezifischen Commands auf den Tracklist-Elementen müssen noch für Radio und Tidal stimmen (müsste im Python eigentlich bereits gemacht worden sein)
 * Sonderzeichen wie ! oder ' in Songtiteln beim getLyrics beachten (Roxette: Crash-boom-bang), da fehlen noch diverse
 ** Runde Klammern wie bei shine one your crazy diamond (part 1)
 * Wenn der ActivePlayer von "extern" geändert wird, kriegt das die App nicht mit
 * Lyrics Page muss sich bei Song Wechsel noch selbst updaten, ebenso die Seite 2 mit der Playlist
 * Man müsste noch Links zu Band in Playlist etc. einbauen
 * Genre?
 * Wiki Links adden
 * Evtl. Edit Song/Genre Detail Page wie hier https://bugfender.com/blog/swiftui-lists/
 * Evtl. Swipe-Geste auf Track Image zum Forward-Next/Prev -> ist begonnen
 * IP noch initial lesen. Im Python Code hat es evtl eine coole URL mit localhost/Burmi o.ä. (wobei der nicht funktioniert)
 * Die ganze Playlist Edit Geschichte fehlt noch
 * Eine vernünftige Suche nach Songs etc. wäre cool
 * Auf der ActiveTrack-Seite: Was wäre das Resultat von Swipe Up/Down
 * Man müsste auf MVC/MVMM umstellen: https://www.netguru.com/blog/mvc-vs-mvvm-on-ios-differences-with-examples#:~:text=Model%2DView%2DController%20(MVC,fit%20for%20your%20next%20project.
*/


struct ContentView: View {
    //
    // Page Nbr to be displayed
    //   1 = Player with active Track
    //   2 = TrackList with Tracks/Stations
    //   3 = Lyrics
    @State var PAGE_NBR: Int8
    // True if Burmi is online, otherwise False
    @State var IS_BURMI_ON: Bool
    // Name of the player:
    //   "Radio"                -> Radio
    //   "Linionik Pipe Player" -> CD
    //   "WiMP Player"          -> TIDAL
    @State var PLAYER: String
    // True if currently a track is being played, otherwise False
    // (irrespective of the play mode cd, tidal etc)
    @State var IS_TRACK_PLAYING: Bool
    // True if player is currently in shuffle mode
    @State var IS_MODE_SHUFFLE: Bool
    // True if player is currently in repeate mode
    @State var IS_MODE_REPEAT: Bool
    // Name of the currently active track
    @State var ACTIVE_TRACK: String
    // Name of the currently active artist
    @State var ACTIVE_ARTIST: String
    // Name of the currently active album
    @State var ACTIVE_ALBUM: String
    // URL for cover info for the currently active track
    @State var ACTIVE_COVER_URL: String
    // List of tracks / stations in the active playlist
    @State var TRACKS: [Track]
    // Lyrics of the currently played track
    @State var LYRICS: String
    // Upates the UI every 3 sec., Source: https://maheshsai252.medium.com/updating-swiftui-view-for-every-x-seconds-559360ce3b4a
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    /*
    // TODO Ralf
    // Save und clear tracklist noch implementieren
    // Lyrics wohl bei Radio disablen, Lyrics wird bei Songwechsel nicht nachgeführt
    // In der Tracklist (Seite 2) noch den aktiv gespielten Track andersfarbig hinterlegen
    // Das Player Icon (CD etc.) wird initial nicht nachgeführt
    // Die Icons müsste es noch in einer ausgegraut Version (inactive) geben (für Burmi Off/No Player)
    // Create a swipe gesture recognizer
    let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))

    // Set the direction of the swipe (e.g., right)
    swipeGesture.direction = .right

    // Add the gesture recognizer to a view
    yourView.addGestureRecognizer(swipeGesture)

    // Handle the swipe gesture
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        // Perform the desired action based on the swipe direction
        if sender.direction == .right {
            // Handle right swipe
        }
    }
    */
    
    // Initializes the various state variables
    // Source https://stackoverflow.com/questions/56691630/swiftui-state-var-initialization-issue
    init () {
        var pageNbr: Int8
        var isBurmiOn: Bool
        var isTrackPlaying: Bool
        var isShuffle: Bool
        var isRepeat: Bool
        var player: String
        var track: String
        var album: String
        var artist: String
        var coverURL: String
        var tracks: [Track]
        var lyrics: String
        pageNbr = 1
        player = "Linionik Pipe Player" // CD
        lyrics =  ""
        _PAGE_NBR = State(initialValue: pageNbr)
        _PLAYER = State(initialValue: player)
        (isBurmiOn, track, artist, album, coverURL) = retrieveTrackInfo()
        _IS_BURMI_ON = State(initialValue: isBurmiOn)
        _ACTIVE_TRACK = State(initialValue: track)
        _ACTIVE_ARTIST = State(initialValue: artist)
        _ACTIVE_ALBUM = State(initialValue: album)
        _ACTIVE_COVER_URL = State(initialValue: coverURL)
        (isBurmiOn, isTrackPlaying, isShuffle, isRepeat) = retrievePlayerInfo()
        _IS_BURMI_ON = State(initialValue: isBurmiOn)
        _IS_TRACK_PLAYING = State(initialValue: isTrackPlaying)
        _IS_MODE_SHUFFLE = State(initialValue: isShuffle)
        _IS_MODE_REPEAT = State(initialValue: isRepeat)
        tracks = retrieveTrackList(player: player)
        _TRACKS = State(initialValue: tracks)
        _LYRICS = State(initialValue: lyrics)
    }
    
    var body: some View {
        if PAGE_NBR == 1 {
            // Page Nbr 1 - Track Details
            VStack {
                HStack {
                    Button(action: {
                        if (IS_BURMI_ON) {
                            PLAYER = "Linionik Pipe Player"
                            setPlayer(player: "Linionik Pipe Player")
                            sleep(2)
                            (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                            TRACKS = retrieveTrackList(player: PLAYER)
                        }
                    })
                    {
                        Image(systemName: PLAYER == "Linionik Pipe Player" ? "opticaldisc.fill" : "opticaldisc")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.height / 25, height: UIScreen.main.bounds.height / 25)
                    }
                    Button(action: {
                        if (IS_BURMI_ON) {
                            PLAYER = "Radio"
                            setPlayer(player: "Radio")
                            sleep(1)
                            (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                            TRACKS = retrieveTrackList(player: PLAYER)
                        }
                    })
                    {
                        Image(systemName: PLAYER == "Radio" ? "radio.fill" : "radio")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.height / 25, height: UIScreen.main.bounds.height / 25)
                    }
                    Button(action: {
                        if (IS_BURMI_ON) {
                            PLAYER = "WiMP Player"
                            setPlayer(player: "WiMP Player")
                            sleep(1)
                            (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                            TRACKS = retrieveTrackList(player: PLAYER)
                        }
                    }) {
                        Image(systemName: PLAYER == "WiMP Player" ? "icloud.and.arrow.down.fill" : "icloud.and.arrow.down")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.height / 25, height: UIScreen.main.bounds.height / 25)
                    }
                }
                Spacer()
                HStack {
                    Button(action: {
                        if (IS_BURMI_ON) {
                            trackPrevious()
                            // TODO Ralf. Geht das irgendwie besser
                            sleep(1)
                            (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                            (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                        }
                    }) {
                        Image(systemName: IS_BURMI_ON ? "backward.circle.fill" : "backward.circle")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.height / 25, height: UIScreen.main.bounds.height / 25)
                    }
                    Button(action: {
                        if (IS_BURMI_ON) {
                            trackPlayOrPause(isTrackPlaying: !(IS_TRACK_PLAYING))
                            sleep(1)
                            (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                            (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                        }
                    }) {
                        Image(systemName: IS_BURMI_ON ? (IS_TRACK_PLAYING ? "pause.circle" : "play.circle.fill") : "play.circle")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.height / 25, height: UIScreen.main.bounds.height / 25)
                    }
                    Button(action: {
                        if (IS_BURMI_ON) {
                            trackStop()
                            sleep(1)
                            (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                            (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                        }
                    }
                    ) {
                        Image(systemName: IS_BURMI_ON ? "stop.circle.fill" : "stop.circle")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.height / 25, height: UIScreen.main.bounds.height / 25)
                    }
                    Button(action: {
                        if (IS_BURMI_ON) {
                            trackNext()
                            sleep(1)
                            (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                            (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                        }
                    }) {
                        Image(systemName: IS_BURMI_ON ? "forward.circle.fill" : "forward.circle")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.height / 25, height: UIScreen.main.bounds.height / 25)
                    }
                }
                HStack {
                    Button(action: {
                        if (IS_BURMI_ON) {
                            toggleRepeat(isModeRepeat: IS_MODE_REPEAT)
                            (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                            (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                        }
                    }) {
                        Image(systemName: IS_MODE_REPEAT ? "repeat.circle.fill" : "repeat.circle")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.height / 40, height: UIScreen.main.bounds.height / 40)
                    }
                    Button(action: {
                        if (IS_BURMI_ON) {
                            toggleShuffle(isModeShuffle: IS_MODE_SHUFFLE)
                            (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                            (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                        }
                    }) {
                        Image(systemName: IS_MODE_SHUFFLE ? "shuffle.circle.fill" : "shuffle.circle")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.height / 40, height: UIScreen.main.bounds.height / 40)
                    }
                }
                Spacer()
                VStack{
                    AsyncImage(url: URL(string: ACTIVE_COVER_URL)){ result in
                        result.image?
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.height / 4, height: UIScreen.main.bounds.height / 4)
                    }
                    // TODO Ralf
                    .onTapGesture {print("Tapped on Image")}
                    // https://stackoverflow.com/questions/60885532/how-to-detect-swiping-up-down-left-and-right-with-swiftui-on-a-view
                    .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                        .onEnded { value in
                            print(value.translation)
                            switch(value.translation.width, value.translation.height) {
                            case (...0, -100...100):  trackNext()     // left swipre
                            case (0..., -100...10):  trackPrevious() // right swipe
                            case (-100...100, ...0):  print("up swipe")
                            case (-100...100, 0...):  print("down swipe")
                            default:  print("no clue")
                            }
                        }
                    )
                }
                Spacer()
                VStack{
                    Text(ACTIVE_TRACK)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ACTIVE_ARTIST)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ACTIVE_ALBUM)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                HStack {
                    Button(action: {
                        PAGE_NBR = 1
                    }) {
                        Image(systemName: (PAGE_NBR == 1) ? "circle.fill" : "circle")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    Button(action: {
                        PAGE_NBR = 2
                    }) {
                        Image(systemName: (PAGE_NBR == 2) ? "circle.fill" : "circle")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    Button(action: {
                        PAGE_NBR = 3
                    }) {
                        Image(systemName: (PAGE_NBR == 3) ? "circle.fill" : "circle")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                }
            }.onReceive(timer, perform: { _ in
                print("Self-Update Page 1")
                //print("bounds h:" + UIScreen.main.bounds.height.description)
                //print("bounds w:" + UIScreen.main.bounds.width.description)
                (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
            })
            // END Page Nbr 1
        }
        if PAGE_NBR == 2 {
            // PAGE Nbr 2 - Track List
            HStack {
                VStack {
                    Text(PLAYER == "Radio" ? "Stations" : "Tracks").font(.headline).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity, alignment: .center)
                Menu("...") {
                    Button("Save", systemImage: "square.and.arrow.down.fill", action: {
                        print("Noch nicht implementiert")
                        // TODO Ralf codieren
                        //moveTrackTop(rowIndex: track.counter, player: PLAYER)
                        //TRACKS = retrieveTrackList(player: PLAYER)
                    })
                    Button("Delete", systemImage: "trash", action: {
                        print("Noch nicht implementiert")
                           // TODO Ralf codieren
                           //moveTrackUp(rowIndex: track.counter, player: PLAYER)
                           //TRACKS = retrieveTrackList(player: PLAYER)
                   })
                }
            }
            VStack {
                List(TRACKS, id: \.uniqueID) { track in
                    HStack {
                        AsyncImage(url: URL(string: track.imageURL)){ result in
                            result.image?
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.height / 25, height: UIScreen.main.bounds.height / 25)
                        }
                        .onTapGesture {
                            playTrackIndex(player: PLAYER, trackIndex: track.counter)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                                Text(track.title)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                Text(track.artist)
                                    .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            playTrackIndex(player: PLAYER, trackIndex: track.counter)
                            (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                            TRACKS = retrieveTrackList(player: PLAYER)
                            LYRICS = retrieveLyrics(artist: ACTIVE_ARTIST, title: ACTIVE_TRACK)
                        }
                        Spacer()
                        Menu("...") {
                            Button("Top", systemImage: "arrow.up.to.line", action: {
                                moveTrackTop(rowIndex: track.counter, player: PLAYER)
                                TRACKS = retrieveTrackList(player: PLAYER)
                            })
                            Button("Up", systemImage: "arrow.up", action: {
                                moveTrackUp(rowIndex: track.counter, player: PLAYER)
                                TRACKS = retrieveTrackList(player: PLAYER)
                            })
                            Button("Down", systemImage: "arrow.down", action: {
                                moveTrackDown(rowIndex: track.counter, nbrTracks: TRACKS.count, player: PLAYER)
                                TRACKS = retrieveTrackList(player: PLAYER)
                            })
                            Button("Bottom", systemImage: "arrow.down.to.line", action: {
                                moveTrackBottom(rowIndex: track.counter, nbrTracks: TRACKS.count, player: PLAYER)
                                TRACKS = retrieveTrackList(player: PLAYER)
                            })
                            Divider()
                            Button("Remove", systemImage: "trash", action: {
                                removeTrack(rowIndex: track.counter, player: PLAYER)
                                TRACKS = retrieveTrackList(player: PLAYER)
                            })
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
            HStack {
                Button(action: {
                    PAGE_NBR = 1
                }) {
                    Image(systemName: (PAGE_NBR == 1) ? "circle.fill" : "circle")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                Button(action: {
                    PAGE_NBR = 2
                }) {
                    Image(systemName: (PAGE_NBR == 2) ? "circle.fill" : "circle")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                Button(action: {
                    PAGE_NBR = 3
                }) {
                    Image(systemName: (PAGE_NBR == 3) ? "circle.fill" : "circle")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
            }.onReceive(timer, perform: { _ in
                print("Self-Update Page 2")
                (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
            })
            // END Page Nbr 2
        }
        if PAGE_NBR == 3 {
            // PAGE Nbr 3 - Lyrics
            Text("Lyrics   (by Genius.com)").font(.headline)
            VStack {
                ScrollView {
                    Text(LYRICS).onAppear() {
                        LYRICS = retrieveLyrics(artist: ACTIVE_ARTIST, title: ACTIVE_TRACK)
                    }
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxHeight: .infinity)
                }
            }
            HStack {
                Button(action: {
                    PAGE_NBR = 1
                }) {
                    Image(systemName: (PAGE_NBR == 1) ? "circle.fill" : "circle")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                Button(action: {
                    PAGE_NBR = 2
                }) {
                    Image(systemName: (PAGE_NBR == 2) ? "circle.fill" : "circle")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                Button(action: {
                    PAGE_NBR = 3
                }) {
                    Image(systemName: (PAGE_NBR == 3) ? "circle.fill" : "circle")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
            }.onReceive(timer, perform: { _ in
                print("Self-Update Page 3")
                (IS_BURMI_ON, ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                LYRICS = retrieveLyrics(artist: ACTIVE_ARTIST, title: ACTIVE_TRACK)
            })
            // END Page Nbr 3
        }
    }
}
//
// Timeout in Milliseconds for normal (quick) operations when communicating with Burmi
let TIMEOUT_NORM_MS = 100
// Timeout in Milliseconds for long (slow) operations when communicating with Burmi
let TIMEOUT_LONG_MS = 5000
//
// IP under which the Burmi device is accessible
let IP = "192.168.1.106"  // es war auch schon mal 115
//let IP = "musiccenter151.local" -> gibt nur die HTML Seite zurück, aber keine Info über die IP Adresse


 
// TODO Document
func setPlayer(player: String) {
    // TODO hier nicht den n'ten Song hartcodieren - moment hartcodiert 5 (wobei, woher weiss man den letzten Zustand
    let cmd = "{\"Media_Obj\" : \"" + player  + "\", \"AudioControl\" : { \"Method\" : \"PlaySongIdx\", \"Parameters\" :  5 }}"
    _ = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
}
//
// Plays for the given player the given track
func playTrackIndex(player: String, trackIndex: Int) {
    let cmd = "{\"Media_Obj\" : \"" + player  + "\", \"AudioControl\" : { \"Method\" : \"PlaySongIdx\", \"Parameters\" :  " + String(trackIndex) + " }}"
    _ = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
}
//
// Retrieves information about the current play mode
func retrievePlayerInfo() -> (isBurmiOn: Bool, isTrackPlaying: Bool, isShuffle: Bool, isRepeat: Bool) {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\", \"Method\" : \"ActiveInputCmd\", \"Parameters\" : { \"AudioGetInfo\" : { \"Method\" : \"GetPlayState\"}}}"
    let resp = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
    if (resp.count == 0) {
        // Burmi is off
        return (false, false, false, false)
    } else if (resp["Media_Obj"] as! String == "DefaultZeroPlayer") {
        // Burmi is on, but no player is active
        return (true, false, false, false)
    } else if (resp["Media_Obj"] as! String == "Radio") {
        // Radio is active, Radio does not offer Shuffle/Repeat
        return (true, (resp["PlayState"] as! String == "Play"), false, false)
    } else {
        // CD/Tidal is Active
        return (true, (resp["PlayState"] as! String == "Play"), (resp["Shuffle"] as! Bool), (resp["Repeat"] as! Bool))
    }
}
//
// Retrieves information about the currently active track/station
func retrieveTrackInfo() -> (isBurmiOn: Bool, title: String, artist: String, album: String, coverUrl: String) {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioGetInfo\" : {\"Method\" : \"GetCurrentSongInfo\"}}}"
    let resp = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
    if (resp.count == 0) {
        // Burmi is off
        return (false, "", "", "", "")
    } else if (resp["Media_Obj"] as! String == "DefaultZeroPlayer") {
        // Burmi is on, but no player is active
        return (true, "", "", "", "")
    }
    let jsonSongInfo = resp["SongInfo"] as! [String:Any]
    let jsonSongDictionary = resp["SongDictionary"] as! [String:Any]
    var title: String = ""
    var artist: String = ""
    var album: String = ""
    var coverUrl: String = ""
    title = (jsonSongInfo["Title"] as! String)
    coverUrl = (jsonSongDictionary["Cover"] as! String)
    artist = (jsonSongInfo["Artist"] as! String)
    if (resp["InputName"] as! String == "Linionik Pipe Player") {
        // CD
        album = (jsonSongInfo["Album"] as! String)
    } else if (resp["InputName"] as! String == "Radio") {
        // Radio
        artist = (jsonSongDictionary["Album"] as! String)
        artist = artist.replacingOccurrences(of:", " + (jsonSongDictionary["AudioInfo"] as! String), with:(""))
        album = "" // TODO Ralf können wir hier was anderes holen??
    } else if (resp["InputName"] as! String == "WiMP Player") {
        // Tidal
        album = (jsonSongInfo["Album"] as! String)
    }
    // TODO Ralf Fehlerbehandlung unbekannter Player fehlt noch
    return (true, title, artist, album, coverUrl)
}
//
// Retrieves Tracklist (List of tracks (or radio stations) in the currently active Track-List/StationList)
func retrieveTrackList(player: String) -> ([Track]) {
    if (player.isEmpty) {
        // Burmi off or no player active
        return []
    }
    var cmd = "{\"Media_Obj\" : \"xxxx\", \"AudioPlayList\" : {\"Method\" : \"GetPlayList\"}}"
    cmd = cmd.replacingOccurrences(of:"xxxx", with:player)
    let resp = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_LONG_MS)
    let jsonPlayListElements = (resp["PlayList"] as? [Dictionary<String, AnyObject>])
    var retValue: [Track] = []
    for i in 0..<jsonPlayListElements!.count {
        if (player == "Radio") {
            var artist = (jsonPlayListElements![i]["Album"] as! String)
            artist = artist.replacingOccurrences(of:", " + (jsonPlayListElements![i]["AudioInfo"] as! String), with:(""))
            retValue.append(Track(uniqueID: jsonPlayListElements![i]["SongID"] as! String, counter: i, title: artist, artist: jsonPlayListElements![i]["Genre"] as! String, imageURL: jsonPlayListElements![i]["Cover"] as! String))
        } else  {
            // CD / Tidal
            retValue.append(Track(uniqueID: jsonPlayListElements![i]["SongID"] as! String, counter: i, title: jsonPlayListElements![i]["Title"] as! String, artist: jsonPlayListElements![i]["TrackArtist"] as! String, imageURL: jsonPlayListElements![i]["Cover"] as! String))
        }
        
    }
    return retValue
}
//
// Starts or pauses playing of a currently active track
func trackPlayOrPause(isTrackPlaying: Bool) {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"" +  (isTrackPlaying ? "Play" : "Pause") + "\"}}}"
    _ = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
}
//
// Moves to the next played track
func trackNext() {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"SkipForward\"}}}"
    _ = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
}
//
// Moves to the previous played track
func trackPrevious() {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"BackForward\"}}}"
    _ =  executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
}
//
// Stops playing any track
func trackStop() {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"Stop\"}}}"
    _ = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
}
//
// Toggles the repeat mode
func toggleRepeat(isModeRepeat: Bool)  {
    var cmd = "{\"Media_Obj\" : \"ActiveInput\", \"Method\" : \"ActiveInputCmd\", \"Parameters\" : {\"AudioControl\" : {\"Method\" : \"SetRepeat\", \"Parameters\" :  xxxx}}}"
    cmd = cmd.replacingOccurrences(of:"xxxx", with:(isModeRepeat ? "false" : "true"))
    _ = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
}
//
// Toggles the shuffle mode
func toggleShuffle(isModeShuffle: Bool) {
    var cmd = "{\"Media_Obj\" : \"ActiveInput\", \"Method\" : \"ActiveInputCmd\", \"Parameters\" : {\"AudioControl\" : {\"Method\" : \"SetShuffle\", \"Parameters\" :  xxxx}}}"
    cmd = cmd.replacingOccurrences(of:"xxxx", with:(isModeShuffle ? "false" : "true"))
    _ = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
}
//
// Moves the given track to the top of the tracklist
func moveTrackTop(rowIndex: Int, player: String) {
    moveTrack(rowIndexStart: rowIndex, rowIndexEnd: 0, player: player)
}
//
// Moves the given track one element up
func moveTrackUp(rowIndex: Int, player: String) {
    if (rowIndex > 0) {
        moveTrack(rowIndexStart: rowIndex, rowIndexEnd: rowIndex - 1, player: player)
    }
}
//
// Moves the given track one down
func moveTrackDown(rowIndex: Int, nbrTracks: Int, player: String) {
    if (rowIndex + 1 < nbrTracks) {
        moveTrack(rowIndexStart: rowIndex, rowIndexEnd: rowIndex + 1, player: player)
    }
}
//
// Moves the given track to the bottom of the tracklist
func moveTrackBottom(rowIndex: Int, nbrTracks: Int, player: String) {
    moveTrack(rowIndexStart: rowIndex, rowIndexEnd: nbrTracks - 1, player: player)
}
//
// Helper to move tracks within the tracklist
func moveTrack(rowIndexStart: Int, rowIndexEnd: Int, player: String) {
    // TODO Ralf Fehlt noch für Tidal und für Radio
    var cmd = "{\"Media_Obj\" : \"zzzz\", \"AudioPlayList\" : {\"Method\" : \"MoveSong\", \"Parameters\" : {\"Source\" : xxxx, \"Destination\" : yyyy}}}"
    cmd = cmd.replacingOccurrences(of:"xxxx", with:String(rowIndexStart))
    cmd = cmd.replacingOccurrences(of:"yyyy", with:String(rowIndexEnd))
    cmd = cmd.replacingOccurrences(of:"zzzz", with:player)
    _ = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
}
// Removes the given track from the tracklist
func removeTrack(rowIndex: Int, player: String) {
    var cmd = "{\"Media_Obj\" : \"zzzz\", \"AudioPlayList\" : {\"Method\" : \"RemoveSongs\", \"Parameters\" : [xxxx]}}"
    cmd = cmd.replacingOccurrences(of:"xxxx", with:String(rowIndex))
    cmd = cmd.replacingOccurrences(of:"zzzz", with:player)
    _ = executeBurmiHttpRequest(cmd: cmd, timeout: TIMEOUT_NORM_MS)
}
//
// Retrieves the lyrics of the given song from Genius, if it exists
func retrieveLyrics(artist: String, title: String) -> String {
    // Example: https://genius.com/Die-toten-hosen-hier-kommt-alex-lyrics
    var artistUrl = artist.replacingOccurrences(of:"[ /]", with:"-", options: [.regularExpression]).lowercased()
    artistUrl = artistUrl.replacingOccurrences(of:" + ", with:"-").lowercased()
    artistUrl = artistUrl.replacingOccurrences(of:"[.'!]", with:"", options: [.regularExpression])
    let firstLetter = artistUrl.prefix(1).capitalized
    let remainingLetters = artistUrl.dropFirst().lowercased()
    var titleUrl = title.replacingOccurrences(of:" ", with:"-").lowercased()
    titleUrl = titleUrl.replacingOccurrences(of:"[!+.']", with:"", options: [.regularExpression])
    let url = "https://genius.com/" + firstLetter + remainingLetters + "-" + titleUrl + "-lyrics"
    let resp = executeGenericHttpRequest(url: url, timeout: TIMEOUT_NORM_MS)
    print("url for lyrics: " + url  )
    do {
        let doc: Document = try SwiftSoup.parse(resp)
        var retValue = ""
        let lyricContainers : Elements = try doc.select("div[data-lyrics-container=\"true\"]")
        for lyricContainer in lyricContainers {
            retValue = try retValue + lyricContainer.html()
        }
        retValue = retValue.replacingOccurrences(of:"<br />", with:"\n")
        // Remove all <SPAN>..</SPAN> tags, but not the values in between
        retValue = retValue.replacingOccurrences(of:"<span[^>]*>", with:"", options: [.regularExpression])
        retValue = retValue.replacingOccurrences(of:"</span>", with:"")
        // Remove all <A>..</A> tags, but not the values in between
        retValue = retValue.replacingOccurrences(of:"<a[^>]*>", with:"", options: [.regularExpression])
        retValue = retValue.replacingOccurrences(of:"</a>", with:"")
        // Remove all <I>..</I> tags, but not the values in between
        retValue = retValue.replacingOccurrences(of:"<i[^>]*>", with:"", options: [.regularExpression])
        retValue = retValue.replacingOccurrences(of:"</i>", with:"")
        // Remove all <DIV>..</DIV> tags, but not the values in between
        retValue = retValue.replacingOccurrences(of:"<div[^>]*>", with:"", options: [.regularExpression])
        retValue = retValue.replacingOccurrences(of:"</div>", with:"")
        // Remove all <SVG>..</SVG> tags, but not the values in between
        retValue = retValue.replacingOccurrences(of:"<svg[^>]*>", with:"", options: [.regularExpression])
        retValue = retValue.replacingOccurrences(of:"</svg>", with:"")
        // Remove all <PATH>..</PATH> tags, but not the values in between
        retValue = retValue.replacingOccurrences(of:"<path[^>]*>", with:"", options: [.regularExpression])
        retValue = retValue.replacingOccurrences(of:"</path>", with:"")
        // Replace multiple CRLF with single ones
        retValue = retValue.replacingOccurrences(of:"\n*\n", with:"\n", options: [.regularExpression])
        // Add an empty line before headings
        retValue = retValue.replacingOccurrences(of:"[", with:"\n[")
        return retValue
    } catch {
        return ""
    }
}
//
// Encodes the given URL and returns the result
func getEncodedURL(url: String) -> String {
    var retValue = url
    let charsAndEncodings = ["\"" : "%22", "," : "%2C", ":" : "%3A", "{" : "%7B", "}" : "%7D", " " : "%20"]
    for (key, val) in charsAndEncodings {
        retValue = retValue.replacingOccurrences(of:key, with:val)
    }
    return retValue
}
//
// Helper to create a SHA1 string - needed for Burmi authorization
// Source: https://stackoverflow.com/questions/25761344/how-to-hash-nsstring-with-sha1-in-swift
extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}
// TODO Ralf: Das braucht es zwar, ist aber evtl. noch nicht genieal?
// Source: https://stackoverflow.com/questions/26784315/can-i-somehow-do-a-synchronous-http-request-via-nsurlsession-in-swift
extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest, timeout: Int) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()
        _ = semaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.milliseconds(timeout))

        return (data, response, error)
    }
}

// TODO Ralf: Dies sollte die synchrone Extension nutzen
func executeGenericHttpRequest(url: String, timeout: Int) -> (String) {
    guard let myURL = URL(string: url) else {
        print("Error: \(url) doesn't seem to be a valid URL")
        return ""
    }

    do {
        let myHTMLString = try String(contentsOf: myURL, encoding: .utf8)
        //print("HTML : \(myHTMLString)")
        return myHTMLString
    } catch let error {
        print("Error: \(error)")
        return ""
    }
}

// TODO Document, noch etwas clean-up
func executeBurmiHttpRequest(cmd: String, timeout: Int) -> (Dictionary<String, AnyObject>) {
    let encodedCmd = getEncodedURL(url: cmd)
    let authString = "Linionik_HTML5" + cmd + "#_Linionik_6_!HTML5!#_Linionik_2012"
    let authStringHash = authString.sha1()
    // Prefix of URL (part directly after the IP/Host)
    let URL_PRE = "/json.php?Json=Linionik_HTML5_[MC_JSON]_"
    // Suffix of URL (part directly before the param)
    let URL_SUF = "_[MC_JSON]_"
    let urlString = "http://" + IP + URL_PRE + authStringHash + URL_SUF + encodedCmd;
    //print("urlString: " + urlString)
    // Initialize return value
    var json = [String: AnyObject]()
    // Initialize HTTP Request
    var request = URLRequest(url: URL(string: urlString)!)
    request.httpMethod = "GET"
    let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request, timeout: timeout)
    if let error = error {
        print("Synchronous task ended with error: \(error)")
    } else {
      if data != nil {
            do {
                json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                
            } catch {
                print("error, kann JSON Data nicht konvertieren")
            }
        } else{
            print("error, keine Daten erhalten")}
    }
    return json
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Data Structure for a track in the track list
// TODO Ralf: könnte eigentlich auch für die Detailseite verwendet werden (anstatt einzelner Variablen wie artist)
struct Track {
    var uniqueID : String
    var counter: Int    // Position of track in list (1 = topmost)
    var title: String
    var artist: String
    var imageURL: String
}
