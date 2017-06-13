//
//  MZIMVoiceManager.m
//  WePlayVoiceDemo
//
//  Created by Me on 25/05/2017.
//  Copyright © 2017 veryitman.com. All rights reserved.
//

#import "MZIMVoiceManager.h"

#import "GCloudVoice.h"
#import "GCloudVoiceErrno.h"
#import "GCloudVoiceExtension.h"
#import "GCloudVoiceVersion.h"

using namespace gcloud_voice;

class MZIMVoiceCallback : public IGCloudVoiceNotify {
public:
    virtual ~MZIMVoiceCallback() {};
    
public:
    virtual void OnJoinRoom(GCloudVoiceCompleteCode code, const char *roomName, int memberID);
    
    virtual void OnStatusUpdate(GCloudVoiceCompleteCode status, const char *roomName, int memberID);
    
    virtual void OnQuitRoom(GCloudVoiceCompleteCode code, const char *roomName);
    
    virtual void OnMemberVoice(const unsigned int *members, int count);
};


@implementation MZIMVoiceManager
{
    MZIMVoiceCallback *_imVoiceCb;
    id<MZIMVoiceDelegate> _delegate;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static MZIMVoiceManager *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (BOOL)initIMVoiceSDK
{
    /// 获取版本信息
    {
        char *gVoiceVersion = gcloud_voice_version();
        
        NSString *gVersion = [NSString stringWithUTF8String:gVoiceVersion];
        
        NSLog(@"GVoice SDK. Version: %@", gVersion);
    }
    
    /// 在 GVoice 后台申请得到这两个参数
    NSString *appID  = @"";
    NSString *appKey = @"";
    
    // 随机一个 openid, 唯一用户标识符
    u_int32_t randomId = arc4random() % 90989;
    NSString *openID = [NSString stringWithFormat:@"%d", randomId];
    GCloudVoiceErrno appInfoCode = GetVoiceEngine()->SetAppInfo([appID UTF8String], [appKey UTF8String], [openID UTF8String]);
    NSLog(@"GVoice SDK. SetAppInfo rsp code: %d", appInfoCode);
    
    GCloudVoiceErrno initCode = GetVoiceEngine()->Init();
    NSLog(@"GVoice SDK. Init rsp code: %d", initCode);
    
    if (GCLOUD_VOICE_SUCC == appInfoCode && GCLOUD_VOICE_SUCC == initCode) {
        
        // 设置回调
        if (!_imVoiceCb) {
            _imVoiceCb = new MZIMVoiceCallback();
            GetVoiceEngine()->SetNotify(_imVoiceCb);
        }
        return YES;
    }
    
    return NO;
}

- (BOOL)joinVoiceRoom:(NSString *)roomName
{
    GetVoiceEngine()->SetMode(IGCloudVoiceEngine::RealTime);
    
    GCloudVoiceErrno rst = GetVoiceEngine()->JoinTeamRoom([roomName UTF8String], 50000);
    NSLog(@"GVoice SDK. JoinTeamRoom Error code: %d", rst);
    
    if (GCLOUD_VOICE_SUCC == rst) {
        return YES;
    }
    
    return NO;
}

- (BOOL)joinNVoiceRoom:(NSString *)roomName roleType:(MZRoleType)type
{
    GetVoiceEngine()->SetMode(IGCloudVoiceEngine::RealTime);
    GCloudVoiceErrno rst;
    
    if (MZRoleTypeAnchor == type) {
        rst = GetVoiceEngine()->JoinNationalRoom([roomName UTF8String], IGCloudVoiceEngine::Anchor, 50000);
    }
    else {
        rst = GetVoiceEngine()->JoinNationalRoom([roomName UTF8String], IGCloudVoiceEngine::Audience, 50000);
    }
    
    NSLog(@"GVoice SDK. JoinTeamRoom Error code: %d", rst);
    
    if (GCLOUD_VOICE_SUCC == rst) {
        return YES;
    }
    
    return NO;
}

- (BOOL)quitVoiceRoom:(NSString *)roomName
{
    GCloudVoiceErrno ret = GetVoiceEngine()->QuitRoom([roomName UTF8String]);
    NSLog(@"GVoice SDK. ExitRoom Error code: %d", ret);
    
    if (GCLOUD_VOICE_SUCC == ret) {
        return YES;
    }
    
    return NO;
}

- (BOOL)enableMIC:(BOOL)enable
{
    GCloudVoiceErrno ret;
    
    if (enable) {
        ret = GetVoiceEngine()->OpenMic();
    }
    else {
        ret = GetVoiceEngine()->CloseMic();
    }
    
    if (GCLOUD_VOICE_SUCC == ret) {
        return YES;
    }
    
    return NO;
}

- (BOOL)enableSpeaker:(BOOL)enable
{
    GCloudVoiceErrno ret;
    
    if (enable) {
        ret = GetVoiceEngine()->OpenSpeaker();
    }
    else {
        ret = GetVoiceEngine()->CloseSpeaker();
    }
    
    if (GCLOUD_VOICE_SUCC == ret) {
        return YES;
    }
    
    return NO;
}

- (BOOL)forceCloseMIC:(NSString *)userId
{
    if (nil == userId || [@"" isEqualToString:userId]) {
        return NO;
    }
    
    GCloudVoiceErrno ret = GetVoiceEngine()->ForbidMemberVoice((int)[userId integerValue], true);
    
    if (GCLOUD_VOICE_SUCC == ret) {
        return YES;
    }
    
    return NO;
}

- (BOOL)pollRender
{
    GCloudVoiceErrno ret = GetVoiceEngine()->Poll();
    
    if (GCLOUD_VOICE_SUCC == ret) {
        return YES;
    }
    
    return NO;
}

- (void)handleIMVoicePause
{
    GetVoiceEngine()->Pause();
}

- (void)handleIMVoiceResume
{
    GetVoiceEngine()->Resume();
}

- (void)setVoiceDelegate:(id<MZIMVoiceDelegate>)delegate
{
    _delegate = delegate;
}

- (id<MZIMVoiceDelegate>)delegate
{
    return _delegate;
}

#pragma mark - GVoice Notify Callback.

void MZIMVoiceCallback::OnJoinRoom(GCloudVoiceCompleteCode code, const char *roomName, int memberID)
{
    NSLog(@"GVoice SDK. OnJoinRoom code: %d", code);
    
    NSString *rnStr = [NSString stringWithUTF8String:roomName];
    
    id<MZIMVoiceDelegate> delegate = [MZVManagerInstance delegate];
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(onIMVoiceJoinRoom:roomName:uid:)]) {
            [delegate onIMVoiceJoinRoom:code roomName:rnStr uid:memberID];
        }
    }
}

