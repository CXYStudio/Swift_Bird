//
//  GameScene.m
//  test
//
//  Created by 曹修远 on 07/09/2017.
//  Copyright © 2017 曹修远. All rights reserved.
//

// Degrees to radians
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#import "GameScene.h"
//typedef enum _myCoverage{
//    myBackGround,
//    myObstacle,
//    myFrontGround,
//    myGameCharacter
//    myGameCharacterHat,
//}myCoverage;

//struct myPhysics {
//    UInt32 physicsNone;
//    UInt32 physicsGameCharacter;
//    UInt32 physicsObstacle;
//    UInt32 physicsFrontGround;

//};


@implementation GameScene {
    SKNode *myWorldNode;
    CGFloat myGameStartPoint;
    CGFloat myGameRegionHeight;
    SKSpriteNode *myGameCharacter;
    SKSpriteNode *myGameCharacterHat;
    NSTimeInterval myLastUpdateTime;
    NSTimeInterval myElapsedTime;
    CGFloat myGravity;//重力
    CGFloat myFly;//点击之后上飞
    CGPoint myVelocity;//速度
    
    CGFloat myFrontGroundTotal;
    CGFloat myFrontGroundVelocity;
    
    SKSpriteNode *myBackGround;
    SKSpriteNode *myFrontGround;
    
    //障碍物的最大最小范围
    CGFloat myMinimumCoefficient;
    CGFloat myMaximumCoefficient;
    
    //缺口系数
    CGFloat myGapCoefficient;
    
    //生成障碍延迟时间
    NSTimeInterval myFirstTimeGenerateObstacle;
    NSTimeInterval myTimeGenerateObstacle;
    
    //physics
    UInt32 physicsNone;
    UInt32 physicsGameCharacter;
    UInt32 physicsObstacle;
    UInt32 physicsFrontGround;
    
    //BOOL
    BOOL myHitFrontGround;
    BOOL myHitObstacle;
    
    //游戏状态
    CGFloat myMainMenu;
    CGFloat myTutorial;
    CGFloat myGame;
    CGFloat myFall;
    CGFloat myDisplayScore;
    CGFloat myEndGame;
    
    CGFloat myCurrentGameState;
    
    //游戏音效
    SKAction *mySoundFall;
}


- (void)didMoveToView:(SKView *)view {
    //关闭重力
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    //代理
    self.physicsWorld.contactDelegate = self;
    
    
    // Setup scene 设置场景
    myWorldNode = [[SKNode alloc]init];
    [self addChild:myWorldNode];
    
    myGravity = -1000;
    myFly = 500;
    myVelocity = CGPointZero;
    
    myFrontGroundTotal = 2;// 循环地面
    myFrontGroundVelocity = -150;
    
    //障碍物的最大最小范围
    myMinimumCoefficient = 0.1;
    myMaximumCoefficient = 0.6;
    
    myGapCoefficient = 3.5;
    
    //生成障碍延迟时间
    myFirstTimeGenerateObstacle = 1.65;
    myTimeGenerateObstacle = 1.75;
    
    //physics
    physicsNone = 0;                //0
    physicsGameCharacter = 0b1;     //1
    physicsObstacle = 0b10;         //2
    physicsFrontGround = 0b100;     //4
    
    myHitFrontGround = NO;
    myHitObstacle = NO;
    
    //游戏状态
    myMainMenu = 0;
    myTutorial = 1;
    myGame = 2;
    myFall = 3;
    myDisplayScore =4;
    myEndGame = 5;
    
    myCurrentGameState = 2;
    
    //游戏音效
    mySoundFall = [SKAction playSoundFileNamed:@"falling.wav" waitForCompletion:NO];

    
    
    [self mySetBackGround];
    [self mySetFrontGround];
    [self mySetGameCharacter];
    [self myInfiniteGenerateObstacle];
    [self mySetGameCharacterHat];
    
    //test code
//    int myRandomValue = arc4random()% 6 + 1;
//    NSLog(@"%d",myRandomValue);
//    
    
}

