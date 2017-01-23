#import "Headers.h"

// Localised Strings (Usage seems somewhat odd.)
// File: strman_0400.strings
// 580 - Undo
// 581 - Redo
#define UNDO_STRING NSLocalizedString(@"580", nil)
#define REDO_STRING NSLocalizedString(@"581", nil)
#define TABLE_NAME @"strman_0400"
// These are fallback titles, for now they're English. Unsure what OneNote is actually using.
#define DEFAULT_UNDO_TITLE @"Undo"
#define DEFAULT_REDO_TITLE @"Redo"

#define INVOCATION_STATE_KEY @"IState"

// Notifications
static NSString *kUndoRedoInvocationNotificationName = @"ONSFUndoRedoInvocation";

// Localised Button titles
static NSString *kLocalisedUndoButtonTitle = nil;
static NSString *kLocalisedRedoButtonTitle = nil;

typedef NS_ENUM(BOOL, ONSFScrollDeference){
	ONSFScrollDeferenceDisabled = NO,
	ONSFScrollDeferenceEnabled = YES
};

%hook ONPageViewController

- (void)loadView{
	%orig;
	NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
	[notificationCenter addObserver:self selector:@selector(ONSF_undoRedoInvocation:) name:kUndoRedoInvocationNotificationName object:nil];
}

- (void)dealloc{
	NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
    [notificationCenter removeObserver:self name:kUndoRedoInvocationNotificationName object:nil];

	%orig;
}

%new
- (void)ONSF_undoRedoInvocation:(NSNotification *)notification{
	NSDictionary *userInfo = notification.userInfo;
	id temp = [userInfo objectForKey:INVOCATION_STATE_KEY];
	BOOL deferScrollChanges = temp ? [temp boolValue] : ONSFScrollDeferenceDisabled;
	self.scrollView.ONSF_deferScrollChanges = deferScrollChanges;
}

%end

%hook ONPageScrollView

%property (nonatomic, retain) BOOL ONSF_deferScrollChanges;

- (void)setContentOffset:(CGPoint)contentOffset{
	if (self.ONSF_deferScrollChanges == ONSFScrollDeferenceEnabled){
		return;
	}
	%orig;
}

%end

static BOOL contains_valid_accessory(OUIOfficeSpaceDataSourceProxy *proxy){
	CUIButton *button = (CUIButton *)proxy.userInterfaceItem;
	if ([button isKindOfClass:%c(CUIButton)]){
		if ([button.savedTitle isEqualToString:kLocalisedUndoButtonTitle] || [button.savedTitle isEqualToString:kLocalisedRedoButtonTitle]){
			return YES;
		}
	}
	return NO;
}

%hook OUIOfficeSpaceDataSourceProxy

- (void)performAction:(id)target{
	BOOL isUndoRedoButton = NO;
	NSNotificationCenter *nc = nil;

	if (contains_valid_accessory(self)){
		isUndoRedoButton = YES;
		nc = NSNotificationCenter.defaultCenter;
		NSDictionary *userInfo = @{INVOCATION_STATE_KEY : @(ONSFScrollDeferenceEnabled)};
		[nc postNotificationName:kUndoRedoInvocationNotificationName object:nil userInfo:userInfo];
	}

	%orig;

	if (isUndoRedoButton){
		// A delay is needed. I don't know why.
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			NSDictionary *userInfo = @{INVOCATION_STATE_KEY : @(ONSFScrollDeferenceDisabled)};
		    [nc postNotificationName:kUndoRedoInvocationNotificationName object:nil userInfo:userInfo];
		});
	}
}

%end

%ctor{
	NSBundle *bundle = [NSBundle mainBundle];
	kLocalisedUndoButtonTitle = [bundle localizedStringForKey:UNDO_STRING value:DEFAULT_UNDO_TITLE table:TABLE_NAME];
	kLocalisedRedoButtonTitle = [bundle localizedStringForKey:REDO_STRING value:DEFAULT_REDO_TITLE table:TABLE_NAME];
}