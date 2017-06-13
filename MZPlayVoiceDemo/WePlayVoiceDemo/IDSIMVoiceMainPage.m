//
//  IDSIMVoiceMainPage.m
//  WePlayVoiceDemo
//
//  Created by Me on 25/05/2017.
//  Copyright © 2017 veryitman.com. All rights reserved.
//

#import "IDSIMVoiceMainPage.h"
#import "MZIMVoiceManager.h"
#import "UIView+MZToast.h"

static NSString * const sOpenMIC  = @"打开麦克风";
static NSString * const sCloseMIC = @"关闭麦克风";
static NSString * const sOpenSpeaker  = @"打开扬声器";
static NSString * const sCloseSpeaker = @"关闭扬声器";
static NSString * const sExitRoomStr  = @"退出房间";

@interface IDSIMVoiceMainPage () <MZIMVoiceDelegate>

@property (nonatomic, strong) NSTimer *timer;

@property (strong, nonatomic) IBOutlet UILabel *userLb;

@property (strong, nonatomic) IBOutlet UIButton *enableMICBtn;
@property (strong, nonatomic) IBOutlet UIButton *enableSpeakerBtn;
@property (strong, nonatomic) IBOutlet UIButton *quitRoomBtn;

@property (strong, nonatomic) IBOutlet UITextField *textInputField;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;

@property (nonatomic, copy) NSString *roomName;

@end

@implementation IDSIMVoiceMainPage

- (instancetype)initWithRoomName:(NSString *)roomName
{
    if (self = [super init]) {
        
        self = [super initWithNibName:NSStringFromClass([IDSIMVoiceMainPage class]) bundle:nil];
        
        self.roomName = roomName;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor cyanColor];
    self.navigationItem.title = @"语音聊";
    
    [MZVManagerInstance setVoiceDelegate:self];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.06 target:self selector:@selector(onPoll:) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // [self openMIC];
        [self openSpeaker];
    });
}

#pragma mark - Cpp Callback.

- (void)onIMVoiceJoinRoom:(int)rspCode roomName:(NSString *)aRoomName uid:(int)aUid
{
    NSLog(@"GVoice SDK. onIMVoiceJoinRoom code: %d", rspCode);
}

- (void)onIMVoiceStatusChanged:(int)status roomName:(NSString *)aRoomName uid:(int)aUid
{
    NSLog(@"GVoice SDK. onIMVoiceStatusChanged code: %d", status);
}

- (void)onIMVoiceQuitRoom:(int)code roomName:(NSString *)aRoomName
{
    NSLog(@"GVoice SDK. onIMVoiceQuitRoom code: %d", code);
}

- (void)onIMVoiceMemberVoice:(const unsigned int *)members userCount:(int)count
{
    NSLog(@"GVoice SDK. onIMVoiceMemberVoice code: %d, members: %d", count, *members);
}

- (IBAction)doOperateMICAction:(id)sender
{
    [self openMIC];
}

- (IBAction)doSendAction:(id)sender
{
    
}

- (IBAction)doOperateSpeakerAction:(id)sender
{
    [self openSpeaker];
}

- (IBAction)doExitRoomAction:(id)sender
{
    [self exitRoom];
}

- (void)exitRoom
{
    BOOL sus = [MZVManagerInstance quitVoiceRoom:self.roomName];
    
    if (sus) {
        [self showToast:@"退出房间成功."];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self showToast:@"退出房间失败."];
    }
}

- (void)openMIC
{
    static bool once = false;
    if (!once) {
        if ([MZVManagerInstance enableMIC:YES]) {
            [self showToast:@"打开麦克风成功"];
        }
        else {
            [self showToast:@"打开麦克风失败"];
        }
        once = true;
    }
    else {
        if ([MZVManagerInstance enableMIC:NO]) {
            [self showToast:@"关闭麦克风成功"];
        }
        else {
            [self showToast:@"关闭麦克风失败"];
        }
        
        once = false;
    }
}

- (void)openSpeaker
{
    static bool once = false;
    if (!once) {
        if ([MZVManagerInstance enableSpeaker:YES]) {
            [self showToast:@"打开扬声器成功."];
        }
        else {
            [self showToast:@"打开扬声器失败."];
        }
        once = true;
    }
    else {
        if ([MZVManagerInstance enableSpeaker:NO]) {
            [self showToast:@"关闭扬声器成功."];
        }
        else {
            [self showToast:@"关闭扬声器失败."];
        }
        once = false;
    }
}

- (void)onPoll:(id)sender
{
    [MZVManagerInstance pollRender];
}

- (void)showToast:(NSString *)string
{
    [self.view showToast:string];
}

@end
