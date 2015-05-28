//
//  GameScene.m
//  PixelPlane
//
//  Created by Dario Safa on 23.05.14.
//  Copyright (c) 2014 Dario A. Safa. All rights reserved.
//

/*
 
 Ziele für das nächste Update:
 
 - GameOver-Screen Bugs beheben
 - Mute Button wird im Hauptmenü hinzugefügt
 - Eventuell wird der Verlauf von Blau zu Schwarz kürzer eingestellt, da es sehr schwierig ist, durch die schwerer-werdenen Gegner den Sternenhintergrund zu erreichen
 
 - Eventuell wird noch iPad Support hinzugefügt. Alle Elemente skalieren sich zwar ausser die BezierPaths der Gegner.
 Falls es mir gelingt, die Start-, Kontroll- und Endpunkte BezierPaths auf allgemeine Variabeln zu übersetzen, sollte 
 PixelPlane auch auf dem iPad ohne Probleme laufen.
 
 */


#import "GameScene.h"
#import <CoreFoundation/CoreFoundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <SpriteKit/SpriteKit.h>
#import "MainMenu.h"
#define kScoreHudName @"scoreHud"


@interface GameScene ()
@property (nonatomic) CGRect screenRect;
@property int score;

@end

//Bitmask Categories um Gegner, Schüsse, Spieler zu unterscheiden
static const uint32_t shipCategory = 1;
static const uint32_t enemyCategory = 2;
static const uint32_t shootCategory = 4;


@implementation GameScene

//Wenn sich Applikation im Hintergrund befindet (= Multitasking) wird Pausemenü angezeigt
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self pauseMenu];
    
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
       [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil]; //Scene soll KEINE Ads anzeigen -> Nachricht an SpriteViewController
       
        
        // Initialisierung vom Score, von den Gegnern und deren Actions
        [self setupHud];
        [self initEnemies];
        [self gameScene];
        
        // Physics-Eigenschaften werden initialisiert.
        self.physicsWorld.gravity = CGVectorMake(0, 0); // Vektor muss 0 sein
        self.physicsWorld.contactDelegate = self; // Berührungen werden "aufgezeichnet"
        touchEnabled = NO; // Touchscreen wird erst nach 2 Sekunden freigegeben
        
        //Gegner Einstellungen
        enemy1Spawned = 0;
        enemyGetsOtherColor = 0;
        pathSpeed = 8;
        firstTouch = 0;
        oneTimeAction = YES;
        timeBetweenShots = 0;
        //userDefaultsMute = [NSUserDefaults standardUserDefaults];
        //mute = [userDefaultsMute integerForKey:@"mute"];
        
       
    }
    return self;
}

- (void) didSimulatePhysics // Wird ausgeführt nach jeder ausgeführten "Physik Simulation"
{
    /* Durchgehender Rand
     kann nicht in updatemethod stehen, da sich die Position von player1 ansonsten "unendlich" mal verschoben wird, falls der Rand berührt wird
     */
     
    if (player1.position.x < -20.0f) {
        player1.position = CGPointMake(screenWidth+20.0f, player1.position.y);
    } else if (player1.position.x > screenWidth+20.0f) {
        player1.position = CGPointMake(-20.0f, player1.position.y);
    }
    return;
}


// Paths, Enemies und deren Aktionen Initialisierung

-(void)initEnemies{
    //// Bezier 1 Drawing : zick zack, mitte -> rechts -> links
    bezierPath1 = UIBezierPath.bezierPath;
    [bezierPath1 moveToPoint: CGPointMake(121.5, 613.5)];
    [bezierPath1 addCurveToPoint: CGPointMake(225.25, -60.5) controlPoint1: CGPointMake(121.5, 613.5) controlPoint2: CGPointMake(329, 542.87)];
    
    //// Bezier 2 Drawing : einfache Kurve, mitte -> unten rechts
    bezierPath2 = UIBezierPath.bezierPath;
    [bezierPath2 moveToPoint: CGPointMake(158.5, 634.5)];
    [bezierPath2 addCurveToPoint: CGPointMake(158.5, -93.5) controlPoint1: CGPointMake(399.5, 89.22) controlPoint2: CGPointMake(-88.5, 773.21)];
    
    //// Bezier 3 Drawing : links oben nach rechts unten (~linear)
    bezierPath3 = UIBezierPath.bezierPath;
    [bezierPath3 moveToPoint: CGPointMake(65.5, 624.5)];
    [bezierPath3 addCurveToPoint: CGPointMake(252.5, -62.5) controlPoint1: CGPointMake(173.2, -55.45) controlPoint2: CGPointMake(252.5, -62.5)];

    //// Bezier 4 Drawing : links oben nach rechts unten ver2 (~exponentiell)
    bezierPath4 = UIBezierPath.bezierPath;
    [bezierPath4 moveToPoint: CGPointMake(158.5, 634.5)];
    [bezierPath4 addCurveToPoint: CGPointMake(158.5, -93.5) controlPoint1: CGPointMake(399.5, 89.22) controlPoint2: CGPointMake(-88.5, 773.21)];
    
    //// Bezier 5 Drawing : Zick Zack, anfang links
    bezierPath5 = UIBezierPath.bezierPath;
    [bezierPath5 moveToPoint: CGPointMake(54.02, 647.5)];
    [bezierPath5 addCurveToPoint: CGPointMake(270.74, 463.39) controlPoint1: CGPointMake(297.14, 448.71) controlPoint2: CGPointMake(237.73, 524.38)];
    [bezierPath5 addCurveToPoint: CGPointMake(54.02, 254.43) controlPoint1: CGPointMake(303.74, 402.4) controlPoint2: CGPointMake(29.81, 333.5)];
    [bezierPath5 addCurveToPoint: CGPointMake(146.42, -41.5) controlPoint1: CGPointMake(78.22, 175.37) controlPoint2: CGPointMake(146.42, -41.5)];

    
    //// Bezier 6 Drawing : Zick Zack, anfang rechts
    
    bezierPath6 = UIBezierPath.bezierPath;
    [bezierPath6 moveToPoint: CGPointMake(320.5, 630.5)];
    [bezierPath6 addCurveToPoint: CGPointMake(56.5, 368.98)
                   controlPoint1: CGPointMake(52.5, 414.94)
                   controlPoint2: CGPointMake(56.5, 456.52)];
    [bezierPath6 addCurveToPoint: CGPointMake(219.5, 199.38)
                   controlPoint1: CGPointMake(56.5, 281.44)
                   controlPoint2: CGPointMake(219.5, 364.6)];
    [bezierPath6 addCurveToPoint: CGPointMake(56.5, -89.5)
                   controlPoint1: CGPointMake(219.5, 34.15)
                   controlPoint2: CGPointMake(56.5, -89.5)];

    //// Bezier 7 Drawing : einfacher Bogen links
    bezierPath7 = UIBezierPath.bezierPath;
    [bezierPath7 moveToPoint: CGPointMake(69.5, 627.5)];
    [bezierPath7 addCurveToPoint: CGPointMake(69.5, -45.5) controlPoint1: CGPointMake(328.25, 352.38) controlPoint2: CGPointMake(69.5, -45.5)];

    
    //// Bezier 8 Drawing : einfacher Bogen rechts
    bezierPath8 = UIBezierPath.bezierPath;
    [bezierPath8 moveToPoint: CGPointMake(271.5, 611.5)];
    [bezierPath8 addCurveToPoint: CGPointMake(271.5, -61.5) controlPoint1: CGPointMake(12.75, 336.38) controlPoint2: CGPointMake(271.5, -61.5)];
}

