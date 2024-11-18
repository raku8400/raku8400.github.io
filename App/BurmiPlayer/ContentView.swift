//
//  ContentView.swift
//
//  Created by Ralf Kulik (c) 2024

import SwiftUI;
import CommonCrypto;

/* TODO
 * Self-Refresh alle X Sek
 * Irgendwie muss man noch auf die State-Attribute von aussen zugreifen können?
 * IP noch initial lesen. Im Python Code hat es evtl eine coole URL mit localhost/Burmi o.ä.
 * Wiki-Links noch einfügen
 * Man müsste auf MVC/MVMM umstellen: https://www.netguru.com/blog/mvc-vs-mvvm-on-ios-differences-with-examples#:~:text=Model%2DView%2DController%20(MVC,fit%20for%20your%20next%20project.
*/


struct ContentView: View {
    
    // True if Burmi is online, otherwise False
    @State var IS_BURMI_ON: Bool
    // True if currently a song is being played (irrespective of the play mode cd, tidal etc), otherwise False
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
    
    // Initializes the various state variables
    // Source https://stackoverflow.com/questions/56691630/swiftui-state-var-initialization-issue
    init () {
        var isBurmiOn: Bool
        var isTrackPlaying: Bool
        var isShuffle: Bool
        var isRepeat: Bool
        var track: String
        var album: String
        var artist: String
        var coverURL: String
        (track, artist, album, coverURL) = retrieveTrackInfo()
        _ACTIVE_TRACK = State(initialValue: track)
        _ACTIVE_ARTIST = State(initialValue: artist)
        _ACTIVE_ALBUM = State(initialValue: album)
        _ACTIVE_COVER_URL = State(initialValue: coverURL)
        (isBurmiOn, isTrackPlaying, isShuffle, isRepeat) = retrievePlayerInfo()
        _IS_BURMI_ON = State(initialValue: isBurmiOn)
        _IS_TRACK_PLAYING = State(initialValue: isTrackPlaying)
        _IS_MODE_SHUFFLE = State(initialValue: isShuffle)
        _IS_MODE_REPEAT = State(initialValue: isRepeat)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    trackPrevious()
                    // TODO Ralf. Geht das irgendwie besser
                    sleep(1)
                    (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                    print("IS_MODE_SHUFFLE" + String(IS_MODE_SHUFFLE))
                    (ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                }) {
                    Image(IS_BURMI_ON ? "Play_PreviousActive" : "Play_PreviousInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
                Button(action: {
                    trackPlayOrPause(isTrackPlaying: !(IS_TRACK_PLAYING))
                    sleep(1)
                    (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                    (self.ACTIVE_TRACK, self.ACTIVE_ARTIST, self.ACTIVE_ALBUM, self.ACTIVE_COVER_URL) = retrieveTrackInfo()
                }) {
                    Image(IS_BURMI_ON ? (IS_TRACK_PLAYING ? "Play_PauseActive" : "Play_PlayActive") : "Play_PlayInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
                Button(action: {
                    trackStop()
                    sleep(1)
                    (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                    (ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                }) {
                    Image(IS_BURMI_ON ? "Play_StopActive" : "Play_StopInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
                Button(action: {
                    trackNext()
                    sleep(1)
                    (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                    (ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                }) {
                    Image(IS_BURMI_ON ? "Play_NextActive" : "Play_NextInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
            }
            HStack {
                Button(action: {
                    toggleRepeat(isModeRepeat: IS_MODE_REPEAT)
                    //sleep(1)
                    (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                    (ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                    //logState(isBurmiOn: IS_BURMI_ON, isTrackPlaying: IS_TRACK_PLAYING, isShuffle: IS_MODE_SHUFFLE, isRepeat: IS_MODE_REPEAT)
                }) {
                    Image(IS_MODE_REPEAT ? "RepeatActive" : "RepeatInActive")
                        .resizable()
                        .frame(width: 34, height: 34)
                }
                Button(action: {
                    toggleShuffle(isModeShuffle: IS_MODE_SHUFFLE)
                    //sleep(1)
                    (IS_BURMI_ON, IS_TRACK_PLAYING, IS_MODE_SHUFFLE, IS_MODE_REPEAT) = retrievePlayerInfo()
                    (ACTIVE_TRACK, ACTIVE_ARTIST, ACTIVE_ALBUM, ACTIVE_COVER_URL) = retrieveTrackInfo()
                    //logState(isBurmiOn: IS_BURMI_ON, isTrackPlaying: IS_TRACK_PLAYING, isShuffle: IS_MODE_SHUFFLE, isRepeat: IS_MODE_REPEAT)
                }) {
                    Image(IS_MODE_SHUFFLE ? "ShuffleActive" : "ShuffleInActive")
                        .resizable()
                        .frame(width: 34, height: 34)
                }
            }
            Spacer()
            VStack{
            AsyncImage(url: URL(string: ACTIVE_COVER_URL))
               .frame(width: 160, height: 160)
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
        }}
}

let IP = "192.168.1.106"

/*
func logState(isBurmiOn: Bool, isTrackPlaying: Bool, isShuffle: Bool, isRepeat: Bool) {
    let msg = "Burmi On: " + String(isBurmiOn) + ", Track Playing: " + String(isTrackPlaying) + ", Shuffle: " + String(isShuffle) + ", Repeat: " + String(isRepeat)
    print(msg)
}
 */
 
// Retrieves information about the current play mode
// TODO Ralf Player noch ergänzen (Radio/CD/Tidal/NONE)
func retrievePlayerInfo() -> (isBurmiOn: Bool, isTrackPlaying: Bool, isShuffle: Bool, isRepeat: Bool) {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\", \"Method\" : \"ActiveInputCmd\", \"Parameters\" : { \"AudioGetInfo\" : { \"Method\" : \"GetPlayState\"}}}"
    let resp = executeGetRequest(cmd: cmd)
    return (true, (resp["PlayState"] as! String == "Play"), (resp["Shuffle"] as! Bool), (resp["Repeat"] as! Bool))
    /*
    {"BufferLevel":100,"EffectFilter":-1,"InputName":"Linionik Pipe Player","Media_Obj":"Linionik Pipe Player","PlayState":"Play","Repeat":false,"Result":["OK"],"Shuffle":false}
     */
}
//
// Retrieves information about the currently active track
func retrieveTrackInfo() -> (title: String, artist: String, album: String, coverUrl: String) {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioGetInfo\" : {\"Method\" : \"GetCurrentSongInfo\"}}}"
    let resp = executeGetRequest(cmd: cmd)
    let jsonSongInfo = resp["SongInfo"] as! [String:Any]
    let jsonSongDictionary = resp["SongDictionary"] as! [String:Any]
    return ((jsonSongInfo["Title"] as! String), (jsonSongInfo["Artist"] as! String), (jsonSongInfo["Album"] as! String), (jsonSongDictionary["Cover"] as! String))
  
}
//
// Starts or pauses playing of a currently active track
func trackPlayOrPause(isTrackPlaying: Bool) {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"" +  (isTrackPlaying ? "Play" : "Pause") + "\"}}}"
    _ = executeGetRequest(cmd: cmd)
}
//
// Moves to the next played track
func trackNext() {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"SkipForward\"}}}"
    _ = executeGetRequest(cmd: cmd)
}
//
// Moves to the previous played track
func trackPrevious() {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"BackForward\"}}}"
    _ =  executeGetRequest(cmd: cmd)
}
//
// Stops playing any track
func trackStop() {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"Stop\"}}}"
    _ = executeGetRequest(cmd: cmd)
}
//
// Toggles the repeat mode
func toggleRepeat(isModeRepeat: Bool)  {
    var cmd = "{\"Media_Obj\" : \"ActiveInput\", \"Method\" : \"ActiveInputCmd\", \"Parameters\" : {\"AudioControl\" : {\"Method\" : \"SetRepeat\", \"Parameters\" :  xxxx}}}"
    cmd = cmd.replacingOccurrences(of:"xxxx", with:(isModeRepeat ? "false" : "true"))
    _ = executeGetRequest(cmd: cmd)
}
//
// Toggles the shuffle mode
func toggleShuffle(isModeShuffle: Bool) {
    var cmd = "{\"Media_Obj\" : \"ActiveInput\", \"Method\" : \"ActiveInputCmd\", \"Parameters\" : {\"AudioControl\" : {\"Method\" : \"SetShuffle\", \"Parameters\" :  xxxx}}}"
    cmd = cmd.replacingOccurrences(of:"xxxx", with:(isModeShuffle ? "false" : "true"))
    _ = executeGetRequest(cmd: cmd)
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
// Helper to create a SHA1 string
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


// TODO Ralf: Braucht es das jetzt wirklich noch, scheinbar schon, ist aber evtl. noch nicht genieal?
// Source: https://stackoverflow.com/questions/26784315/can-i-somehow-do-a-synchronous-http-request-via-nsurlsession-in-swift
extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
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

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}


// TODO Document, noch etwas clean-up
func executeGetRequest(cmd: String) -> (Dictionary<String, AnyObject>) {
    let encodedCmd = getEncodedURL(url: cmd)
    let authString = "Linionik_HTML5" + cmd + "#_Linionik_6_!HTML5!#_Linionik_2012"
    let authStringHash = authString.sha1()
    // Prefix of URL (part directly after the IP/Host)
    let URL_PRE = "/json.php?Json=Linionik_HTML5_[MC_JSON]_"
    // Suffix of URL (part directly before the param)
    let URL_SUF = "_[MC_JSON]_"
    let urlString = "http://" + IP + URL_PRE + authStringHash + URL_SUF + encodedCmd;
    // Initialize return value
    var json = [String: AnyObject]()
    // Initialize HTTP Request
    var request = URLRequest(url: URL(string: urlString)!)
    //print("URL:" + urlString)
    request.httpMethod = "GET"
    let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
    if let error = error {
        print("Synchronous task ended with error: \(error)")
    }
    else {
        //print("Synchronous task ended without errors.")
        do {
            json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
            
        } catch {
            print("error")
        }
    }
    //print(json)
    return json
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