void MZIMVoiceCallback::OnStatusUpdate(GCloudVoiceCompleteCode status, const char *roomName, int memberID)
{
    NSLog(@"GVoice SDK. OnStatusUpdate code: %d", status);
    
    NSString *rnStr = [NSString stringWithUTF8String:roomName];
    
    id<MZIMVoiceDelegate> delegate = [MZVManagerInstance delegate];
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(onIMVoiceStatusChanged:roomName:uid:)]) {
            [delegate onIMVoiceStatusChanged:status roomName:rnStr uid:memberID];
        }
    }
}

void MZIMVoiceCallback::OnQuitRoom(GCloudVoiceCompleteCode code, const char *roomName)
{
    NSLog(@"GVoice SDK. OnQuitRoom code: %d", code);
    
    NSString *rnStr = [NSString stringWithUTF8String:roomName];
    
    id<MZIMVoiceDelegate> delegate = [MZVManagerInstance delegate];
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(onIMVoiceQuitRoom:roomName:)]) {
            [delegate onIMVoiceQuitRoom:code roomName:rnStr];
        }
    }
}

void MZIMVoiceCallback::OnMemberVoice(const unsigned int *members, int count)
{
    NSLog(@"GVoice SDK. OnMemberVoice code: %d", count);
    
    id<MZIMVoiceDelegate> delegate = [MZVManagerInstance delegate];
    if (delegate) {
        if ([delegate respondsToSelector:@selector(onIMVoiceMemberVoice:userCount:)]) {
            [delegate onIMVoiceMemberVoice:members userCount:count];
        }
    }
}

@end