-(void)gameScene{
    
    //Damit das Spiel nicht ausversehen durch Touch gestartet wird, setze ich eine Verzögerung von 2 Sekunden.
    
    SKAction* touchWait = [SKAction waitForDuration:2];

    [self runAction:touchWait completion:^{
        touchEnabled = YES;
    }];
    
    
    screenHeight = self.frame.size.height;
    screenWidth = self.frame.size.width;
   
    
    
    // CoreMotion Beschleunigungssensor mit Hilfe von diesem Quellcode hinzugefügt:
    //https://www.inkling.com/read/learning-ios-programming-alasdair-allan-2nd/chapter-9/the-core-motion-framework
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0; //Updateintervall der Geräteposistion
    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                         withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
    CMAcceleration acceleration = accelerometerData.acceleration;
    _xAcceleration = (acceleration.x*0.8) + (_xAcceleration*0.4);
                                         }];
    
    
    //// High Score Speicher & Darstellung
    
    // High Score NSUserDefaults-Speicher wird initialisiert
    userDefaults = [NSUserDefaults standardUserDefaults];
    highScore = [userDefaults integerForKey:@"HighScore"];
    /*Zeigt beim Compilen die Warnung an, dass der NSInteger an Präzision verliert, da er zum "int" Dateityp umkonvertiert. 
     highScore wurde aber immer als "int" Dateityp definiert wie man anhand von GameScene.h / Score.h erkennt, deshalb kann diese Warnung ignoriert werden.
                                                           */
   
    
    // Instruktionen des Gameplays  mit transparenten Grafiklayer wird über Bildschirm angezeigt
    startScreen=[SKSpriteNode spriteNodeWithImageNamed:@"startScreen"];
    startScreen.position = CGPointMake(screenWidth/2, screenHeight/2);
    startScreen.zPosition = 5;
    startScreen.size = CGSizeMake(screenWidth, screenHeight);
    
    [self addChild:startScreen];

    
    
    //Spieler - Flugzeug initialisiert
    player1=[SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    player1.position = CGPointMake(screenWidth/2, 140);
    player1.zPosition = 2;
    player1.size = CGSizeMake(50, 40);
    player1.physicsBody =[SKPhysicsBody bodyWithCircleOfRadius:player1.size.height/2];
    player1.physicsBody.dynamic = YES;
    
    /*
    node.physicsBody.categoryBitMask = die Kategorie des Sprites selber
    node.physicsBody.contactBitMask = die Kategorie mit welcher der Sprite interagiert (=> Berührungen beispielsweise)

    */
    
    player1.physicsBody.categoryBitMask = shipCategory;
    player1.physicsBody.contactTestBitMask = enemyCategory;
    
    // [self addChild:player1]; ///////////////////
    
    // Partikeleffekt des Raketenantriebs
    myParticlePathSmoke = [[NSBundle mainBundle] pathForResource:@"shipSmoke" ofType:@"sks"];
    shipSmoke = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePathSmoke];
    shipSmoke.zPosition = 2;

    // [self addChild:shipSmoke];
    
    //Hintergrund-Musik
    NSURL *url2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pixelplane" ofType:@"aiff"]];
    bgPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url2 error:nil];
    bgPlayer.numberOfLoops = -1;
    
    //if (mute == 0) {
    [bgPlayer play];
      //  NSLog(@"%i", mute);

    //}
    //if (mute == 100) {
    //    [bgPlayer stop];
    //    NSLog(@"%i", mute);
    //}
    
    
    //Hintergrund Video (=> Verlauf von blau zu schwarz)
    bgVideo = [SKVideoNode videoNodeWithVideoFileNamed:@"background.mov"];
    bgVideo.position = CGPointMake(screenWidth/2, screenHeight/2);
    bgVideo.zPosition = -2;
    bgVideo.size = CGSizeMake(screenWidth, screenHeight);
    [self addChild:bgVideo];
    
    //Hintergrund Sterne (=> werden angezeigt sobald das Video fertig ist, d.h. wenn der Bildschirm schwarz ist)
    blackBG = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(screenWidth, screenHeight)];
    blackBG.position = CGPointMake(screenWidth/2, screenHeight/2);
    blackBG.zPosition = -1;
    [self addChild:blackBG];
    blackBG.hidden = YES;

    remove = [SKAction removeFromParent];
    starsCountdown = [SKAction waitForDuration:300];
    removeVideo = [SKAction runBlock:^{
        [bgVideo runAction:remove];
    }];
    
    removeClouds = [SKAction runBlock:^{
        cloudsStop = YES;
    }];
    
    blackBack = [SKAction runBlock:^{
        blackBG.hidden = NO;
    }];
    
     /*
     Sterne werden hinzugefügt, in dem zuerst die Länge des Videos abgewartet wird.
     Danach werden keine Wolken mehr gespawnt, das Video wird vom Speicher gelöscht 
     und ein schwarzes Bild im Hintergrund eingefügt. 
     Das schwarze bild wird eingefügt, weil die Standardhintergrundfarbe einer Scene grau ist.
    
    ---> runAction siehe firsttouch == 1
      */
    

 
    
    //Pausen Button
    pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"pauseIcon"];
    pauseButton.position = CGPointMake(screenWidth/2, screenHeight-40);
    pauseButton.zPosition = 1010;
    pauseButton.name = @"pauseButton";
    pauseButton.size = CGSizeMake(40, 40);
    
    // [self addChild:pauseButton]; /////////////////////////////////////////////

    
    //Pausen-Menü
    
    //Transparenter Schwarz-Weiss Verlauf, um das Menü
    pauseBG = [SKSpriteNode spriteNodeWithImageNamed:@"pauseBG"];
    pauseBG.size = CGSizeMake(screenWidth, screenHeight);
    pauseBG.position = CGPointMake(screenWidth/2, screenHeight/2);
    pauseBG.alpha = 0.5;
    pauseBG.zPosition = 50;
    pauseBG.hidden = YES;
    
    [self addChild:pauseBG];
    
    pauseText = [SKSpriteNode spriteNodeWithImageNamed:@"PAUSE"];
    pauseText.size = CGSizeMake(178, 47);
    pauseText.position = CGPointMake(screenWidth/2, 4*screenHeight/5);
    pauseText.zPosition = 100;
    pauseText.hidden = YES;

    [self addChild:pauseText];
    
    cont = [SKSpriteNode spriteNodeWithImageNamed:@"CONTINUE"];
    cont.size = CGSizeMake(250, 120);
    cont.position = CGPointMake(screenWidth/2, 4*screenHeight/7);
    cont.zPosition = -100;
    cont.name = @"continue";
    cont.hidden = YES;
    
    [self addChild:cont];
    
    backm = [SKSpriteNode spriteNodeWithImageNamed:@"BACKTM"];
    backm.size = CGSizeMake(250, 120);
    backm.position = CGPointMake(screenWidth/2, 4*screenHeight/10);
    backm.zPosition = -100;
    backm.name = @"backtomenu";
    backm.hidden = YES;
    
    [self addChild:backm];
    
    
}

