//
//  ViewController.m
//  TestARKit
//
//  Created by 曹修远 on 07/09/2017.
//  Copyright © 2017 曹修远. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <ARSCNViewDelegate,ARSessionDelegate,SCNSceneRendererDelegate,SCNPhysicsContactDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

@property (nonatomic, strong) ARSession *arSession;

@property (nonatomic, strong) ARWorldTrackingConfiguration *arSessionConfiguration;

@end

typedef enum : NSUInteger {
    CollisionDetectionMaskBird = 1,     //游戏角色
    CollisionDetectionMaskGround = 2,
    CollisionDetectionMaskStone = 4     //障碍物
} CollisionDetectionMask;

@implementation ViewController{
    SCNScene *mainScene;
    SCNScene *birdScene;
    SCNScene *stoneScene;
    
    SCNNode *ground;
    SCNNode *stone;                     //障碍物
    SCNNode *bird;                      //游戏角色
    SCNText *myTutorialSCNText;
    SCNNode *myTutorialSCNTextNode;
    
    SCNNode *myCurrentScore;            //“目前得分”
    SCNNode *myBestScore;               //“最高得分”
    SCNNode *myCurrentScoreDisplay;     //显示目前分数
    SCNNode *myBestScoreDisplay;        //显示最高分数
    
    SCNNode *myAudioNode;
    
    SCNNode *myAnchorNode;
    
    //    SCNNode *cameraNode;
    
    //生成障碍延迟时间
    NSTimeInterval myFirstTimeGenerateObstacle;
    NSTimeInterval myTimeGenerateObstacle;
    //上一个障碍物
    SCNNode *myLastObstacleNode;
    //上次生成障碍物的时间
    NSTimeInterval myLastObstacleCreationTime;
    
    //游戏状态
    int myMainMenu;
    int myTutorial;
    int myGame;
    int myFall;
    int myDisplayScore;
    int myEndGame;
    
    int myCurrentGameState;
    
    //时间相关
    NSTimeInterval myLastUpdateTime;
    NSTimeInterval myElapsedTime;
    NSTimeInterval myCurrentTime;
    
    //
    float myGravity;//重力
    float myFly;//点击之后上飞
    SCNVector3 myVelocity;//速度
    
    //顶部分数
    int myCurrentScoreNumber;
    
    //BOOL
    BOOL isFall;
    
    //游戏音效
    SCNAction *mySoundFall;
    SCNAction *mySoundFly;
    SCNAction *mySoundGetPoint;
    SCNAction *mySoundHitFrontGround;
    SCNAction *mySoundPop;
    SCNAction *mySoundWhack;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self mySetScene];
    
    
    //delegate
    //    mainScene.physicsWorld.contactDelegate = self;
    self.sceneView.scene.physicsWorld.contactDelegate = self;
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    //初始化一些关键参数
    //生成障碍延迟时间
    myFirstTimeGenerateObstacle = 1.65;
    myTimeGenerateObstacle = 1.75;
    //上次生成障碍物的时间
    myLastObstacleCreationTime = 0;
    //游戏状态
    //    myMainMenu = 0;
    myTutorial = 1;
    myGame = 2;
    myFall = 3;
    myDisplayScore =4;
    myEndGame = 5;
    
    myCurrentGameState = 0;
    //
    myGravity = -0.8;
    myFly = 0.3;
    myVelocity = SCNVector3Zero;
    
    //顶部分数
    myCurrentScoreNumber = 0;;
    
    //游戏音效
#pragma mark 音效加载出现问题
    mySoundFall = [SCNAction playAudioSource:[[SCNAudioSource alloc]initWithFileNamed:@"falling.wav"] waitForCompletion:NO];
    
    //进入教程模式
    [self mySwitchToTutorial];
    
    
    
}




