//
//  MessageInputView.h
//  WeiMi
//
//  
//
//

#import <UIKit/UIKit.h>
//#import "HPGrowingTextView.h"
//#import "AddtionView.h"
#import "DeviceItem.h"

//137
#define EMOTICON_PANEL_HEIGHT        216.0f


@class MessageInputView;

@protocol MessageInputViewDelegate <NSObject>

//- (void)messageInputView:(MessageInputView*)messageInputView sendText:(NSString*)text;
//- (void)messageInputView:(MessageInputView*)messageInputView sendAddtion:(AddtionMethodType)type;
//- (void)messageInputView:(MessageInputView *)messageInputView sendChartlet:(NSString*)text withType:(NSString *)type;

@optional
- (void)messageInputView:(MessageInputView*)messageInputView textViewDidBeginEditing:(UITextView*)textView;
- (void)messageInputView:(MessageInputView*)messageInputView textViewDidEndEditing:(UITextView*)textView;
- (void)messageInputView:(MessageInputView*)messageInputView textViewDidChange:(UITextView*)textView;
- (void)messageInputView:(MessageInputView*)messageInputView willChangeHeight:(float)height;
- (BOOL)messageInputView:(MessageInputView*)messageInputView allowBackspacePressedAtRange:(NSRange)range;

- (void)onClickEmoticonOrAddtion:(MessageInputView*)messageInputView whichPanel:(BOOL)emo_or_add;

- (void)onClickVoiceAddtion;

- (NSArray*)addtionViewAddtionMethodTypes;
- (NSArray*)addtionViewTitles;
- (NSArray*)addtionViewIcons;
- (void)showBigTypePicker:(DeviceItemVO*)itemVO;



@end

@interface MessageInputView : UIView


//@property (nonatomic, strong) NSString *bigType;//大类型 HW红外，KG开关
//@property (nonatomic, strong) NSString *deviceType;//设备类型
@property (nonatomic, weak) id<MessageInputViewDelegate> delegate;
@property (nonatomic, assign) BOOL popup;
@property (nonatomic, assign) int current_show_panel; //1 means emoticon, 2 means addtion


- (id)initWithFrame:(CGRect)frame delegate:(id<MessageInputViewDelegate>)delegate withBigType:(DeviceItemVO*)bigType withIsChat:(BOOL)isChat;


//- (void)setInputText:(NSString*)text;

- (void)changeDevType:(DeviceItemVO *)bigType;

-(void)PostData:(NSString *)bigType;
//+ (CGFloat)textViewLineHeight;
//+ (CGFloat)maxLines;
//+ (CGFloat)maxHeight;

@end
