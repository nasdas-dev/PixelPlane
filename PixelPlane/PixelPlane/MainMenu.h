//
//  MainMenu.h
//  PixelPlane
//
//  Created by Dario Safa on 23.05.14.
//  Copyright (c) 2014 Dario A. Safa. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>


@interface MainMenu : SKScene{

    
    int screenWidth;
    int screenHeight;
    
    AVAudioPlayer* player;
    int mute;
    int intMute;
    int intSound;
    NSUserDefaults* userDefaultsMute;
    
    SKSpriteNode* background;
    SKSpriteNode* startGame;
    SKSpriteNode* startGame_pressed;
    SKSpriteNode* MusicOn;
    SKSpriteNode* MusicOff;
    SKSpriteNode* HighScore;

    SKEmitterNode* playCloud;

    NSURL* url;
    
}

@end