//Hintergrundwolkenfunktion
-(void)clouds{
    
    SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
    int randomYAxix = [self getRandomNumberBetween:0 to:screenHeight];
    cloud.size = CGSizeMake(100, 65);
    cloud.position = CGPointMake(screenHeight+cloud.size.height/2, randomYAxix);
    cloud.zPosition = 1;
    cloud.alpha = 0.4;
    int randomTimeCloud = [self getRandomNumberBetween:9 to:19];
    
    SKAction *move =[SKAction moveTo:CGPointMake(0-cloud.size.height, randomYAxix) duration:randomTimeCloud];
    remove = [SKAction removeFromParent];
    [cloud runAction:[SKAction sequence:@[move,remove]]];
    [self addChild:cloud];
    
    /*
     Da die Wolken auf verschiedenen z.Positionen spawnen und transparent sind,
     entstehen sehr schöne Effekte, falls sich zwei oder mehrere Wolken überlappen.
    */
    
}

//Hintergrundsterne (ab 5min Spielzeit)
-(void)stars{
    starsPath = [[NSBundle mainBundle] pathForResource:@"Stars" ofType:@"sks"];
    stars = [NSKeyedUnarchiver unarchiveObjectWithFile:starsPath];
    stars.position = CGPointMake(screenWidth/2, screenHeight/2);
    stars.zPosition = 1;

    SKAction* starsWait = [SKAction waitForDuration:3];
    remove = [SKAction removeFromParent];

    [stars runAction:[SKAction sequence:@[starsWait,remove]]];
    [self addChild:stars];

    /*
    Da die Sterne mit dem Partikeleditor erstellt wurden,
    müssen sie nur im regelmässigem Abstand zur Szene hizugefügt und wieder gelöscht werden
    */
}

// Zahlenzufallsgeneratorfunktion
-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}