#pragma mark 设置的相关方法
- (void)mySetBackGround{
    
    myBackGround = [[SKSpriteNode alloc]initWithImageNamed:@"Background"];
    
    myBackGround.anchorPoint = CGPointMake(0.5, 1.0);
    myBackGround.position = CGPointMake(self.size.width/2, self.size.height);
    myBackGround.zPosition = 0;
    myBackGround.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*0.7);
    
    [myWorldNode addChild:myBackGround];
    
    myGameStartPoint = self.view.frame.size.height - myBackGround.size.height;
    myGameRegionHeight = myBackGround.size.height;
    
    CGPoint myLeftX = CGPointMake(0, myGameStartPoint);
    CGPoint myRightX = CGPointMake(self.size.width, myGameStartPoint);
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:myLeftX toPoint:myRightX];
    self.physicsBody.categoryBitMask = physicsFrontGround;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = physicsGameCharacter;
    
}

- (void)mySetFrontGround{

    for (int i = 0; i < myFrontGroundTotal; i++) {
        myFrontGround = [[SKSpriteNode alloc]initWithImageNamed:@"Ground"];
        
        myFrontGround.anchorPoint = CGPointMake(0, 1.0);
//        myFrontGround.position = CGPointMake((CGFloat)i * myFrontGround.size.width, myGameStartPoint);
        myFrontGround.position = CGPointMake((CGFloat)i * self.view.frame.size.width, myGameStartPoint);
        myFrontGround.zPosition = 2;
        myFrontGround.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*0.3);
        myFrontGround.name = @"前地面";
        [myWorldNode addChild:myFrontGround];
        NSLog(@"第%d个前地面Set",i);
    }
    
    
//    //test code
//    for (int i = 0; i < myFrontGroundTotal; i++) {
//        if (i == 1) {
//            myFrontGround = [[SKSpriteNode alloc]initWithImageNamed:@"Ground"];
//            
//            myFrontGround.anchorPoint = CGPointMake(0, 1.0);
//            //        myFrontGround.position = CGPointMake((CGFloat)i * myFrontGround.size.width, myGameStartPoint);
//            myFrontGround.position = CGPointMake((CGFloat)i * self.view.frame.size.width, myGameStartPoint);
//            myFrontGround.zPosition = 1;
//            myFrontGround.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*0.3);
//            myFrontGround.name = @"前地面";
//            myFrontGround.alpha = 0.5;
//            [myWorldNode addChild:myFrontGround];
//            NSLog(@"第%d个前地面Set",i);
//        } else {
//            myFrontGround = [[SKSpriteNode alloc]initWithImageNamed:@"Ground"];
//            
//            myFrontGround.anchorPoint = CGPointMake(0, 1.0);
//            //        myFrontGround.position = CGPointMake((CGFloat)i * myFrontGround.size.width, myGameStartPoint);
//            myFrontGround.position = CGPointMake((CGFloat)i * self.view.frame.size.width, myGameStartPoint);
//            myFrontGround.zPosition = 1;
//            myFrontGround.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*0.3);
//            myFrontGround.name = @"前地面";
//            [myWorldNode addChild:myFrontGround];
//            NSLog(@"第%d个前地面Set",i);
//        }
//        
//    }
//    //end test
    

}

