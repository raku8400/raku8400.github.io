//
//  ContentView.swift
//
//  Created by Ralf Kulik
//

import SwiftUI;
import CommonCrypto;


struct ContentView: View {
    
    // True if Burmi is online, otherwise False
    @State var IS_BURMI_ON = true
    // True if currently a song is being played (irrespective of the play mode cd, tidal etc), otherwise False
    @State var IS_TRACK_PLAYING = true
    // True if player is currently in shuffle mode
    @State var IS_MODE_SHUFFLE = false
    // True if player is currently in repeate mode
    @State var IS_MODE_REPEAT = false
    
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
                    logMsg(crrntMsg: "Play/Pause button was tapped")
                    IS_TRACK_PLAYING = !(IS_TRACK_PLAYING)
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
                }) {
                    Image(IS_MODE_REPEAT ? "RepeatActive" : "RepeatInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
                Button(action: {
                    IS_MODE_SHUFFLE = !(IS_MODE_SHUFFLE)
                    toggleShuffle(isModeShuffle: IS_MODE_SHUFFLE)
                }) {
                    Image(IS_MODE_SHUFFLE ? "ShuffleActive" : "ShuffleInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
            }}}
}

let IP = "192.168.1.106"

// TODO: Irgendwie muss ich noch die STATE Variablen in der Struktur oben von hier aus aktualisieren können


// vermutlich nicht nötig, da implizit im Button definiert
//func updateAllIcons()
//{
//    //print("Hello World:" + crrntMsg)
//}

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

// TODO Document
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
    request.httpMethod = "GET"
    //request.addValue(IP, forHTTPHeaderField: "Host")
    //request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    //request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
    //request.addValue("PostmanRuntime/7.42.0", forHTTPHeaderField: "User-Agent")
    //request.addValue("*/*", forHTTPHeaderField: "Accept")
    //request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
    //let username = "user"
    //let password = "pass"
    //let loginString = String(format: "%@:%@", username, password)
    //let loginData = loginString.data(using: String.Encoding.utf8)!
    //let base64LoginString = loginData.base64EncodedString()
    //request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    //request.addValue("http://192.168.1.106/html5/big_player.html", forHTTPHeaderField: "Referer")
    //request.httpBody = nil

    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
        print("data")
        print(data!)
        if let httpResponse = response as? HTTPURLResponse {
            print("statusCode: \(httpResponse.statusCode)")} 
        let responseData = String(data: data!, encoding: String.Encoding(rawValue: NSUTF8StringEncoding))
        
        print("response")
        print(responseData as Any)
        do {
            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
            print("Data-JSON")
            print(json)
        } catch {
            print("error")
        }
    })

    task.resume()
    /*
    // create the session object
    let session = URLSession.shared
    
    // now create the URLRequest object using the url object
    var request = URLRequest(url: url)
    request.httpMethod = "POST" //set http method as POST
    
    // add headers for the request
    //request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
    //request.addValue("application/json", forHTTPHeaderField: "Accept")
    let parameters: [String: Any] = [:]/*
    do {
      // convert parameters to Data and assign dictionary to httpBody of request
      request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
    } catch let error {
      print(error.localizedDescription)
      return
    }*/
    
    // create dataTask using the session object to send data to the server
    let task = session.dataTask(with: request) { data, response, error in
      
      if let error = error {
        print("Post Request Error: \(error.localizedDescription)")
        return
      }
      
      // ensure there is valid response code returned from this HTTP response
      guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
      else {
        print("Invalid Response received from the server")
        return
      }
    
      // ensure there is data returned
      guard let responseData = data else {
        print("nil Data received from the server")
        return
      }
      /*
      do {
        // create json object from data or use JSONDecoder to convert to Model stuct
        if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
          print(jsonResponse)
          // handle json response
        } else {
          print("data maybe corrupted or in wrong format")
          throw URLError(.badServerResponse)
        }
      } catch let error {
        print(error.localizedDescription)
      }*/
        logMsg(crrntMsg: "data: " )
    }
    // perform the task
    task.resume()
        */
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
