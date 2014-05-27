//
//  TRZSlideLicenseViewController2.m
//  TRZSlideLicenseViewController
//
//  Created by yam on 2014/04/23.
//  Copyright (c) 2014年 yam. All rights reserved.
//

#import "TRZSlideLicenseViewController.h"
#import "TRZSlideLicenseScrollView.h"

@interface TRZSlideLicenseViewController ()

@property (nonatomic) NSArray *licenses;
@property (nonatomic) TRZSlideLicenseScrollView *scrolView;

@end


@implementation TRZSlideLicenseViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        NSLog(@"initWithNibName");
        [self initProperty];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
//        NSLog(@"initWithCoder");
        [self initProperty];
    }
    return self;
}

- (void)initProperty {
    _podsPlistName = @"";
    _headerType = TRZSlideLicenseViewHeaderTypeDefault;
    _headerTitle = @"";
    _headerText = @"";
    _footerType = TRZSlideLicenseViewFooterTypeDefault;
    _footerTitle = @"";
    _footerText = @"";
}

- (void)loadView {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:screenBounds];
    contentView.backgroundColor = [UIColor whiteColor];
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSLog(@"controller frame:%@",NSStringFromCGRect(self.view.frame));
//    NSLog(@"podsPlistName:%@", _podsPlistName);
    if (_podsPlistName) {
        [self loadPodsPlist];
    } else {
        NSLog(@"podsPlistName not specified.");
    }
    if (_licenses) {
        TRZSlideLicenseScrollView *slideLicenseScrollView = [[TRZSlideLicenseScrollView alloc] initWithFrame:self.view.frame licenses:_licenses];
        slideLicenseScrollView.delegate = self;
        slideLicenseScrollView.titleColor = self.titleColor;
        _scrolView = slideLicenseScrollView;
        [self.view addSubview:slideLicenseScrollView];
    } else {
        NSLog(@"licenses data not found.");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //    NSLog(@"scrollViewWillBeginDragging:");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    NSLog(@"scrollViewDidScroll");
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    NSLog(@"scrollViewWillEndDragging:velocity:%f, offset:%f",velocity.x,targetContentOffset->x);
    if (abs(velocity.x) > 1) {
        scrollView.pagingEnabled = NO;
    } else if (velocity.x == 0) {
        if (!scrollView.pagingEnabled) {
            scrollView.pagingEnabled = YES;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //    NSLog(@"scrollViewDidEndDragging");
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    //    NSLog(@"scrollViewWillBeginDecelerating");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidEndDecelerating:%f",scrollView.contentOffset.x);
    if (!scrollView.pagingEnabled) {
        scrollView.pagingEnabled = YES;
    }
    
    CGFloat endPoint = scrollView.contentOffset.x;
    CGFloat width = scrollView.frame.size.width;
    int quo = endPoint / width;
    CGFloat mod = fmod(endPoint, width);
    CGFloat tgtPoint;
//    NSLog(@"quo:%d, mod:%f",quo, mod);
    if (mod) {
        if (mod > width / 2) {
            tgtPoint = width * (quo + 1);
        } else {
            tgtPoint = width * quo;
        }
//        NSLog(@"fitEdgeTo:tgtPoint:%f", tgtPoint);
        [scrollView scrollRectToVisible:CGRectMake(tgtPoint, scrollView.contentOffset.y, scrollView.frame.size.width, scrollView.frame.size.height) animated:YES];
    }
}


#pragma mark - load Pods plist

- (void)loadPodsPlist {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:_podsPlistName ofType:nil];
    NSData *plistData = [NSData dataWithContentsOfFile:filePath];
    NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
    NSError *error;
    id dict = [NSPropertyListSerialization propertyListWithData:plistData options:(NSPropertyListReadOptions)NSPropertyListImmutable format:&format error:&error];
    if (!dict) {
        return;
    }
    NSMutableArray *preferenceSpecifiers = [NSMutableArray arrayWithArray:dict[@"PreferenceSpecifiers"]];
    switch (_headerType) {
        case TRZSlideLicenseViewHeaderTypeNone:
//            NSLog(@"TRZSlideLicenseViewHeaderTypeNone");
            [preferenceSpecifiers removeObjectAtIndex:0];
            break;
        case TRZSlideLicenseViewHeaderTypeCustom:
//            NSLog(@"TRZSlideLicenseViewHeaderTypeCustom");
            preferenceSpecifiers[0] = @{ @"Title" : _headerTitle, @"FooterText" : _headerText};
            break;
        case TRZSlideLicenseViewHeaderTypeDefault:
//            NSLog(@"TRZSlideLicenseViewHeaderTypeDefault");
            break;
    }
    switch (_footerType) {
        case TRZSlideLicenseViewFooterTypeNone:
//            NSLog(@"TRZSlideLicenseViewFooterTypeNone");
            [preferenceSpecifiers removeLastObject];
            break;
        case TRZSlideLicenseViewFooterTypeCustom:
//            NSLog(@"TRZSlideLicenseViewFooterTypeCustom");
            preferenceSpecifiers[[preferenceSpecifiers count] - 1] = @{ @"Title" : _footerTitle, @"FooterText" : _footerText};
            break;
        case TRZSlideLicenseViewFooterTypeDefault:
//            NSLog(@"TRZSlideLicenseViewFooterTypeDefault");
            break;
    }
    
    _licenses = preferenceSpecifiers;
//    for (NSDictionary *license in _licenses) {
//        NSLog(@"Title:%@", license[@"Title"]);
//        NSLog(@"FooterText:%@", license[@"FooterText"]);
//    }
}

#pragma mark - Setter

- (void)setTitleColor:(UIColor *)color
{
    if (color != _titleColor) {
        _titleColor = color;
        
        // Update title color of scrollview.
        self.scrolView.titleColor = color;
    }
}

@end