- (void)mySetGameCharacter{
    myGameCharacter = [[SKSpriteNode alloc]initWithImageNamed:@"Bird0"];
    myGameCharacter.position = CGPointMake(self.view.frame.size.width*0.2, myGameRegionHeight*0.4 + myGameStartPoint);
    myGameCharacter.zPosition = 3;
    
    //
    CGFloat offsetX = myGameCharacter.frame.size.width * myGameCharacter.anchorPoint.x;
    CGFloat offsetY = myGameCharacter.frame.size.height * myGameCharacter.anchorPoint.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 3 - offsetX, 16 - offsetY);
    CGPathAddLineToPoint(path, NULL, 19 - offsetX, 24 - offsetY);
    CGPathAddLineToPoint(path, NULL, 38 - offsetX, 26 - offsetY);
    CGPathAddLineToPoint(path, NULL, 37 - offsetX, 25 - offsetY);
    CGPathAddLineToPoint(path, NULL, 38 - offsetX, 20 - offsetY);
    CGPathAddLineToPoint(path, NULL, 38 - offsetX, 15 - offsetY);
    CGPathAddLineToPoint(path, NULL, 39 - offsetX, 10 - offsetY);
    CGPathAddLineToPoint(path, NULL, 38 - offsetX, 6 - offsetY);
    CGPathAddLineToPoint(path, NULL, 36 - offsetX, 3 - offsetY);
    CGPathAddLineToPoint(path, NULL, 30 - offsetX, 1 - offsetY);
    CGPathAddLineToPoint(path, NULL, 21 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 15 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 9 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 5 - offsetX, 0 - offsetY);
    CGPathAddLineToPoint(path, NULL, 2 - offsetX, 2 - offsetY);
    CGPathAddLineToPoint(path, NULL, 2 - offsetX, 7 - offsetY);
    CGPathAddLineToPoint(path, NULL, 1 - offsetX, 11 - offsetY);
    CGPathAddLineToPoint(path, NULL, 2 - offsetX, 14 - offsetY);
    CGPathAddLineToPoint(path, NULL, 27 - offsetX, 28 - offsetY);
    
    CGPathCloseSubpath(path);
    
    myGameCharacter.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    myGameCharacter.physicsBody.categoryBitMask = physicsGameCharacter;
    myGameCharacter.physicsBody.collisionBitMask = 0;
    myGameCharacter.physicsBody.contactTestBitMask = physicsObstacle | physicsFrontGround;
    
    
    [myWorldNode addChild:myGameCharacter];
    
}

- (void)mySetGameCharacterHat{
    myGameCharacterHat = [[SKSpriteNode alloc]initWithImageNamed:@"Hat"];
    myGameCharacterHat.position = CGPointMake(myGameCharacter.size.width/4, myGameCharacter.size.height/2);
    myGameCharacterHat.zPosition = 4;
    [myGameCharacter addChild:myGameCharacterHat];
}

#pragma mark 游戏事件
- (SKSpriteNode *)myCreateObstacle:(NSString *)myPNG{//创建障碍物
    SKSpriteNode *myObstacle = [[SKSpriteNode alloc]initWithImageNamed:myPNG];
    myObstacle.zPosition = 1;
    
    CGFloat offsetX = myObstacle.frame.size.width * myObstacle.anchorPoint.x;
    CGFloat offsetY = myObstacle.frame.size.height * myObstacle.anchorPoint.y;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 1 - offsetX, 1 - offsetY);
    CGPathAddLineToPoint(path, NULL, 3 - offsetX, 312 - offsetY);
    CGPathAddLineToPoint(path, NULL, 9 - offsetX, 314 - offsetY);
    CGPathAddLineToPoint(path, NULL, 25 - offsetX, 314 - offsetY);
    CGPathAddLineToPoint(path, NULL, 37 - offsetX, 314 - offsetY);
    CGPathAddLineToPoint(path, NULL, 45 - offsetX, 313 - offsetY);
    CGPathAddLineToPoint(path, NULL, 49 - offsetX, 310 - offsetY);
    CGPathAddLineToPoint(path, NULL, 50 - offsetX, 307 - offsetY);
    CGPathAddLineToPoint(path, NULL, 50 - offsetX, 1 - offsetY);
    
    CGPathCloseSubpath(path);
    
    myObstacle.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
    myObstacle.physicsBody.categoryBitMask = physicsObstacle;
    myObstacle.physicsBody.collisionBitMask = 0;
    myObstacle.physicsBody.contactTestBitMask = physicsGameCharacter;
    return myObstacle;
}