// Zufallsgenerator für Enemy Paths
-(UIBezierPath*)getRandomPath:(int)from to:(int)to{
    switch (arc4random() % 8) {
        case 1:
            return bezierPath1;
            break;
        case 2:
            return bezierPath2;
            break;
        case 3:
            return bezierPath3;
            break;
        case 4:
            return bezierPath4;
            break;
        case 5:
            return bezierPath5;
            break;
        case 6:
            return bezierPath6;
            break;
        case 7:
            return bezierPath7;
            break;
        case 8:
            return bezierPath8;
            break;
        
        // Der Bug der in der schriftlichen Maturaarbeit unter "Schwierigkeiten" erwähnt wurde.
        // Der default Status der switch Funktion gab return 0 als BezierPath zurückl, was die App zum Absturz brachte
            
        default:
            return bezierPath6;
            break;
    }
}


-(void)setupHud {
    // Das ScoreLabel wird eingefügt
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Fipps-Regular"];
    scoreLabel.name = kScoreHudName;
    scoreLabel.fontSize = 13;
    scoreLabel.fontColor = [SKColor whiteColor];
    scoreLabel.text = [NSString stringWithFormat:@"%08u", 0];
    scoreLabel.position = CGPointMake(20 + scoreLabel.frame.size.width/2,self.frame.size.height-50);
    scoreLabel.zPosition = 100;

    // [self addChild:scoreLabel];
}

// Die Scorefunktion. Das Scoring-System wurde mit Hilfe von diesem Tutorial erstellt und ein wenig überarbeitet:
// http://www.raywenderlich.com/51108/build-spaceinvaders-in-spritekit-part-2-of-2
-(void)scoreChange:(int)points {
    self.score += points;
    SKLabelNode* score = (SKLabelNode*)[self childNodeWithName:kScoreHudName];
    score.text = [NSString stringWithFormat:@"%08u", self.score];
}

// Diese Funktion wird jedes Mal ausgeführt wenn der Spieler schiessen will
-(void)weaponParticle{
    // Spieler Schuss-Particles
    
    //Path des Schusspartikels
    myParticlePath = [[NSBundle mainBundle] pathForResource:@"ShootFire" ofType:@"sks"];
    myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    
    myParticle.physicsBody =[SKPhysicsBody bodyWithCircleOfRadius:0.2];
    myParticle.physicsBody.categoryBitMask = shootCategory;
    myParticle.physicsBody.contactTestBitMask = enemyCategory;
    
    //Schuss-Action
    moveUp = [SKAction moveByX:0.0 y:screenHeight duration:1.0];
    remove = [SKAction removeFromParent];
    weaponShot = [SKAction sequence:@[moveUp, remove]];
    
    myParticle.position = CGPointMake(player1.position.x, player1.position.y+10);
    
    //Schuss Sound-Effect
    SKAction* laserShot = [SKAction playSoundFileNamed:@"Laser_Shoot.wav" waitForCompletion:NO];
    
    
    if (tapToRestart.zPosition != 102) {
        [self addChild:myParticle]; // verhindert dass noch im Game Over Bildschirm geschossen werden kann
        [myParticle runAction: weaponShot];
        [self runAction:laserShot];
    }

}

// Diese Funktion wird jedes Mal ausgeführt wenn der Gegner schiesst
-(void)enemyWeaponParticle{
    
    //Schuss-Particles
    
    //Schuss-Action
    enemyParticlePath = [[NSBundle mainBundle] pathForResource:@"enemyFire" ofType:@"sks"];
    enemyParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:enemyParticlePath];
    
    enemyParticle.physicsBody =[SKPhysicsBody bodyWithCircleOfRadius:0.2];
    enemyParticle.physicsBody.collisionBitMask = shootCategory;
    enemyParticle.physicsBody.contactTestBitMask = shipCategory;
    
    enemyParticle.position = CGPointMake(enemy.position.x, enemy.position.y-10);
    
    
    moveDown = [SKAction moveByX:0.0 y:-screenHeight duration:2];
    remove = [SKAction removeFromParent];
    
    weaponShotE = [SKAction sequence:@[moveDown, remove]];
    [self addChild:enemyParticle];
    [enemyParticle runAction:weaponShotE];
    
}

/*
TouchToShoot gibt an, ob es dem Spieler gerade erlaubt ist zu schiessen 
 (z.B. im Pausenmenü oder in der Game Over Ansichtnicht erlaubt)
*/
- (void)enableTouchToShoot{
    touchToShoot = YES;
}

// Pausenmenü Funktion (wird ausgeführt wenn Pausebutton gedrückt wird)
-(void)pauseMenu{

    pauseButtonTouch = YES;
    self.paused=YES;
    
    //NSLog(@"cS %i", _score);
    //NSLog(@"HS %i", highScore);
    pauseBG.hidden = NO;
    pauseText.hidden = NO;
    cont.hidden = NO;
    backm.hidden = NO;
    backm.zPosition = 100;
    cont.zPosition = 100;


}

/*
Diese Aktion wird bei Berührung des Back To Main Menu- Buttons ausgeführt
um zu verhindern, dass man unbeabsichtigt das Spiel verlässt
*/
 - (void) displayAlert {
    self.paused = YES;
    alertView = [[UIAlertView alloc] initWithTitle:@"Returning to Main Menu" message:@"Are you sure you want to go the Main Menu? All your progress will be lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Main Menu", nil];
    [alertView show];

}

// GameOver Funktion
/*
 Die GameOver Ansicht ist noch ein wenig verbuggt, d.h. es treten folgende bekannte Fehler auf:
  - Falls Spieler noch vor dem Game Over schiesst und Gegner trifft bekommt er trotzdem Punkte. 
  - Wenn der Score des aktuellen Spiels höher als der HighScore ist, wird der HighScore mit 100 Punkten weniger angezeigt. Es speichert jedoch den richtigen (den erreichten) Score im Speicher ab.
  - Wenn Spieler von einem gegnerischen Schuss getroffen wurde, spawnen zwei Gegner im Hintergrund.

 Alle Buggs sollten mit dem nächsten Update behoben werden.
 
 
*/

