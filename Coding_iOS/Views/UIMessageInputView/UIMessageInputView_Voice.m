//
//  UIMessageInputView_Voice.m
//  Coding_iOS
//
//  Created by sumeng on 8/1/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "UIMessageInputView_Voice.h"
#import "AudioRecordView.h"
#import "AudioPlayView.h"

typedef NS_ENUM(NSInteger, UIMessageInputView_VoiceState) {
    UIMessageInputView_VoiceStateReady,
    UIMessageInputView_VoiceStateRecording,
    UIMessageInputView_VoiceStateCancel
};

@interface UIMessageInputView_Voice () <AudioRecordViewDelegate>

@property (strong, nonatomic) UILabel *recordTipsLabel;
@property (strong, nonatomic) AudioRecordView *recordView;
@property (assign, nonatomic) UIMessageInputView_VoiceState state;
@property (assign, nonatomic) int duration;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) AudioPlayView *playView;

@end

@implementation UIMessageInputView_Voice

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        
        _recordTipsLabel = [[UILabel alloc] init];
        _recordTipsLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:_recordTipsLabel];
        
        _recordView = [[AudioRecordView alloc] initWithFrame:CGRectMake((self.frame.size.width - 88) / 2, 62, 88, 88)];
        _recordView.delegate = self;
        [self addSubview:_recordView];
        
        _playView = [[AudioPlayView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        _playView.backgroundColor = [UIColor greenColor];
        [self addSubview:_playView];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.font = [UIFont systemFontOfSize:12];
        tipLabel.textColor = [UIColor colorWithRGBHex:0x999999];
        tipLabel.text = @"向上滑动，取消发送";
        [tipLabel sizeToFit];
        tipLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height-25);
        [self addSubview:tipLabel];
        
        _duration = 0;
        self.state = UIMessageInputView_VoiceStateReady;
    }
    return self;
}

- (void)dealloc {
    self.state = UIMessageInputView_VoiceStateReady;
}

- (void)setState:(UIMessageInputView_VoiceState)state {
    _state = state;
    switch (state) {
        case UIMessageInputView_VoiceStateReady:
            _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0x999999];
            _recordTipsLabel.text = @"按住说话";
            break;
        case UIMessageInputView_VoiceStateRecording:
            _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0x2faeea];
            _recordTipsLabel.text = [self formattedTime:_duration];
            break;
        case UIMessageInputView_VoiceStateCancel:
            _recordTipsLabel.textColor = [UIColor colorWithRGBHex:0x999999];
            _recordTipsLabel.text = @"松开取消";
            break;
        default:
            break;
    }
    [_recordTipsLabel sizeToFit];
    _recordTipsLabel.center = CGPointMake(self.frame.size.width/2, 20);
}

#pragma mark - RecordTimer

- (void)startTimer {
    _duration = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(increaseRecordTime) userInfo:nil repeats:YES];
}

- (void)stopTimer {
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
    self.state = UIMessageInputView_VoiceStateReady;
    _duration = 0;
}

- (void)increaseRecordTime {
    _duration++;
    if (self.state == UIMessageInputView_VoiceStateRecording) {
        //update time label
        self.state = UIMessageInputView_VoiceStateRecording;
    }
}

- (NSString *)formattedTime:(int)duration {
    return [NSString stringWithFormat:@"%02d:%02d", duration / 60, duration % 60];
}

#pragma mark - AudioRecordViewDelegate

- (void)recordViewRecordStarted:(AudioRecordView *)recordView {
    self.state = UIMessageInputView_VoiceStateRecording;
    [self startTimer];
}

- (void)recordViewRecordFinished:(AudioRecordView *)recordView file:(NSString *)file duration:(NSTimeInterval)duration {
    [self stopTimer];
    if (self.state == UIMessageInputView_VoiceStateRecording) {
        if (_recordSuccessfully) {
            _recordSuccessfully(file, duration);
        }
    }
    self.state = UIMessageInputView_VoiceStateReady;
    
    _playView.url = [NSURL fileURLWithPath:file];
}

- (void)recordView:(AudioRecordView *)recordView touchStateChanged:(AudioRecordViewTouchState)touchState {
    self.state = UIMessageInputView_VoiceStateCancel;
}

- (void)recordView:(AudioRecordView *)recordView volume:(double)volume {
    
}

@end
