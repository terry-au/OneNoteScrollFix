@interface ONPageScrollView : UIScrollView
@property (nonatomic) BOOL ONSF_deferScrollChanges;
@end

@interface ONPageViewController : UIViewController
@property (nonatomic, retain) ONPageScrollView *scrollView;
@end

@interface CUIButton : UIButton
@property (nonatomic, copy, readwrite) NSString *savedTitle;
@end

@interface OUIOfficeSpaceUIItem : NSObject
@end

@interface OUIOfficeSpaceDataSourceProxy : NSObject
@property (nonatomic, retain) OUIOfficeSpaceUIItem *userInterfaceItem;
@end