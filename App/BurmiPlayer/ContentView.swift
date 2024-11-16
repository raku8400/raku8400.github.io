//
//  ContentView.swift
//
//  Created by Ralf Kulik (c) 2024

import SwiftUI;
import CommonCrypto;

/* TODO
 * Die Zustände müssen noch initial gelesen werden (z.B. of Shuffle TRUE ist)
 * Self-Refresh alle X Sek
 * Irgendwie muss man noch auf die State-Attribute von aussen zugreifen können?
 * IP noch initial lesen. Im Python Code hat es evtl eine coole URL mit localhost/Burmi o.ä.
 
*/

struct ContentView: View {
    
    // True if Burmi is online, otherwise False
    @State var IS_BURMI_ON = true
    // True if currently a song is being played (irrespective of the play mode cd, tidal etc), otherwise False
    @State var IS_TRACK_PLAYING = true
    // True if player is currently in shuffle mode
    @State var IS_MODE_SHUFFLE = true
    // True if player is currently in repeate mode
    @State var IS_MODE_REPEAT = true
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    (IS_BURMI_ON ? trackPrevious() : logMsg(crrntMsg: "Burmi off"))
                }) {
                    Image(IS_BURMI_ON ? "Play_PreviousActive" : "Play_PreviousInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
                Button(action: {
                    IS_TRACK_PLAYING = !(IS_TRACK_PLAYING)
                    (IS_BURMI_ON ? trackPlayOrPause(isTrackPlaying: IS_TRACK_PLAYING) : logMsg(crrntMsg: "Burmi off"))
                }) {
                    Image(IS_BURMI_ON ? (IS_TRACK_PLAYING ? "Play_PauseActive" : "Play_PlayActive") : "Play_PlayInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
                Button(action: {
                    (IS_BURMI_ON ? trackStop() : logMsg(crrntMsg: "Burmi off"))
                }) {
                    Image(IS_BURMI_ON ? "Play_StopActive" : "Play_StopInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
                Button(action: {
                    (IS_BURMI_ON ? trackNext() : logMsg(crrntMsg: "Burmi off"))
                }) {
                    Image(IS_BURMI_ON ? "Play_NextActive" : "Play_NextInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
            }
            HStack {
                Button(action: {
                    IS_MODE_REPEAT = !(IS_MODE_REPEAT)
                    toggleRepeat(isModeRepeat: IS_MODE_REPEAT)
                    logState(isBurmiOn: IS_BURMI_ON, isTrackPlaying: IS_TRACK_PLAYING, isShuffle: IS_MODE_SHUFFLE, isRepeat: IS_MODE_REPEAT)
                }) {
                    Image(IS_MODE_REPEAT ? "RepeatActive" : "RepeatInActive")
                        .resizable()
                        .frame(width: 34, height: 34)
                }
                Button(action: {
                    IS_MODE_SHUFFLE = !(IS_MODE_SHUFFLE)
                    toggleShuffle(isModeShuffle: IS_MODE_SHUFFLE)
                    logState(isBurmiOn: IS_BURMI_ON, isTrackPlaying: IS_TRACK_PLAYING, isShuffle: IS_MODE_SHUFFLE, isRepeat: IS_MODE_REPEAT)
                }) {
                    Image(IS_MODE_SHUFFLE ? "ShuffleActive" : "ShuffleInActive")
                        .resizable()
                        .frame(width: 34, height: 34)
                }
            }
            Spacer()
            VStack{
            Image(IS_BURMI_ON ? (IS_TRACK_PLAYING ? "Play_PauseActive" : "Play_PlayActive") : "Play_PlayInActive")
                .resizable()
                .frame(width: 160, height: 160)
                
            }
            Spacer()
            VStack{
                Text("Title " + "xx")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Artist " + "xx")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Album " + "xx")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }}
}

let IP = "192.168.1.106"

// TODO: Irgendwie muss ich noch die STATE Variablen in der Struktur oben von hier aus aktualisieren können

func logState(isBurmiOn: Bool, isTrackPlaying: Bool, isShuffle: Bool, isRepeat: Bool) {
    let msg = "Burmi On: " + String(isBurmiOn) + ", Track Playing: " + String(isTrackPlaying) + ", Shuffle: " + String(isShuffle) + ", Repeat: " + String(isRepeat)
    print(msg)
}


//
// Retrieves information about the currently active track
func retrieveTrackInfo(isTrackPlaying: Bool) {
  if (isTrackPlaying) {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioGetInfo\" : {\"Method\" : \"GetCurrentSongInfo\"}}}"
    executeGetRequest(cmd: cmd);
  }
}
//
// Starts or pauses playing of a currently active track
func trackPlayOrPause(isTrackPlaying: Bool) {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"" +  (isTrackPlaying ? "Play" : "Pause") + "\"}}}"
    executeGetRequest(cmd: cmd)
}
//
// Moves to the next played track
func trackNext() {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"SkipForward\"}}}"
    executeGetRequest(cmd: cmd)
}
//
// Moves to the previous played track
func trackPrevious() {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"BackForward\"}}}"
    executeGetRequest(cmd: cmd)
}
//
// Stops playing any track
func trackStop() {
    let cmd = "{\"Media_Obj\" : \"ActiveInput\",\"Method\" : \"ActiveInputCmd\",\"Parameters\" : {\"AudioControl\" : {\"Method\" : \"Stop\"}}}"
    executeGetRequest(cmd: cmd)
}
//
// Toggles the repeat mode
func toggleRepeat(isModeRepeat: Bool)  {
    var cmd = "{\"Media_Obj\" : \"ActiveInput\", \"Method\" : \"ActiveInputCmd\", \"Parameters\" : {\"AudioControl\" : {\"Method\" : \"SetRepeat\", \"Parameters\" :  xxxx}}}"
    cmd = cmd.replacingOccurrences(of:"xxxx", with:(isModeRepeat ? "false" : "true"))
    executeGetRequest(cmd: cmd)
}
//
// Toggles the shuffle mode
func toggleShuffle(isModeShuffle: Bool) {
    var cmd = "{\"Media_Obj\" : \"ActiveInput\", \"Method\" : \"ActiveInputCmd\", \"Parameters\" : {\"AudioControl\" : {\"Method\" : \"SetShuffle\", \"Parameters\" :  xxxx}}}"
    cmd = cmd.replacingOccurrences(of:"xxxx", with:(isModeShuffle ? "false" : "true"))
    executeGetRequest(cmd: cmd)
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

// TODO Document, noch etwas clean-up
func executeGetRequest(cmd: String) {
    let encodedCmd = getEncodedURL(url: cmd)
    let authString = "Linionik_HTML5" + cmd + "#_Linionik_6_!HTML5!#_Linionik_2012"
    let authStringHash = authString.sha1()
    // Prefix of URL (part directly after the IP/Host)
    let URL_PRE = "/json.php?Json=Linionik_HTML5_[MC_JSON]_"
    // Suffix of URL (part directly before the param)
    let URL_SUF = "_[MC_JSON]_"
    let urlString = "http://" + IP + URL_PRE + authStringHash + URL_SUF + encodedCmd;
    var request = URLRequest(url: URL(string: urlString)!)
    print("url: " + cmd)
    request.httpMethod = "GET"

    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
        //if let httpResponse = response as? HTTPURLResponse {
        //    print("statusCode: \(httpResponse.statusCode)")}
        let responseData = String(data: data!, encoding: String.Encoding(rawValue: NSUTF8StringEncoding))
        print("Response:")
        print(responseData as Any)
        /*
        do {
            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
            print("Data-JSON")
            print(json)
        } catch {
            print("error")
        }
        */
    })

    task.resume()

}


// TODO Document
func logMsg(crrntMsg: String)
{
    print("BurmiApp: " + crrntMsg)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
