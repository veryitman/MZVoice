//
//  IDSRoomTablePage.m
//  WePlayVoiceDemo
//
//  Created by Me on 08/06/2017.
//  Copyright © 2017 veryitman.com. All rights reserved.
//

#import "IDSRoomTablePage.h"
#import "IDSIMVoiceMainPage.h"
#import "MZIMVoiceManager.h"
#import "UIView+MZToast.h"

@interface IDSRoomTablePage ()

@property (strong, nonatomic) IBOutlet UITextField *roomNameTF;

@property (strong, nonatomic) IBOutlet UITextField *nRoomNameTf;

@property (strong, nonatomic) IBOutlet UILabel *modeLb;

@property (strong, nonatomic) IBOutlet UISwitch *modeSwith;

@end


@implementation IDSRoomTablePage

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.roomNameTF.text = @"";
    
    self.nRoomNameTf.text = @"";
    
    [self.modeSwith addTarget:self action:@selector(onSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)doStartGVoiceAction:(id)sender
{
    NSString *roomName = [[self class] trim:self.roomNameTF.text];
    
    if ([@"" isEqualToString:roomName] || nil == roomName) {
        [self showToast:@"房间名无效, 请重新输入."];
        return;
    }
    
    BOOL sus = [MZVManagerInstance joinVoiceRoom:roomName];
    
    if (sus) {
        [self showToast:@"加入团战房间成功."];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            IDSIMVoiceMainPage *page = [[IDSIMVoiceMainPage alloc] initWithRoomName:roomName];
            [self.navigationController pushViewController:page animated:YES];
        });
    }
    else {
        [self showToast:@"加入团战房间失败."];
    }
}

- (IBAction)doStartNVoiceAction:(id)sender
{
    NSString *roomName = [[self class] trim:self.roomNameTF.text];
    
    if ([@"" isEqualToString:roomName] || nil == roomName) {
        [self showToast:@"房间名无效, 请重新输入."];
        return;
    }
    
    BOOL sus = NO;
    
    if (self.modeSwith.isOn) {
        sus = [MZVManagerInstance joinNVoiceRoom:roomName roleType:MZRoleTypeAnchor];
    }
    else {
        sus = [MZVManagerInstance joinNVoiceRoom:roomName roleType:MZRoleTypeAudice];
    }
    
    if (sus) {
        [self showToast:@"加入国战房间成功."];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            IDSIMVoiceMainPage *page = [[IDSIMVoiceMainPage alloc] initWithRoomName:roomName];
            [self.navigationController pushViewController:page animated:YES];
        });
    }
    else {
        [self showToast:@"加入国战房间失败."];
    }
}

- (void)onSwitchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch *)sender;
    
    BOOL isButtonOn = [switchButton isOn];
    
    if (isButtonOn) {
        self.modeLb.text = @"主播角色";
    }
    else {
        self.modeLb.text = @"吃瓜群众";
    }
}

+ (NSString *)trim:(NSString *)content
{
    NSCharacterSet *nCs = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *resultStr = [content stringByTrimmingCharactersInSet:nCs];
    
    return resultStr;
}

- (void)showToast:(NSString *)string
{
    [self.view showToast:string];
}

@end
