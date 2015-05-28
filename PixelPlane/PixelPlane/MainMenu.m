//
//  MainMenu.m
//  PixelPlane
//
//  Created by Dario Safa on 23.05.14.
//  Copyright (c) 2014 Dario A. Safa. All rights reserved.
//

#import "Score.h"
#import "MainMenu.h"
#import "GameScene.h"
#import <iAd/iAd.h>



@interface MainMenu ()

@property BOOL contentCreated;

@end


@implementation MainMenu


-(void)didMoveToView:(SKView *)view{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil]; //Scene soll Ads anzeigen -> Nachricht an SpriteViewController

    [self createSceneContents];
    //userDefaultsMute = [NSUserDefaults standardUserDefaults];
    //mute = [userDefaultsMute integerForKey:@"mute"];
    //intMute = 100;
    //intSound = 0;
}

//MainMenu Scene Inhalt
-(void)createSceneContents{
    //Bildschirmgrösse vereinfachen
    screenWidth = self.frame.size.width;
    screenHeight = self.frame.size.height;
    
    
    //Hintergrund initialisiert und eingefügt
    
    background = [SKSpriteNode spriteNodeWithImageNamed:@"PixelPlane"];
    background.size = CGSizeMake(screenWidth, screenHeight);
    background.position = CGPointMake(screenWidth/2, screenHeight/2);
    background.zPosition = -10;

     // Je nach Bildschirmgrösse wird Scene skaliert, so dass es den ganzen Bildschrimplatz braucht
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    [self addChild:background];


    //Start und Options Buttons
    //Start
    startGame = [SKSpriteNode spriteNodeWithImageNamed:@"PixelPlane_PlayButton"];
    startGame.name = @"startGame";
    startGame.position = CGPointMake(screenWidth/2, 8*screenHeight/19);
    startGame.zPosition = 0;
    startGame.alpha = 0.7;
    startGame.size = CGSizeMake(270, 180);
    [self addChild:startGame];

    
    // "Play" Hintergrundeffekt
    NSString*playCloudPath = [[NSBundle mainBundle] pathForResource:@"Cloud" ofType:@"sks"];
    playCloud = [NSKeyedUnarchiver unarchiveObjectWithFile:playCloudPath];
    playCloud.position = startGame.position;
    playCloud.zPosition = -1;
    
    [self addChild:playCloud];
 

   
    //Music On // Da der "Mute Button" noch ein wenig verbuggt ist, werde ich dieses Feature erst mit einem Update veröffentlichen
    /*
    
    MusicOn = [SKSpriteNode spriteNodeWithImageNamed:@"PixelPlane_MusicOn"];
    MusicOn.name = @"MusicOn";
    MusicOn.position = CGPointMake((screenWidth/2)-50, startGame.position.y-65);
    MusicOn.size = CGSizeMake(100, 90);
    MusicOn.zPosition = 5;
    
    [self addChild:MusicOn];
    
    //Music Off
    MusicOff = [SKSpriteNode spriteNodeWithImageNamed:@"PixelPlane_MusicOff"];
    MusicOff.name = @"MusicOff";
    MusicOff.position = CGPointMake((screenWidth/2)-50, startGame.position.y-65);
    MusicOff.size = CGSizeMake(100, 90);
    MusicOff.zPosition = 4;
    
    [self addChild:MusicOff];
    */
    
    
    //HighScore Button zum Scenewechsel
    HighScore = [SKSpriteNode spriteNodeWithImageNamed:@"PixelPlane_HighScore"];
    HighScore.name = @"HighScore";
    HighScore.position = CGPointMake((screenWidth/2)+50, startGame.position.y-65);
    HighScore.size = CGSizeMake(100, 90);
    HighScore.zPosition = 5;
    
    [self addChild:HighScore];
    
    
    
    //Hintergrund-Musik
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"8bitMenu" ofType:@"m4a"]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    player.numberOfLoops = -1;
    [player play];
    
    
    
}

//Aktionen bei einem TouchEvent
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    
    //Prüft welcher Button gedrückt wird
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];
    

    if ([node.name isEqualToString:@"startGame"]) {
    
        
    //Start Button Aktionen bei Touch
    SKNode* startButton = [self childNodeWithName:@"startGame"];
    SKAction* pause = [SKAction waitForDuration:0];
    SKAction* startSequence = [SKAction sequence:@[pause]];

        [startButton runAction:startSequence completion:^{
         SKScene* gameScene = [[GameScene alloc] initWithSize:self.size];
         SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
        
         [self.view presentScene:gameScene transition:doors];
       
        
        //Coin Sound-Effect bei Buttonberührung
        
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Pickup_Coin" ofType:@"wav"]];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [player play];
        
        }];
    }

    
    // Mute Support (kommt im nächsten Update)
    /*
    if([node.name isEqualToString:@"MusicOn"]) {
    //Musik Button Aktionen bei Touch
    MusicOn.zPosition = 1;
        
    [[NSNotificationCenter defaultCenter] postNotificationName:@"muteSound" object:nil]; //Scene soll KEINE Ads anzeigen -> Nachricht an SpriteViewController

    //Coin Sound-Effect
    
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Pickup_Coin" ofType:@"wav"]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player play];
        
            
        
    };
    

    
    if ([node.name isEqualToString:@"MusicOff"]) {
    //Music Button Aktionen bei Touch
    MusicOn.zPosition = 10;
        
    [[NSNotificationCenter defaultCenter] postNotificationName:@"muteSound" object:nil]; //Scene soll KEINE Ads anzeigen -> Nachricht an SpriteViewController
        
    NSLog(@"%i", mute);

    //Coin Sound-Effect
        
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"8bitMenu" ofType:@"m4a"]];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    player.numberOfLoops = -1;
    [player play];

    };
    
    */
    
    //HighScore wird gedrückt
    
    if ([node.name isEqualToString:@"HighScore"]) {
        
       
        
        SKNode* highscore = [self childNodeWithName:@"HighScore"];
        SKAction* pause = [SKAction waitForDuration:0];
        SKAction* startSequence = [SKAction sequence:@[pause]];
        
        [highscore runAction:startSequence completion:^{
            SKScene* score = [[Score alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
            
            [self.view presentScene:score transition:doors];
         
         
         //Coin Sound-Effect
         
         url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Pickup_Coin" ofType:@"wav"]];
         player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
         [player play];
        }];
    }
    
}



@end