//顶部和底部障碍生成
- (void)myGenerateObstacle{
    
    //Bottom
    SKSpriteNode *myBottom = [self myCreateObstacle:@"Bottom"];
//    CGFloat myStartXCoordinate = self.size.width/2;
    CGFloat myStartXCoordinate = self.size.width + myBottom.size.width/2;
    
    int myRandomValue = arc4random()% 6 + 1; //取随机数
    float myCoefficient = 0.0;
    switch (myRandomValue) {
        case 1:
            myCoefficient = 0.2;
            break;
        case 2:
            myCoefficient = 0.25;
            break;
        case 3:
            myCoefficient = 0.3;
            break;
        case 4:
            myCoefficient = 0.4;
            break;
        case 5:
            myCoefficient = 0.5;
            break;
        case 6:
            myCoefficient = 0.6;
            break;
            
        default:
            
            break;
    }
//    CGFloat myYMin = myGameStartPoint - myBottom.size.height/2 + myGameRegionHeight * myMinimumCoefficient;
//    CGFloat myYMax = myGameStartPoint - myBottom.size.height/2 + myGameRegionHeight * myMaximumCoefficient;
    CGFloat myY = myGameStartPoint - myBottom.size.height/2 + myGameRegionHeight * myCoefficient;
    myBottom.position = CGPointMake(myStartXCoordinate, myY);
    myBottom.name = @"底部障碍";
    [myWorldNode addChild:myBottom];
    
    
    //Top
    SKSpriteNode *myTop = [self myCreateObstacle:@"Top"];
    myTop.zRotation = DEGREES_TO_RADIANS(180);
    myTop.position = CGPointMake(myStartXCoordinate, myBottom.position.y + myBottom.size.height/2 + myTop.size.height/2 + myGameCharacter.size.height * myGapCoefficient);
    myTop.name = @"顶部障碍";
    [myWorldNode addChild:myTop];
    
    //Move
    CGFloat myXCoordinateMoveDistance = -(self.size.width + myBottom.size.width);
    CGFloat myMoveTime = myXCoordinateMoveDistance / myFrontGroundVelocity;
    
    
    SKAction *myMoveAction1 = [SKAction moveByX:myXCoordinateMoveDistance y:0 duration:myMoveTime];
    SKAction *myMoveAction2 = [SKAction removeFromParent];
    SKAction *myMoveAction = [SKAction sequence:@[myMoveAction1,myMoveAction2]];
    
    [myBottom runAction:myMoveAction];

    [myTop runAction:myMoveAction];
    
    
}

//无限生成障碍
- (void)myInfiniteGenerateObstacle{
    SKAction *myFirst = [SKAction waitForDuration:myFirstTimeGenerateObstacle];
    SKAction *myRegenerateObstacle = [SKAction runBlock:^{
        [self myGenerateObstacle];
    }];
    SKAction *myGenerateObstacleTimeGap = [SKAction waitForDuration:myTimeGenerateObstacle];
    SKAction *myRegenerateObstacleSequence = [SKAction sequence:@[myRegenerateObstacle,myGenerateObstacleTimeGap]];
    SKAction *myInfiniteGenerate = [SKAction repeatActionForever:myRegenerateObstacleSequence];
    SKAction *myAllGenerateObstacleSequence = [SKAction sequence:@[myFirst,myInfiniteGenerate]];
    
    [self runAction:myAllGenerateObstacleSequence withKey:@"重生"];
}

- (void)myStopGenerateObstacle{
    [self removeActionForKey:@"重生"];
    
    [myWorldNode enumerateChildNodesWithName:@"底部障碍" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeAllActions];
    }];
    
    [myWorldNode enumerateChildNodesWithName:@"顶部障碍" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeAllActions];
    }];
    
    
}

//myGameCharacter & myGameCharacterHat 飞一下效果
- (void)myGameCharacterFly{
    
    myVelocity = CGPointMake(0, myFly);
    
}
- (void)myGameCharacterHatFly{
    
    SKAction *myUpMove = [SKAction moveByX:0 y:18 duration:0.15];
    [myUpMove setTimingMode:SKActionTimingEaseInEaseOut];
    SKAction *myDownMove = [myUpMove reversedAction];
    SKAction *myAllHatFly = [SKAction sequence:@[myUpMove, myDownMove]];
    
    [myGameCharacterHat runAction:myAllHatFly];
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //点击屏幕，GameCharacter向上飞
    [self myGameCharacterFly];
    
    //帽子飞一下的效果
    [self myGameCharacterHatFly];
    
}

