//
//  ContentView.swift
//
//  Created by Ralf Kulik
//

import SwiftUI

struct ContentView: View {
    
    // IP adress in local network under which Burmi MC can be reached - look it up in the app
    @State var IP = "192.168.1.106"
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
                    greet(crrntMsg: "Previous button was tapped")
                }) {
                    Image("Play_PreviousActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
                Button(action: {
                    greet(crrntMsg: "Play/Play button was tapped")
                    IS_TRACK_PLAYING = !(IS_TRACK_PLAYING)
                }) {
                    Image(IS_TRACK_PLAYING ? "Play_PauseActive" : "Play_PlayInActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
                Button(action: {
                    greet(crrntMsg: "Stop button was tapped")
                }) {
                    Image("Play_StopActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
                Button(action: {
                    greet(crrntMsg: "Forward button was tapped")
                }) {
                    Image("Play_NextActive")
                        .resizable()
                        .frame(width: 68, height: 68)
                }
            }}}
    
    /*
     // TODO nachfolgende IFs einbauen
     if (IS_BURMI_ON)
       IS_TRACK_PLAYING ? "./Icons/Play_PauseActive.png" : "./Icons/Play_PlayActive.png";
     else
        "./Icons/Play_PlayInActive.png";
     document.getElementById("TrackStop").src = IS_BURMI_ON ? "./Icons/Play_StopActive.png" : "./Icons/Play_StopInActive.png" ;
     document.getElementById("TrackPrevious").src = IS_BURMI_ON ? "./Icons/Play_PreviousActive.png" : "./Icons/Play_PreviousInActive.png" ;
     document.getElementById("TrackNext").src = IS_BURMI_ON ? "./Icons/Play_NextActive.png" : "./Icons/Play_NextInActive.png" ;
     document.getElementById("PlayModeShuffle").src = IS_MODE_SHUFFLE ? "./Icons/ShuffleActive.png" : "./Icons/ShuffleInActive.png";
     document.getElementById("PlayModeRepeat").src = IS_MODE_REPEAT ? "./Icons/RepeatActive.png" : "./Icons/RepeatInActive.png";
     */
    
}

func updateAllIcons()
{
    //print("Hello World:" + crrntMsg)
}

// TODO Dummy Function noch anpassen
func greet(crrntMsg: String)
{
    print("Hello World:" + crrntMsg)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
