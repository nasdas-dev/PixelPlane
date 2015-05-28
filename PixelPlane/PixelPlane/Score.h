//
//  SKScene+Score.h
//  PixelPlane
//
//  Created by Dario Safa on 18.10.14.
//  Copyright (c) 2014 nasdas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Score:SKScene{
    
    
    AVAudioPlayer* player;

    int highScore;
    SKLabelNode* highScoreLabel;
        
    int screenWidth;
    int screenHeight;

    SKSpriteNode* background;
    SKSpriteNode* backButton;

        
    SKSpriteNode* stars1;
    SKSpriteNode* stars2;
    SKSpriteNode* stars3;
    SKSpriteNode* stars4;
    SKSpriteNode* stars5;
    SKSpriteNode* stars5s;
}
@end
