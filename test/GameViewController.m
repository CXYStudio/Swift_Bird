//
//  GameViewController.m
//  test
//
//  Created by 曹修远 on 07/09/2017.
//  Copyright © 2017 曹修远. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewWillLayoutSubviews];
    
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        skView.showsPhysics = YES;
        skView.ignoresSiblingOrder = YES;
        
        // Create and configure the scene.
        SKScene * scene = [GameScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
