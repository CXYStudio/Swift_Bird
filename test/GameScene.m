//
//  GameScene.m
//  test
//
//  Created by 曹修远 on 07/09/2017.
//  Copyright © 2017 曹修远. All rights reserved.
//

#import "GameScene.h"
//typedef enum _myCoverage{
//    myBackGround,
//    myFrontGround,
//    myGameCharacter
//}myCoverage;

@implementation GameScene {
    
    SKNode *myWorldNode;
    CGFloat myGameStartPoint;
    CGFloat myGameRegionHeight;
    SKSpriteNode *myGameCharacter;
    NSTimeInterval myLastUpdateTime;
    NSTimeInterval myElapsedTime;
    CGFloat myGravity;//重力
    CGFloat myFly;//点击之后上飞
    CGPoint myVelocity;//速度
    
    CGFloat myFrontGroundTotal;
    CGFloat myFrontGroundVelocity;
    
    SKSpriteNode *myBackGround;
    SKSpriteNode *myFrontGround;
}


- (void)didMoveToView:(SKView *)view {
    // Setup scene 设置场景
    myWorldNode = [[SKNode alloc]init];
    [self addChild:myWorldNode];
    
    myGravity = -1000;
    myFly = 500;
    myVelocity = CGPointZero;
    
    myFrontGroundTotal = 2;// 循环地面
    myFrontGroundVelocity = -150;
    
    [self mySetBackGround];
    [self mySetFrontGround];
    [self mySetGameCharacter];
    
    
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
}

- (void)mySetFrontGround{

    for (int i = 0; i < myFrontGroundTotal; i++) {
        myFrontGround = [[SKSpriteNode alloc]initWithImageNamed:@"Ground"];
        
        myFrontGround.anchorPoint = CGPointMake(0, 1.0);
//        myFrontGround.position = CGPointMake((CGFloat)i * myFrontGround.size.width, myGameStartPoint);
        myFrontGround.position = CGPointMake((CGFloat)i * self.view.frame.size.width, myGameStartPoint);
        myFrontGround.zPosition = 1;
        myFrontGround.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*0.3);
        myFrontGround.name = @"前地面";
        [myWorldNode addChild:myFrontGround];
        NSLog(@"第%d个前地面Set",i);
    }

}

- (void)mySetGameCharacter{
    myGameCharacter = [[SKSpriteNode alloc]initWithImageNamed:@"Bird0"];
    myGameCharacter.position = CGPointMake(self.view.frame.size.width*0.2, myGameRegionHeight*0.4 + myGameStartPoint);
    myGameCharacter.zPosition = 2;
    
    [self addChild:myGameCharacter];
    
}

#pragma mark 游戏事件
- (void)myGameCharacterFly{
    
    myVelocity = CGPointMake(0, myFly);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self myGameCharacterFly];
    
    
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
        
        if ([node.name  isEqual: @"前地面"]) {
            CGPoint myNewFrontGroundVelocity = CGPointMake(myFrontGroundVelocity, 0);
            
            
            node.position = CGPointMake(node.position.x + myNewFrontGroundVelocity.x * (CGFloat)myElapsedTime, node.position.y + myNewFrontGroundVelocity.y * (CGFloat)myElapsedTime);
            
//            myFrontGround.position = CGPointMake(myFrontGround.position.x + myNewFrontGroundVelocity.x * (CGFloat)myElapsedTime, myFrontGround.position.y + myNewFrontGroundVelocity.y * (CGFloat)myElapsedTime);
            
            NSLog(@"%f",myFrontGround.position.x);
            
            
            
            if (myFrontGround.position.x < - myFrontGround.size.width) {
                myFrontGround.position = CGPointMake(myFrontGround.position.x + myFrontGround.size.width * myFrontGroundTotal, myFrontGround.position.y + 0);

                
                NSLog(@"Test!!!");
            }
        
        }
        
//        NSLog(@"BLOCK: %@", [node name]);
     
    }];
    
}
@end
