//
//  GameViewController.m
//  test
//
//  Created by 曹修远 on 07/09/2017.
//  Copyright © 2017 曹修远. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "ViewController.h"
extern BOOL isShouldSkipToAR;
@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewWillLayoutSubviews];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipToAR) name:@"AR" object:nil];
    
}
- (void)skipToAR{
    NSLog(@"isShouldSkipToAR:%d",isShouldSkipToAR);
//    [self performSegueWithIdentifier:@"showAR" sender:self];
    isShouldSkipToAR = NO;
    

    
    ViewController *arVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"arVC"];
    
    

    [self showViewController:arVC sender:nil];

//    [self presentModalViewController:arVC animated:YES];
    
    NSLog(@"test");
    
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
//        skView.showsFPS = YES;
//        skView.showsNodeCount = YES;
//        skView.showsPhysics = YES;
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
