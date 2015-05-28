//
//  SKScene+nadasIntro.m
//  PixelPlane
//
//  Created by Dario Safa on 12.10.14.
//  Copyright (c) 2014 nasdas. All rights reserved.
//

#import "nasdasIntro.h"
#import "MainMenu.h"
#import "GameScene.h"

@implementation nasdasIntro


-(void)didMoveToView:(SKView *)view{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil]; //Scene soll KEINE Ads anzeigen -> Nachricht an SpriteViewController
    
    [self nasdasIntro];
    
}

-(void)nasdasIntro{
    
    //nasdas Intro
    
    //Video wird initialisiert und hinzugefügt
    SKVideoNode* nasdasIntro = [SKVideoNode videoNodeWithVideoFileNamed:@"nasdas.mov"];
    nasdasIntro.position = CGPointMake(self.size.width/2, self.size.height/2);
    nasdasIntro.zPosition = -10;
    nasdasIntro.size = CGSizeMake(self.size.width, self.size.height);
    [self addChild:nasdasIntro];
    
    SKAction *playVideo = [SKAction runBlock:^{
        [nasdasIntro play];
    }];
    
    SKAction *getToMainMenu = [SKAction runBlock:^{
        SKScene* mainMenu = [[MainMenu alloc] initWithSize:self.size];
        SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
        
        [self.view presentScene:mainMenu transition:doors];
    }];
    
    SKAction *waiting =[SKAction waitForDuration:5];
    SKAction* removeVid = [SKAction removeFromParent];
    
    //Abspielsequenz: Video wird abgespielt, es wird 5sek gewartet bis die Scene wechselt, das Video wird vom Speicher gelöscht
    SKAction *playSequence = [SKAction sequence:@[playVideo,waiting,getToMainMenu, removeVid]];
    [self runAction:playSequence];
    

    

    
    
}



@end