-(void)gameOver{
    
    touchEnabled = NO;
    touchToShoot = NO;
    pauseBG.hidden = NO;
    pauseButton.hidden = YES;
    
    gameOverText = [SKSpriteNode spriteNodeWithImageNamed:@"gameOver"];
    gameOverText.size = CGSizeMake(190, 57);
    gameOverText.position = CGPointMake(screenWidth/2, 4*screenHeight/5);
    gameOverText.zPosition = 100;
    
    [self addChild:gameOverText];
    
    // Das weisse Rechteck in dem der Score / High Score angezeigt wird
    gameOverRect = [SKSpriteNode spriteNodeWithImageNamed:@"gameOverRect"];
    gameOverRect.size = CGSizeMake(180, 180);
    gameOverRect.position = CGPointMake(screenWidth/2, screenHeight/2);
    gameOverRect.zPosition = 100;
    
    [self addChild:gameOverRect];
    
    
    SKLabelNode* scoreText = [SKLabelNode labelNodeWithFontNamed:@"Fipps-Regular"];
    scoreText.fontSize = 18;
    scoreText.fontColor = [SKColor blackColor];
    scoreText.text = [NSString stringWithFormat:@"Score"];
    scoreText.position = CGPointMake(screenWidth/2, gameOverRect.position.y+gameOverRect.size.height/2-40);
    scoreText.zPosition = 101;
    
    [self addChild:scoreText];

    
    scoreLabel.fontColor = [SKColor blackColor];
    scoreLabel.position = CGPointMake(screenWidth/2,gameOverRect.position.y+gameOverRect.size.height/2-70);
    scoreLabel.zPosition = 1500;
    
    SKLabelNode* highScoreText = [SKLabelNode labelNodeWithFontNamed:@"Fipps-Regular"];
    highScoreText.fontSize = 17;
    highScoreText.fontColor = [SKColor blackColor];
    highScoreText.text = [NSString stringWithFormat:@"High Score"];
    highScoreText.position = CGPointMake(screenWidth/2, gameOverRect.position.y+gameOverRect.size.height/2-120);
    highScoreText.zPosition = 101;
    
    [self addChild:highScoreText];
    
    
    highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Fipps-Regular"];
    highScoreLabel.fontSize = 13;
    highScoreLabel.fontColor = [SKColor blackColor];
    highScoreLabel.text = [NSString stringWithFormat:@"%08u", highScore];
    highScoreLabel.position = CGPointMake(screenWidth/2, gameOverRect.position.y+gameOverRect.size.height/2-150);
    highScoreLabel.zPosition = 1500;
    
    [self addChild:highScoreLabel];

    /*
     Tap To Restart kommt erst nach einer gewissen Wartzezeit auf -> restartAction
    */
    
    tapToRestart = [SKSpriteNode spriteNodeWithImageNamed:@"tapToRestart"];
    tapToRestart.size = CGSizeMake(220, 40);
    tapToRestart.position = CGPointMake(screenWidth/2, gameOverRect.position.y+gameOverRect.size.height/2-280);
    tapToRestart.zPosition = -101;
    [self addChild:tapToRestart];

    
    restartAction = [SKAction scaleBy:1.3 duration:2];
    restartActionReverse = restartAction.reversedAction;
    restartActionSeq = [SKAction sequence:@[restartAction, restartActionReverse]];
    
    gameOver = YES;
    SKAction* touchWait = [SKAction waitForDuration:1];
    
    [self runAction:touchWait completion:^{
        touchEnabled = YES;
        tapToRestart.zPosition = 102;
        [tapToRestart runAction:[SKAction repeatActionForever:restartActionSeq]];
    }];
    
}

//Scene wird bei TapToRestart neu-initialisiert

-(void)restartGame{
    
    SKScene* gameScene = [[GameScene alloc] initWithSize:self.size];
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:1];
    
    [self.view presentScene:gameScene transition:doors];
    
}

//Enemies Spawner LEVEL 1 - 4 (Gegnertypen)

-(void)enemiesLevel1
{
    /* Kommentare nur bei enemiesLevel1 method, da alle Level ähnlich sind (mit Ausnahme von der Loop-Verfärbung(enemyGetsOtherColor), waitShoot Duration
    */
    
    EnemyName = @"enemy48bit";
    enemy = [SKSpriteNode spriteNodeWithImageNamed:EnemyName];
    //Enemy Path
    enemy.size = CGSizeMake(40, 40);
    
    if (enemyGetsOtherColor == 1) {
        enemy.color = [SKColor redColor];
        enemy.colorBlendFactor = 0.30f;
    }
    
    if (enemyGetsOtherColor == 2) {
        enemy.color = [SKColor redColor];
        enemy.colorBlendFactor = 0.60f;
    }
    
    if (enemyGetsOtherColor == 3) {
        enemy.color = [SKColor redColor];
        enemy.colorBlendFactor = 1;
    }
    
    
    
    //PhysicsBody Eigenshaften
    enemy.physicsBody =[SKPhysicsBody bodyWithCircleOfRadius:2*enemy.size.width/3];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    
    // Generiert zufälligen Enemy Path
    enemyPath = [self getRandomPath:1 to:8];
    pathRef = [enemyPath CGPath];
    followPath = [SKAction followPath:pathRef
                             asOffset:NO
                         orientToPath:YES
                             duration: pathSpeed];
    
    
    SKAction* enemy1Spawn = [SKAction sequence:@[followPath, remove]];
    [self addChild:enemy];
    
    // Gegner wird bei jedem enemiesLevel1 call erschaffen
    [enemy runAction:enemy1Spawn];
    
    
    //Schuss Zeitintervall
    waitShoot = [SKAction waitForDuration:1.3-timeBetweenShots];
    addParticle = [SKAction runBlock:^{
        // Erforderlich, damit letzer Gegner dieser Welle, nicht mehr schiesst nach seiner Zerstörung
        if (hitCount<=11) {
            [self enemyWeaponParticle];
        }
    }];
    SKAction* shootSeq = [SKAction sequence:@[waitShoot, addParticle]];
    foreverShootSeq = [SKAction repeatActionForever:shootSeq];
    //One Time Action wird 1-mal ausgeführt
    if (oneTimeAction == YES) {
        oneTimeAction = NO;
        [self runAction:foreverShootSeq withKey:@"foreverShootSeq"];
        
    }
}

