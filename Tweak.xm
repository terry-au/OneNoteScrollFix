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

// Notifications
static NSString *kUndoRedoWillInvokeNotificationName = @"ONSFUndoRedoWillInvoke";
static NSString *kUndoRedoDidInvokeNotificationName = @"ONSFUndoRedoDidInvoke";

// Localised Button titles
static NSString *kLocalisedUndoButtonTitle = nil;
static NSString *kLocalisedRedoButtonTitle = nil;

%hook ONPageViewController

- (void)loadView{
	%orig;
	NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
	[notificationCenter addObserver:self selector:@selector(ONSF_willUndo:) name:kUndoRedoWillInvokeNotificationName object:nil];
	[notificationCenter addObserver:self selector:@selector(ONSF_didUndo:) name:kUndoRedoDidInvokeNotificationName object:nil];
}

- (void)dealloc{
	NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
    [notificationCenter removeObserver:self name:kUndoRedoWillInvokeNotificationName object:nil];
    [notificationCenter removeObserver:self name:kUndoRedoDidInvokeNotificationName object:nil];

	%orig;
}

%new
- (void)ONSF_willUndo:(id)sender{
	self.scrollView.ONSF_deferScrollChanges = YES;
}

%new
- (void)ONSF_didUndo:(id)sender{
	self.scrollView.ONSF_deferScrollChanges = NO;
}

%end

%hook ONPageScrollView

%property (nonatomic, retain) BOOL ONSF_deferScrollChanges;

- (void)setContentOffset:(CGPoint)contentOffset{
	if (self.ONSF_deferScrollChanges){
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
		[nc postNotificationName:kUndoRedoWillInvokeNotificationName object:nil];
	}

	%orig;

	if (isUndoRedoButton){
		// A delay is needed. I don't know why.
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		    [nc postNotificationName:kUndoRedoDidInvokeNotificationName object:nil];
		});
	}
}

%end

%ctor{
	NSBundle *bundle = [NSBundle mainBundle];
	kLocalisedUndoButtonTitle = [bundle localizedStringForKey:UNDO_STRING value:DEFAULT_UNDO_TITLE table:TABLE_NAME];
	kLocalisedRedoButtonTitle = [bundle localizedStringForKey:REDO_STRING value:DEFAULT_REDO_TITLE table:TABLE_NAME];
}