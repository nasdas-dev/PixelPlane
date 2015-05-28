//
//  SKScene+Score.m
//  PixelPlane
//
//  Created by Dario Safa on 18.10.14.
//  Copyright (c) 2014 nasdas. All rights reserved.
//

#import "Score.h"
#import "MainMenu.h"



@implementation Score
-(void)didMoveToView:(SKView *)view{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil]; //Scene soll Ads anzeigen Nachricht an SpriteViewController
    
    [self createSceneContents];
    
}

//HighScore Scene Inhalt
-(void)createSceneContents{
    
    screenWidth = self.frame.size.width;
    screenHeight = self.frame.size.height;
    
    
    //Hintergrund
    
    background = [SKSpriteNode spriteNodeWithImageNamed:@"highScoreBG"];
    background.size = CGSizeMake(screenWidth, screenHeight);
    background.position = CGPointMake(screenWidth/2, screenHeight/2);
    background.zPosition = -10;
    
    
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    [self addChild:background];
    
    
    backButton = [SKSpriteNode spriteNodeWithImageNamed:@"backB"];
    backButton.size = CGSizeMake(190, 70);
    backButton.position = CGPointMake(screenWidth/2, screenHeight/10);
    backButton.name = @"backbutton";
    [self addChild:backButton];
    
    //NSUserDefaults ist ein kleiner Speicher, der sich gut für kleinere Datenmengen, wie z.B. dem High Score eignet.
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    highScore = [userDefaults integerForKey:@"HighScore"];
    
    highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Fipps-Regular"];
    highScoreLabel.fontSize = 20;
    highScoreLabel.fontColor = [SKColor whiteColor];
    highScoreLabel.text = [NSString stringWithFormat:@"%08u", highScore]; //Es wird ein Label mit dem Inhalt von highScore erstellt
    highScoreLabel.position = CGPointMake(screenWidth/2, 5*screenHeight/12);
    highScoreLabel.zPosition = 100;
    
    [self addChild:highScoreLabel];
    
    
    SKLabelNode* highScoreText = [SKLabelNode labelNodeWithFontNamed:@"Fipps-Regular"];
    highScoreText.text = @"Score:"; // Label mit "Score:"
    highScoreText.position = CGPointMake(screenWidth/2, highScoreLabel.position.y+30);

    [self addChild:highScoreText];
    
    
    //Sternbewertung
    stars1 = [SKSpriteNode spriteNodeWithImageNamed:@"1"];
    stars1.position = CGPointMake(screenWidth/2, 5*screenHeight/16);
    stars1.size = CGSizeMake(50, 50);
   
    stars2 = [SKSpriteNode spriteNodeWithImageNamed:@"2"];
    stars2.position = CGPointMake(screenWidth/2, 5*screenHeight/16);
    stars2.size = CGSizeMake(110, 50);

    stars3 = [SKSpriteNode spriteNodeWithImageNamed:@"3"];
    stars3.position = CGPointMake(screenWidth/2, 5*screenHeight/16);
    stars3.size = CGSizeMake(170, 50);

    stars4 = [SKSpriteNode spriteNodeWithImageNamed:@"4"];
    stars4.position = CGPointMake(screenWidth/2, 5*screenHeight/16);
    stars4.size = CGSizeMake(230, 50);

    stars5 = [SKSpriteNode spriteNodeWithImageNamed:@"5"];
    stars5.position = CGPointMake(screenWidth/2, 5*screenHeight/16);
    stars5.size = CGSizeMake(290, 50);

    stars5s = [SKSpriteNode spriteNodeWithImageNamed:@"5s"];
    stars5s.position = CGPointMake(screenWidth/2, 5*screenHeight/16);
    stars5s.size = CGSizeMake(290, 50);

    
    //Bewertung des High Scores zwischen 1-5 Sternen
    
    if (highScore > 0 && highScore <500)
        [self addChild:stars1];
    else if (highScore >= 500 && highScore <2500)
        [self addChild:stars2];
    else if (highScore >= 2500 && highScore <5000)
        [self addChild:stars3];
    else if (highScore >= 5000 && highScore <7500)
        [self addChild:stars4];
    else if (highScore >= 7500 && highScore <10000)
        [self addChild:stars5];
    else if (highScore >= 10000)
        [self addChild:stars5s];
    
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    //Prüft welcher Button gedrückt wird
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];
    
    
    if ([node.name isEqualToString:@"backbutton"]) {
        
        
        //Start Button Aktionen bei Touch
        SKNode* backbutton = [self childNodeWithName:@"backbutton"];
        SKAction* pause = [SKAction waitForDuration:0];
        SKAction* startSequence = [SKAction sequence:@[pause]];
        
        [backbutton runAction:startSequence completion:^{
            SKScene* mainmenu = [[MainMenu alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
            
            [self.view presentScene:mainmenu transition:doors];
            
            
            //Coin Sound-Effect
            
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Pickup_Coin" ofType:@"wav"]];
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
            [player play];
            
        }];
    }
}



@end