-(void)enemiesLevel2{

    EnemyName = @"enemy28bit";
    enemy = [SKSpriteNode spriteNodeWithImageNamed:EnemyName];
    //Enemy Path
    enemy.size = CGSizeMake(40, 40);
    
    if (enemyGetsOtherColor == 1) {
        enemy.color = [SKColor blueColor];
        enemy.colorBlendFactor = 0.30f;
    }
    
    if (enemyGetsOtherColor == 2) {
        enemy.color = [SKColor blueColor];
        enemy.colorBlendFactor = 0.60f;
    }
    
    if (enemyGetsOtherColor == 3) {
        enemy.color = [SKColor blueColor];
        enemy.colorBlendFactor = 1;
    }
    
    
    
    //PhysicsBody Eigenshaften
    enemy.physicsBody =[SKPhysicsBody bodyWithCircleOfRadius:enemy.size.width/2];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    
    // Generiert zufälligen Enemy Path
    enemyPath = [self getRandomPath:1 to:8];
    pathRef = [enemyPath CGPath];
    followPath = [SKAction followPath:pathRef
                             asOffset:NO
                         orientToPath:YES
                             duration: pathSpeed];
    
    
    SKAction* enemy1Spawn = [SKAction sequence:@[followPath, remove]];
    [self addChild:enemy];
    
    [enemy runAction:enemy1Spawn];
    
    
    
    waitShoot = [SKAction waitForDuration:1.1-timeBetweenShots];
    addParticle = [SKAction runBlock:^{
        if (hitCount<=21) {
            [self enemyWeaponParticle];
        }
    }];
    SKAction* shootSeq = [SKAction sequence:@[waitShoot, addParticle]];
    foreverShootSeq = [SKAction repeatActionForever:shootSeq];
    if (oneTimeAction == YES) {
        oneTimeAction = NO;
        [self runAction:foreverShootSeq withKey:@"foreverShootSeq"];
        
    }
}


-(void)enemiesLevel3{
    EnemyName = @"enemy18bit";
    enemy = [SKSpriteNode spriteNodeWithImageNamed:EnemyName];
    //Enemy Path
    enemy.size = CGSizeMake(40, 40);
    
    if (enemyGetsOtherColor == 1) {
        enemy.color = [SKColor yellowColor];
        enemy.colorBlendFactor = 0.30f;
    }
    
    if (enemyGetsOtherColor == 2) {
        enemy.color = [SKColor yellowColor];
        enemy.colorBlendFactor = 0.60f;
    }
    
    if (enemyGetsOtherColor == 3) {
        enemy.color = [SKColor yellowColor];
        enemy.colorBlendFactor = 1;
    }
    
    
    
    //PhysicsBody Eigenshaften
    enemy.physicsBody =[SKPhysicsBody bodyWithCircleOfRadius:enemy.size.width/2];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    
    // Generiert zufälligen Enemy Path
    enemyPath = [self getRandomPath:1 to:8];
    pathRef = [enemyPath CGPath];
    followPath = [SKAction followPath:pathRef
                             asOffset:NO
                         orientToPath:YES
                             duration: pathSpeed];
    
    
    SKAction* enemy1Spawn = [SKAction sequence:@[followPath, remove]];
    [self addChild:enemy];
    
    [enemy runAction:enemy1Spawn];
    
    
    
    waitShoot = [SKAction waitForDuration:0.9-timeBetweenShots];
    addParticle = [SKAction runBlock:^{
        if (hitCount<=31) {
            [self enemyWeaponParticle];
        }
        
    }];
    SKAction* shootSeq = [SKAction sequence:@[waitShoot, addParticle]];
    foreverShootSeq = [SKAction repeatActionForever:shootSeq];
    if (oneTimeAction == YES) {
        oneTimeAction = NO;
        [self runAction:foreverShootSeq withKey:@"foreverShootSeq"];
        
    }
}

