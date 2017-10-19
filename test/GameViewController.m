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
extern NSString *leaderboardID;
@implementation GameViewController{
    GKGameCenterViewController *gameCenterController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewWillLayoutSubviews];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipToAR) name:@"AR" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeaderboard) name:@"GameCenter" object:nil];
    
    
}

- (void) showLeaderboard{
    
    gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gameCenterController.leaderboardTimeScope = GKLeaderboardTimeScopeToday;
        
        gameCenterController.leaderboardIdentifier = leaderboardID;
        [self presentViewController: gameCenterController animated: YES completion:nil];
    }
}
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