#pragma mark 其他
- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.sceneView.session = self.arSession;
    
    [self.sceneView.session runWithConfiguration:self.arSessionConfiguration];
    //添加返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"Back" forState:UIControlStateNormal];
    btn.frame = CGRectMake(self.view.bounds.size.width*0.25, self.view.bounds.size.height-100, 100, 50);
    btn.backgroundColor = [UIColor grayColor];
    [btn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    //添加重来按钮
    UIButton *btnReset = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnReset setTitle:@"Restart" forState:UIControlStateNormal];
    btnReset.frame = CGRectMake(self.view.bounds.size.width*0.5, self.view.bounds.size.height-100, 100, 50);
    btnReset.backgroundColor = [UIColor grayColor];
    [btnReset addTarget:self action:@selector(myReset:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReset];
}
- (void)back:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)myReset:(UIButton *)btn
{
    [mainScene.rootNode removeFromParentNode];
    [stone removeFromParentNode];
    [self viewDidLoad];
    [myAnchorNode addChildNode:mainScene.rootNode];
    
#pragma mark test
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - AR 会话 和 AR配置
- (ARSession *)arSession {
    if (!_arSession) {
        _arSession = [[ARSession alloc] init];
        _arSession.delegate = self;
    }
    return _arSession;
}

- (ARWorldTrackingConfiguration *)arSessionConfiguration {
    if (!_arSessionConfiguration) {
        _arSessionConfiguration = [[ARWorldTrackingConfiguration alloc] init];
        _arSessionConfiguration.lightEstimationEnabled = YES;
        _arSessionConfiguration.planeDetection = ARPlaneDetectionHorizontal;
    }
    return _arSessionConfiguration;
}

#pragma mark - ARSCNViewDelegate

/*
 // Override to create and configure nodes for anchors added to the view's session.
 - (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
 SCNNode *node = [SCNNode new];
 
 // Add geometry to the node...
 
 return node;
 }
 */

#pragma mark 设置的相关方法
- (void)mySetTutorial{
    isFall = NO;
    [bird runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    myTutorialSCNText = [SCNText textWithString:@"Tap" extrusionDepth:0.05];
    myTutorialSCNText.firstMaterial.diffuse.contents = [UIColor yellowColor];
    myTutorialSCNText.font = [UIFont systemFontOfSize:0.15];
    myTutorialSCNTextNode = [SCNNode nodeWithGeometry:myTutorialSCNText];
    myTutorialSCNTextNode.position = SCNVector3Make(-0.3, -0.5, 0.4);
    [myTutorialSCNTextNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [mainScene.rootNode addChildNode:myTutorialSCNTextNode];
}
- (void)mySetScene{
    // create a new scene
    mainScene = [SCNScene sceneNamed:@"art.scnassets/main.dae"];
    birdScene = [SCNScene sceneNamed:@"art.scnassets/bird.scn"];
    stoneScene = [SCNScene sceneNamed:@"art.scnassets/stone.dae"];
    //node
    ground = [mainScene.rootNode childNodeWithName:@"Cube_016_001" recursively:YES];
    ground.physicsBody = [SCNPhysicsBody staticBody];
    ground.physicsBody.categoryBitMask = CollisionDetectionMaskGround;
    ground.physicsBody.collisionBitMask = 0;
    ground.physicsBody.contactTestBitMask = CollisionDetectionMaskBird;
    
    
}
- (void)mySetGameCharacter{
    bird = [birdScene.rootNode childNodeWithName:@"bird" recursively:YES];
    bird.physicsBody = [SCNPhysicsBody staticBody];
    bird.physicsBody.categoryBitMask = CollisionDetectionMaskBird;
    bird.physicsBody.collisionBitMask = 0;
    bird.physicsBody.contactTestBitMask = CollisionDetectionMaskGround | CollisionDetectionMaskStone;
    bird.position = SCNVector3Make(0, 0.2, 0);
    [mainScene.rootNode addChildNode:bird];
}
- (void)mySetScore{
    SCNText *myCurrentScoreSCNText = [SCNText textWithString:@"Score:" extrusionDepth:0.05];
    SCNText *myBestScoreSCNText = [SCNText textWithString:@"Best:" extrusionDepth:0.05];
    myCurrentScoreSCNText.firstMaterial.diffuse.contents = [UIColor redColor];
    myCurrentScoreSCNText.font = [UIFont systemFontOfSize:0.10];
    myBestScoreSCNText.firstMaterial.diffuse.contents = [UIColor redColor];
    myBestScoreSCNText.font = [UIFont systemFontOfSize:0.10];
    myCurrentScore = [SCNNode nodeWithGeometry:myCurrentScoreSCNText];
    myBestScore = [SCNNode nodeWithGeometry:myBestScoreSCNText];
    //    myCurrentScore.position = SCNVector3Make(-0.5, 0,0);
    //    myBestScore.position = SCNVector3Make(-0.5, -0.1,0);
    myCurrentScore.position = SCNVector3Make(-0.5, -0.5,0);
    myBestScore.position = SCNVector3Make(-0.5, -0.65,0);
    [myCurrentScore runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [myBestScore runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [mainScene.rootNode addChildNode:myCurrentScore];
    [mainScene.rootNode addChildNode:myBestScore];
    
    SCNText *myCurrentScoreDisplaySCNText = [SCNText textWithString:@"0" extrusionDepth:0.05];
    NSString *tmp = [NSString stringWithFormat:@"%ld",(long)[self myBest]];
    SCNText *myBestScoreDisplaySCNText = [SCNText textWithString:tmp extrusionDepth:0.05];
    myCurrentScoreDisplaySCNText.firstMaterial.diffuse.contents = [UIColor redColor];
    myCurrentScoreDisplaySCNText.font = [UIFont systemFontOfSize:0.10];
    myBestScoreDisplaySCNText.firstMaterial.diffuse.contents = [UIColor redColor];
    myBestScoreDisplaySCNText.font = [UIFont systemFontOfSize:0.10];
    myCurrentScoreDisplay = [SCNNode nodeWithGeometry:myCurrentScoreDisplaySCNText];
    myBestScoreDisplay = [SCNNode nodeWithGeometry:myBestScoreDisplaySCNText];
    //    myCurrentScoreDisplay.position = SCNVector3Make(0.1, 0,0);
    //    myBestScoreDisplay.position = SCNVector3Make(0.1, -0.1,0);
    myCurrentScoreDisplay.position = SCNVector3Make(0.1, -0.5,0);
    myBestScoreDisplay.position = SCNVector3Make(0.1, -0.65,0);
    [myCurrentScoreDisplay runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [myBestScoreDisplay runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    [mainScene.rootNode addChildNode:myCurrentScoreDisplay];
    [mainScene.rootNode addChildNode:myBestScoreDisplay];
    
}
#pragma mark 游戏事件

//障碍生成
- (void)myGenerateObstacle{
    if (!stone) {
        stone = [stoneScene.rootNode childNodeWithName:@"stone" recursively:YES];
    } else {
        stone = [stone clone];
    }
}
//无限生成障碍
- (void)myInfiniteGenerateObstacle{
    int myRandomValue = arc4random()% 6 + 1; //取随机数
    float myCoefficient = 0.0;
    switch (myRandomValue) {
        case 1:
            myCoefficient = 0;
            break;
        case 2:
            myCoefficient = 0.01;
            break;
        case 3:
            myCoefficient = 0.02;
            break;
        case 4:
            myCoefficient = 0.03;
            break;
        case 5:
            myCoefficient = 0.04;
            break;
        case 6:
            myCoefficient = 0.05;
            break;
            
        default:
            
            break;
    }
    
    [self myGenerateObstacle];
    
    stone.position = SCNVector3Make(0, 0.05 + myCoefficient, -0.8);
    SCNNode *stoneTop = [stone clone];
    stoneTop.position = SCNVector3Make(0, stone.position.y + 0.35, stone.position.z);
    
    SCNAction *stoneMoveAction = [SCNAction moveTo:SCNVector3Make(0, stone.position.y, 0.8) duration:3.5];
    SCNAction *stoneTopMoveAction = [SCNAction moveTo:SCNVector3Make(0, stoneTop.position.y, 0.8) duration:3.5];
    SCNAction *removeNodeAction = [SCNAction removeFromParentNode];
    
    SCNAction *stoneAction = [SCNAction sequence:@[stoneMoveAction,removeNodeAction]];
    SCNAction *stoneTopAction = [SCNAction sequence:@[stoneTopMoveAction,removeNodeAction]];
    
    
    
    [stone runAction:stoneAction];
    [stoneTop runAction:stoneTopAction];
    
    stone.physicsBody = [SCNPhysicsBody staticBody];
    stone.physicsBody.categoryBitMask = CollisionDetectionMaskStone;
    stone.physicsBody.collisionBitMask = 0;
    stone.physicsBody.contactTestBitMask = CollisionDetectionMaskBird;
    
    [mainScene.rootNode addChildNode:stone];
    [mainScene.rootNode addChildNode:stoneTop];
}
- (void)myStopGenerateObstacle{
    
    [stone removeAllActions];
    //    stone.position = SCNVector3Make(stone.position.x, stone.position.y, stone.position.z);
    
}
- (void)myGameCharacterFly{
    if (isFall == NO) {
        myVelocity =SCNVector3Make(0, myFly, 0);
    }
    
    
}
#pragma mark 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"myCurrentGameState:%d",myCurrentGameState);
    switch (myCurrentGameState) {
        case 0:                 //忽略用户点击
            break;
        case 1:                 //Tutorial
            [self mySwitchToGame];
            break;
        case 2:                 //Game
            [self myGameCharacterFly];
            break;
        case 3:                 //Fall
            [self mySwitchToEndGame];
            break;
            //        case 4:
            //
            //            break;
        case 5:                 //EndGame
            [self mySwitchToNewGame];
            break;
            
        default:
            break;
    }
    
}
#pragma mark 更新的相关方法
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time{
    
    //    NSLog(@"stone.z:%f",stone.position.z);
    //    NSLog(@"bird.y:%f",bird.position.y);
    
    //    NSLog(@"bird.y:%f",bird.presentationNode.position.y);
    
    myCurrentTime = time;
    if (myLastUpdateTime > 0) {
        myElapsedTime = time - myLastUpdateTime;
    } else {
        myElapsedTime = 0;
    }
    myLastUpdateTime = time;
    switch (myCurrentGameState) {
        case 1:                 //Tutorial
            
            break;
        case 2:                 //Game
            if (time > (myTimeGenerateObstacle + myLastObstacleCreationTime)) {
                [self myInfiniteGenerateObstacle];
                myLastObstacleCreationTime = time;
                
            }
            [self myUpdateGameCharacter];
            [self myHitCheck];
            [self myUpdateScore];
            break;
        case 3:                 //Fall
            
            [self myStopGenerateObstacle];
            [self myHitCheck];
            break;
        case 5:                 //EndGame
            break;
            
        default:
            break;
    }
    
}

-(void)myUpdateGameCharacter{
    SCNVector3 kAcceleratedVelocity = SCNVector3Make(0, myGravity, 0);
    myVelocity = SCNVector3Make(myVelocity.x + kAcceleratedVelocity.x * (CGFloat) myElapsedTime, myVelocity.y + kAcceleratedVelocity.y * (CGFloat) myElapsedTime, myVelocity.z + kAcceleratedVelocity.z * (CGFloat) myElapsedTime);
    
    bird.position = SCNVector3Make(bird.position.x + myVelocity.x * (CGFloat) myElapsedTime, bird.position.y + myVelocity.y * (CGFloat) myElapsedTime, bird.position.z + myVelocity.z * (CGFloat) myElapsedTime);
}
- (void)myHitCheck{
    if (bird.position.y >= 0.4 ) {
        //        bird.position = SCNVector3Make(bird.position.x, 0.35 , bird.position.z);
        [bird runAction:[SCNAction moveTo:SCNVector3Make(bird.position.x, 0.35 , bird.position.z) duration:0.1]];
    }
    if (bird.position.y <= 0) {
        bird.position = SCNVector3Make(bird.position.x, 0 , bird.position.z);
        [bird removeAllActions];
    }
}
- (void)myUpdateScore{
    //    NSString *passObstacle = @"已通过";
    //    NSLog(@"stone.z:%f",stone.position.z);
    //    NSLog(@"bird.y:%f",bird.position.z);
    //    NSLog(@"stone.z:%f",stone.parentNode.position.z);
    //    NSLog(@"bird.y:%f",bird.parentNode.position.z);
    
    if (stone.position.z >= bird.position.z - 0.02) {
        myCurrentScoreNumber ++;
        NSLog(@"分数++");
        NSLog(@"myCurrentScoreNumber:%d",myCurrentScoreNumber);
        
        [myCurrentScoreDisplay removeFromParentNode];
        SCNText *myCurrentScoreDisplaySCNText = [SCNText textWithString:[NSString stringWithFormat:@"%d",myCurrentScoreNumber] extrusionDepth:0.05];
        myCurrentScoreDisplaySCNText.firstMaterial.diffuse.contents = [UIColor redColor];
        myCurrentScoreDisplaySCNText.font = [UIFont systemFontOfSize:0.10];
        myCurrentScoreDisplay = [SCNNode nodeWithGeometry:myCurrentScoreDisplaySCNText];
        myCurrentScoreDisplay.position = SCNVector3Make(0.1, -0.5,0);
        [myCurrentScoreDisplay runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
        [mainScene.rootNode addChildNode:myCurrentScoreDisplay];
    }
    
    if (myCurrentScoreNumber > [self myBest]) {
        [self mySetBest:myCurrentScoreNumber];
        [myBestScoreDisplay removeFromParentNode];
        SCNText *myBestScoreDisplaySCNText = [SCNText textWithString:[NSString stringWithFormat:@"%d",myCurrentScoreNumber] extrusionDepth:0.05];
        myBestScoreDisplaySCNText.firstMaterial.diffuse.contents = [UIColor redColor];
        myBestScoreDisplaySCNText.font = [UIFont systemFontOfSize:0.10];
        myBestScoreDisplay = [SCNNode nodeWithGeometry:myBestScoreDisplaySCNText];
        myBestScoreDisplay.position = SCNVector3Make(0.1, -0.65,0);
        [myBestScoreDisplay runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
        [mainScene.rootNode addChildNode:myBestScoreDisplay];
    }
    
    
}
#pragma mark 游戏状态
- (void)mySwitchToTutorial{
    myCurrentGameState = myTutorial;
    
    [self mySetGameCharacter];
    [self mySetScore];
    [self mySetTutorial];
    
}
- (void)mySwitchToGame{
    myCurrentGameState = myGame;
    [myTutorialSCNTextNode removeFromParentNode];
    [self myInfiniteGenerateObstacle];
    [self myGameCharacterFly];
    
}
- (void)mySwitchToFall{
    myCurrentGameState = myFall;
    [bird runAction:[SCNAction moveTo:SCNVector3Make(bird.position.x, 0, bird.position.z) duration:0.5]];
    [myAudioNode runAction:mySoundFall];
    
}
- (void)mySwitchToEndGame{
    myCurrentGameState = myEndGame;
    [self mySwitchToNewGame];
}
- (void)mySwitchToNewGame{
    
    myCurrentGameState = myTutorial;
    myCurrentGameState = 0;//有了Restart按钮，所以不用其他的设置了。此处应该设为0，用户点击后不会有反应。用户按Restart之后运行 viewDidLoad
    isFall = NO;
    //顶部分数
    myCurrentScoreNumber = 0;
    
}
#pragma mark 持久化存储
//最高分
- (NSInteger)myBest{
    return [NSUserDefaults.standardUserDefaults integerForKey:@"AR模式最高分"];
}
- (void)mySetBest:(NSInteger)myBest{
    [NSUserDefaults.standardUserDefaults setInteger:myBest forKey:@"AR模式最高分"];
    [NSUserDefaults.standardUserDefaults synchronize];
}
#pragma mark 碰撞检测
- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact{
    //    NSLog(@"##Begin Contact##");
    isFall = YES;
    
    [self mySwitchToFall];
    
    myCurrentGameState = 0;//此处应该设为0，用户点击后不会有反应。
}

#pragma mark - 添加锚点
- (void)renderer:(id <SCNSceneRenderer>)renderer
      didAddNode:(SCNNode *)node
       forAnchor:(ARAnchor *)anchor {
    if ([anchor isMemberOfClass:[ARPlaneAnchor class]]) {
        NSLog(@"捕捉到");
        
        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
        
        SCNBox *planeBox = [SCNBox boxWithWidth:planeAnchor.extent.x*0.2
                                         height:0
                                         length:planeAnchor.extent.x*0.2
                                  chamferRadius:0];
        
        SCNNode *planeNode = [SCNNode nodeWithGeometry:planeBox];
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
        [node addChildNode:planeNode];
        
        //添加场景
        
        //        SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/main.dae"];
        //        //        SCNNode *cupNode = scene.rootNode.childNodes[0];
        //        SCNNode *mySceneNode = scene.rootNode;
        //
        //        mySceneNode.position = SCNVector3Make(planeAnchor.center.x,0, planeAnchor.center.z);
        //
        //        [node addChildNode:mySceneNode];
        //
        //        SCNScene *birdScene = [SCNScene sceneNamed:@"art.scnassets/bird.scn"];
        //        SCNNode *birdNode = birdScene.rootNode.childNodes[0];
        //        birdNode.position = SCNVector3Make(planeAnchor.center.x,0, planeAnchor.center.z);
        //        [node addChildNode:birdNode];
        
        
        [node addChildNode:mainScene.rootNode];
        
        myAnchorNode = node;
        
    }
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

#pragma mark - ARSessionDelegate
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    //    NSLog(@"相机移动");
}

- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors {
    NSLog(@"添加锚点");
}

- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor*>*)anchors {
    NSLog(@"更新锚点");
}

- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors {
    NSLog(@"移除锚点");
}

@end

