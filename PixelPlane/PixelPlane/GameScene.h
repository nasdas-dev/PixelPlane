//
//  GameScene.h
//  PixelPlane
//
//  Created by Dario Safa on 23.05.14.
//  Copyright (c) 2014 Dario A. Safa. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreFoundation/CoreFoundation.h>


@interface GameScene : SKScene <SKPhysicsContactDelegate> {
    
    //HUD & GameSettings
    SKSpriteNode* player1;
    
    SKSpriteNode* startScreen;
    SKSpriteNode* startGame;
    SKSpriteNode* optionsGame;
    SKSpriteNode* backToMenu;
    SKSpriteNode* pauseButton;
    SKSpriteNode* tapStart;
    
    // Sonstige Variabeln für Funktionen/Berechngungen
    int screenWidth;
    int screenHeight;
    int firstTouch;
    int pauseCount;
    int touchCount;
    int hitCount;
    BOOL touchToShoot;
    BOOL touchEnabled;
    BOOL startScreenRemoved;
    
    ////////////////

    //Pause Menü
    SKSpriteNode* pauseBG; //hintergrund
    SKSpriteNode* pauseText; //"Pause"
    SKSpriteNode* cont; //"continue"
    SKSpriteNode* backm;//"back to main menu"
    UIAlertView * alertView; //alert -> main menu
    
    //Pause SKAktions
    BOOL pauseButtonTouch;
    SKAction* pauseLabelAction;
    SKAction* pauseSceneAction;
    SKAction* pauseEndSceneAction;
    SKAction* pauseStart;
    SKAction* pauseEnd;
    
    ////////////////
    
    //Game Over
    int oneTime;
    float offScreen;
    BOOL gameOver;
    SKSpriteNode* tapToRestart;
    SKSpriteNode* gameOverText;
    SKSpriteNode* gameOverRect;

    SKLabelNode* highScoreLabel;
    
    SKAction* restartAction;
    SKAction* restartActionReverse;
    SKAction* restartActionSeq;

    ////////////////
    
    //Audio & Video
    NSUserDefaults* userDefaultsMute;
    SKVideoNode* bgVideo;
    
    SKLabelNode* scoreLabel;
    SKLabelNode* pauseLabel;
    
    AVAudioPlayer* player;
    AVAudioPlayer* bgPlayer;
    int mute;

    /////////////////
    
    //High Score & Speicher
    NSUserDefaults* userDefaults;
    int currentScore;
    int highScore;
    int scoreInt;

    /////////////////

    // Beschleunigungssensor (= MotionManager/Accelerometer)
    CMMotionManager *_motionManager;
    
    // Beschleunigungsvariabel für Accelerometer
    CGFloat _xAcceleration;
    CGFloat _yAcceleration;

    /////////////////

    //SchussPartikel Variabeln
    
    SKAction* moveUp;
    SKAction* remove;
    SKAction* weaponShot;
    SKAction* weaponShotE;
    NSString* myParticlePath;
    NSString* myParticlePathSmoke;

    BOOL weaponActivated;
    
    // Explosion
    SKAction* explodeSequenceGO; // Explosionsequenz-Aktion
    NSString* ExplosionPath;
    SKEmitterNode* Explosion;

    SKEmitterNode* myParticle;
    SKEmitterNode* shipSmoke;

    // EnemyClass
    NSString* EnemyName;
    CGPathRef* path;
    UIBezierPath* enemyPath;
    int enemy1Spawned;
    BOOL isFinished;
    int runLoop;
    float pathSpeed; // Geschwindigkeit der Gegnerbewegung

    SKSpriteNode* enemy;

    SKAction* foreverShootSeq;
    SKAction* addParticle;
    SKAction *waitShoot;
    SKAction* moveDown;
    SKEmitterNode* enemyParticle;
    NSString* enemyParticlePath;
    
    //// Enemy Paths
    CGPathRef pathRef;
    SKAction* followPath;
    SKAction* followPathForever;
    UIBezierPath* bezierPath1;
    UIBezierPath* bezierPath2;
    UIBezierPath* bezierPath3;
    UIBezierPath* bezierPath4;
    UIBezierPath* bezierPath5;
    UIBezierPath* bezierPath6;
    UIBezierPath* bezierPath7;
    UIBezierPath* bezierPath8;
    
    //Spiel Loop (Alle 4 Gegner überstanden -> Loop startet neu)
    int enemyGetsOtherColor; // Gegner Sprites färben sich langsam rot
    BOOL oneTimeAction; // erforderlich damit Gegner im regelmässigem Abstand schiessen
    int timeBetweenShots; // Schussintervall-Zeit (wird nach jeder Gegner Loop kleiner)
    
    //Hintergrundsterne (ab 5min Spielzeit)
    SKAction* starsCountdown;
    SKAction* removeVideo;
    SKAction* removeClouds;
    SKAction* blackBack;
    
    
    SKSpriteNode* blackBG;
    BOOL cloudsStop;
    SKEmitterNode* stars;
    NSString* starsPath;
    
}

@end