#pragma mark 更新的相关方法

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    if (myLastUpdateTime > 0) {
        myElapsedTime = currentTime - myLastUpdateTime;
    } else {
        myElapsedTime = 0;
    }
    myLastUpdateTime = currentTime;
    
    [self myUpdateGameCharacter];
    [self myUpdateFrontGround];
    
    [self myHitObstacleCheck];

}
-(void)myUpdateGameCharacter{
    CGPoint kAcceleratedVelocity = CGPointMake(0, myGravity);
    myVelocity = CGPointMake(myVelocity.x + kAcceleratedVelocity.x * (CGFloat) myElapsedTime, myVelocity.y + kAcceleratedVelocity.y * (CGFloat) myElapsedTime);
    
    myGameCharacter.position = CGPointMake(myGameCharacter.position.x + myVelocity.x * (CGFloat) myElapsedTime, myGameCharacter.position.y + myVelocity.y * (CGFloat) myElapsedTime);
    
    //Ground
    if (myGameCharacter.position.y - myGameCharacter.size.height/2 < myGameStartPoint) {
        myGameCharacter.position = CGPointMake(myGameCharacter.position.x, myGameStartPoint + myGameCharacter.size.height/2);
    }
    
}
-(void)myUpdateFrontGround{
    
    [myWorldNode enumerateChildNodesWithName:@"前地面" usingBlock:^(SKNode *node, BOOL *stop) {
        
        if ([node.name isEqual: @"前地面"]) {
            CGPoint myNewFrontGroundVelocity = CGPointMake(myFrontGroundVelocity, 0);
            node.position = CGPointMake(node.position.x + myNewFrontGroundVelocity.x * (CGFloat)myElapsedTime, node.position.y + myNewFrontGroundVelocity.y * (CGFloat)myElapsedTime);
            if (node.position.x < - myFrontGround.size.width) {
                node.position = CGPointMake(node.position.x + myFrontGround.size.width * myFrontGroundTotal, node.position.y + 0);
            }
            
            
//            myFrontGround.position = CGPointMake(myFrontGround.position.x + myNewFrontGroundVelocity.x * (CGFloat)myElapsedTime, myFrontGround.position.y + myNewFrontGroundVelocity.y * (CGFloat)myElapsedTime);
//            NSLog(@"FrontGround:%f",myFrontGround.position.x);
            
//            NSLog(@"%f",myFrontGround.position.x);
            
//            if (myFrontGround.position.x < - myFrontGround.size.width) {
//                myFrontGround.position = CGPointMake(myFrontGround.position.x + myFrontGround.size.width * myFrontGroundTotal, myFrontGround.position.y + 0);
//            }
        }
        
//        NSLog(@"BLOCK: %@", [node name]);
     
    }];
    
    
}
- (void)myHitObstacleCheck{
    if (myHitObstacle == YES) {
        myHitObstacle = NO;
        //切换到跌落状态
        [self mySwitchToFall];
    }
}
#pragma mark 游戏状态
- (void)mySwitchToFall{
    myCurrentGameState = myFall;
    SKAction *myWait = [SKAction waitForDuration:0.1];
    SKAction *myFallSequence = [SKAction sequence:@[mySoundFall,myWait]];
    
    [self runAction:myFallSequence];
    
    [myGameCharacter removeAllActions];
    
    [self myStopGenerateObstacle];
    
    
    
}
- (void)didBeginContact:(SKPhysicsContact *)contact{
    
    SKPhysicsBody *myBeHitObj = [[SKPhysicsBody alloc]init];
    
//    NSLog(@"contact.bodyA.contactTestBitMask:%u",contact.bodyA.contactTestBitMask);
//    NSLog(@"contact.bodyB.contactTestBitMask:%u",contact.bodyB.contactTestBitMask);
//    
//    NSLog(@"contact.bodyA.categoryBitMask:%u",contact.bodyA.categoryBitMask);
//    NSLog(@"contact.bodyB.categoryBitMask:%u",contact.bodyB.categoryBitMask);
    
    if (contact.bodyA.contactTestBitMask == physicsGameCharacter) {
        myBeHitObj =  contact.bodyA;
        
    } else {
        myBeHitObj =  contact.bodyB;
    }
//    NSLog(@"myBeHitObj.categoryBitMask:%u",myBeHitObj.categoryBitMask);
    if (myBeHitObj.categoryBitMask == physicsFrontGround) {
        myHitFrontGround = YES;
        NSLog(@"撞击地面");
    }
    if (myBeHitObj.categoryBitMask == physicsObstacle) {
        myHitObstacle = YES;
        NSLog(@"撞击障碍");
    }

    
}
@end