-(void)enemiesLevel4{
    EnemyName = @"enemy58bit";
    enemy = [SKSpriteNode spriteNodeWithImageNamed:EnemyName];
    //Enemy Path
    enemy.size = CGSizeMake(40, 40);
    
    if (enemyGetsOtherColor == 1) {
        enemy.color = [SKColor whiteColor];
        enemy.colorBlendFactor = 0.30f;
    }
    
    if (enemyGetsOtherColor == 2) {
        enemy.color = [SKColor whiteColor];
        enemy.colorBlendFactor = 0.60f;
    }
    
    if (enemyGetsOtherColor == 3) {
        enemy.color = [SKColor whiteColor];
        enemy.colorBlendFactor = 1;
    }
    
    
    
    //PhysicsBody Eigenshaften
    enemy.physicsBody =[SKPhysicsBody bodyWithCircleOfRadius:enemy.size.width/2];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    
    // Generiert zufälligen Enemy Path
    enemyPath = [self getRandomPath:1 to:8];
    pathRef = [enemyPath CGPath];
    followPath = [SKAction followPath:pathRef
                             asOffset:NO
                         orientToPath:YES
                             duration: pathSpeed];
    
    
    SKAction* enemy1Spawn = [SKAction sequence:@[followPath, remove]];
    [self addChild:enemy];
    
    [enemy runAction:enemy1Spawn];
    
    
    
    waitShoot = [SKAction waitForDuration:0.8-timeBetweenShots];
    addParticle = [SKAction runBlock:^{
        if (hitCount<=40) {
            [self enemyWeaponParticle];
        }
        
    }];
    SKAction* shootSeq = [SKAction sequence:@[waitShoot, addParticle]];
    foreverShootSeq = [SKAction repeatActionForever:shootSeq];
    if (oneTimeAction == YES) {
        oneTimeAction = NO;
        [self runAction:foreverShootSeq withKey:@"foreverShootSeq"];
        
    }
}


/////////////////////////////////////////////////////////
/////////////////// System Methods //////////////////////
/////////////////////////////////////////////////////////

// Die AlertView die im Pausenmenü zum Hauptmenü zurückführen kann
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.paused = YES;
    if (buttonIndex == 1) {
        self.paused = NO;
        [bgPlayer stop];
        SKScene* MainMenuScene = [[MainMenu alloc] initWithSize:self.size];
        SKTransition *doors = [SKTransition doorsOpenHorizontalWithDuration:0.5];
        [self.view presentScene:MainMenuScene transition:doors];
    }
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touchEnabled == YES){
        firstTouch++;
        
        //Alle Aktionen die bei der ersten Bildschirmberührung geschehen.
        // (Durch touchEnabled, wird der Touchscreen erst nach 2 Sekunden nach Scene-Eintritt freigegeben
        
        if (firstTouch == 1){
            
            SKAction* removeFade = [SKAction removeFromParent];
            SKAction* startFade = [SKAction fadeAlphaTo:0 duration:0.5];
            SKAction* fadeSeq = [SKAction sequence:@[startFade, removeFade]];
            
            //Instruktionsbild wird mit Fadeout entfernt
            [startScreen runAction:fadeSeq completion:^{
                startScreenRemoved = YES;
                
                //Erste Gegnerwelle wird ausgeführt
                [self enemiesLevel1];
                
                //Verlauf im Hintergrund wird gestartet
                [bgVideo play];
                
                //Clouds Action: Der Countdown zu den Sternen wird gestartet (300 Sekunden lang -> Länge des Hintergrundvideos des Blau-Schwarz Verlaufs)
                [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[starsCountdown, removeClouds,removeVideo, blackBack]]]];
                
                //Nun kann geschossen werden
                touchToShoot = YES;
                
            }];
            
        }
        
        if (gameOver == YES){
            [self removeAllActions];
            [self removeAllChildren];
            
            [bgPlayer stop];
            touchToShoot = NO;
            
            [self restartGame];
            gameOver = NO;
        }
    }
    
    //Spieler-Schuss Kapazität (dass man nicht beliebig schnell feuern kann)
    if (touchToShoot == YES) {
        [self weaponParticle];
        touchToShoot = NO;
        [self performSelector:@selector(enableTouchToShoot) withObject:nil afterDelay:0.5];
        [self scoreChange:10];
    }
    
    
    //Pause Button
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];
    
    
    if ([node.name isEqualToString:@"pauseButton"]) {
        
        [self pauseMenu];
        
    }
    
    
    else if ([node.name isEqualToString:@"continue"]) {
        
        // Die pausierte GameScene wird fortgesetzt
        self.paused = NO;
        pauseBG.hidden = YES;
        pauseText.hidden = YES;
        backm.hidden = YES;
        cont.hidden = YES;
        
        
        //Damit unsichtbare Buttons nicht während dem Spiel gedrückt werden
        backm.zPosition = -100;
        cont.zPosition = -100;
        
        
    }
    
    else if ([node.name isEqualToString:@"backtomenu"]) {
        
        //Aktionen die passieren, wenn man auf den Back To Main Menu Button im Pausenmenü drückt
        self.paused = NO;
        
        [self displayAlert];
        
        
        
    }
}


