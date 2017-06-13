//
//  MZIMVoiceManager.h
//  WePlayVoiceDemo
//
//  Created by Me on 25/05/2017.
//  Copyright © 2017 veryitman.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MZVManagerInstance [MZIMVoiceManager sharedManager]

typedef NS_ENUM(NSUInteger, MZRoleType) {
    MZRoleTypeAnchor = 1,
    MZRoleTypeAudice,
    MZRoleTypeNum
};

@protocol MZIMVoiceDelegate <NSObject>

@optional
- (void)onIMVoiceJoinRoom:(int)rspCode roomName:(NSString *)aRoomName uid:(int)aUid;
- (void)onIMVoiceStatusChanged:(int)status roomName:(NSString *)aRoomName uid:(int)aUid;
- (void)onIMVoiceQuitRoom:(int)code roomName:(NSString *)aRoomName;
- (void)onIMVoiceMemberVoice:(const unsigned int *)members userCount:(int)count;

@end

@interface MZIMVoiceManager : NSObject

+ (instancetype)sharedManager;

/**
 *  调用其他接口之前, 必须首先调用该接口.
 */
- (BOOL)initIMVoiceSDK;

- (BOOL)joinVoiceRoom:(NSString *)roomName;

- (BOOL)joinNVoiceRoom:(NSString *)roomName roleType:(MZRoleType)type;

- (BOOL)quitVoiceRoom:(NSString *)roomName;

- (BOOL)enableSpeaker:(BOOL)enable;

- (BOOL)enableMIC:(BOOL)enable;

- (BOOL)forceCloseMIC:(NSString *)userId;

/**
 * 需要定时器循环调用.
 */
- (BOOL)pollRender;

- (void)setVoiceDelegate:(id<MZIMVoiceDelegate>)delegate;

- (void)handleIMVoicePause;

- (void)handleIMVoiceResume;

@end
