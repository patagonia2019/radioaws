//
//  OGVPlayerViewController.m
//  LDLARadio
//
//  Created by javierfuchs on 1/19/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

#import "OGVPlayerViewController.h"
#import <OGVKit/OGVKit.h>

@interface OGVPlayerViewController () <OGVPlayerDelegate>
@property (nonatomic, strong) OGVPlayerView *playerView;
@end

@implementation OGVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.playerView pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)play
{
    [self.view addSubview:self.playerView];
    
    self.playerView.sourceURL = self.urlLink;
    [self.playerView play];
}

- (OGVPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[OGVPlayerView alloc] initWithFrame:self.view.bounds];
        _playerView.delegate = self; // implement OGVPlayerDelegate protocol
    }
    return _playerView;
}

@end