-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    //Unendliche Gegner Loop: wird im schriftlichen Teil beschrieben
    
    // Anfang der Loop
    if (hitCount<=10) {
        [self enemiesLevel1];
        }
    if (hitCount == 10){
        [enemy removeActionForKey:@"foreverShootSeq"]; /* bei jedem Gegnertypwechsel (jeder 10te hitCount)
                                                        muss foreverShootSeq action gestoppt werden, ansonsten gibt
                                                        es bei den folgenden Loops Probleme*/
        oneTimeAction = YES; // One Time Action wird nach jedem Gegnertypwechsel auf YES geswitched
    }
   
    if (hitCount>10 && hitCount <= 20) {
        [self enemiesLevel2];
    }
    if (hitCount == 20){
        [enemy removeActionForKey:@"foreverShootSeq"];
        oneTimeAction = YES;
    }
    if (hitCount>20 && hitCount <= 30) {
        [self enemiesLevel3];
    }

    if (hitCount == 30){
        [enemy removeActionForKey:@"foreverShootSeq"];
        oneTimeAction = YES;
    }
    
    if (hitCount>30 && hitCount <= 40) {
        [self enemiesLevel4];
    }
    
    
    //Gegner Loop Neustart
    if (hitCount == 40){
        hitCount = 0; // Loop fängt neu an
        [enemy removeActionForKey:@"foreverShootSeq"];
        oneTimeAction = YES; // muss wieder resettet werden, dass Gegner im gleichen Zeitabstand schiessen
        enemyGetsOtherColor++; //Gegner verändern ihre Farbe
        pathSpeed -= 0.3; //Gegner Paths werden schneller ausgeführt
        timeBetweenShots += 0.1;
    }
    
    
    // Erkennung eines Zusammenpralls mit einem Gegner
    if (contact.bodyA.categoryBitMask == shipCategory) {
        
        //Explosion Animation
        SKAction* wait =[SKAction waitForDuration:0.5];
        SKAction* fadeOut = [SKAction scaleTo:0.0 duration:1];
        remove = [SKAction removeFromParent];
        
        
        explodeSequenceGO =[SKAction sequence:@[fadeOut,wait,remove]];
        
        
        ExplosionPath = [[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"];
        Explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:ExplosionPath];
        Explosion.position = CGPointMake(contact.bodyA.node.position.x, contact.bodyA.node.position.y);
        [self addChild:Explosion];
        [Explosion runAction:explodeSequenceGO];
        
        /*
         Die Explosion wird mit Hilfe des Explosion.sks Particle animiert. Wenn man sich das Particle File anschaut,
         erkennt man, dass es sich dabei eigentlich um eine kontinuierliche Vergrösserung von mehreren roten Particles 
         handelt. Deshalb wird bei der SKAction-Sequenz der Explosion.sks Partikel erstellt, herunterskaliert und 
         anschliessend von der Scene entfernt.
         */
        
        
        
        
        [contact.bodyA.node removeFromParent];
        [contact.bodyB.node removeFromParent];
        [shipSmoke removeFromParent];
        [player1 removeFromParent];
       
        touchEnabled = NO;
        [self gameOver];
        
    }
    
    //Erkennung eines Gegner-Abschuss
    if (contact.bodyA.contactTestBitMask == enemyCategory || contact.bodyB.contactTestBitMask == enemyCategory) {
        
        //Explosion Animation
        SKAction* wait =[SKAction waitForDuration:0.5];
        SKAction* fadeOut = [SKAction scaleTo:0.0 duration:1];
        remove = [SKAction removeFromParent];
        explodeSequenceGO =[SKAction sequence:@[fadeOut,wait,remove]];
        
        ExplosionPath = [[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"];
        Explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:ExplosionPath];
        Explosion.position = CGPointMake(contact.bodyA.node.position.x, contact.bodyA.node.position.y);
        
        [Explosion runAction:explodeSequenceGO];
        [self addChild:Explosion];
        [contact.bodyA.node removeFromParent];
        [contact.bodyB.node removeFromParent];
        
        //Schuss Sound-Effect
        SKAction* explosionSound = [SKAction playSoundFileNamed:@"Explosion.wav" waitForCompletion:NO];
        [self runAction:explosionSound];
        hitCount++;
        [self scoreChange:100];
    }
    
}



-(void)update:(CFTimeInterval)currentTime {
    
    
    // Bewegungssensor
    player1.physicsBody.velocity = CGVectorMake(_xAcceleration * 400.0f, player1.physicsBody.velocity.dy);
    
    /*
     Die Schnelligkeit des Spielers kann hier definiert werden. Derzeit ist es auf einem relativ hohen 
     Schwierigkeitsgrad eingestellt, da sich der Spieler nicht so schnell bewegen kann. Ich habe viele Geschwindigkeits-
     einstellungen getestet und habe diese Variante als unterhaltsamste empfunden. Natürlich könnte ich den Spieler
     trotzdem zu jeder Zeit mit einem Update schneller machen.
    */
    
    
    
    // Raketenantriebsposition (Partikel)
    shipSmoke.position = CGPointMake(player1.position.x, player1.position.y-26);

    // Hintergrundwolken
    int randomClouds = [self getRandomNumberBetween:1 to:50];
    if(randomClouds == 1 && cloudsStop == NO){
        if (firstTouch >= 1) {
            [self clouds];
        }
    }
    
    // Hintergrundsterne
    int randomStars = [self getRandomNumberBetween:1 to:50];
    if(randomStars == 1 && cloudsStop == YES){
        [self stars];
    }
    
    //High Score Speicher
    if (_score>highScore) {
        
        [userDefaults setInteger:_score forKey:@"HighScore"];
        [userDefaults synchronize];
        highScore=_score;
    }
    
    // Sobald ein enemy sprite den unteren Bildschirmrand überquert (y<0)
    if (enemy.position.y <0 && enemy.parent != nil){
        if (oneTime == 0) {
            oneTime++;
            [self gameOver];

        }
        
    }
    
    
    
}


@end


/*
 
 Ziele für das nächste Update:
 
 - GameOver-Screen Bugs beheben
 - Mute Button wird im Hauptmenü hinzugefügt
 - Eventuell wird der Verlauf von Blau zu Schwarz kürzer eingestellt, da es sehr schwierig ist, durch die schwerer-werdenen Gegner den Sternenhintergrund zu erreichen
 
 - Eventuell wird noch iPad Support hinzugefügt. Alle Elemente skalieren sich zwar ausser die BezierPaths der Gegner.
 Falls es mir gelingt, die Start-, Kontroll- und Endpunkte BezierPaths auf allgemeine Variabeln zu übersetzen, sollte
 PixelPlane auch auf dem iPad ohne Probleme laufen.
 
 */
