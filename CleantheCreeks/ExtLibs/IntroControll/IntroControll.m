#import "IntroControll.h"

@implementation IntroControll


- (id)initWithFrame:(CGRect)frame pages:(NSArray*)pagesArray
{
    self = [super initWithFrame:frame];
    if(self != nil) {
        
        //Initial Background images
        
        self.backgroundColor = [UIColor blackColor];
        self.backgroundImage1 = [[UIImageView alloc] initWithFrame:frame];
        [_backgroundImage1 setContentMode:UIViewContentModeScaleAspectFill];
        [_backgroundImage1 setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self addSubview:_backgroundImage1];

        _backgroundImage2 = [[UIImageView alloc] initWithFrame:frame];
        [_backgroundImage2 setContentMode:UIViewContentModeScaleAspectFill];
        [_backgroundImage2 setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self addSubview:_backgroundImage2];
        
        //Initial shadow
        UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow.png"]];
        shadowImageView.contentMode = UIViewContentModeScaleToFill;
        shadowImageView.frame = CGRectMake(0, frame.size.height-300, frame.size.width, 300);
        //[self addSubview:shadowImageView];
        
        //Initial ScrollView
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];
        
        //Initial PageView
        self.pageControl = [[FXPageControl alloc] init];
        _pageControl.numberOfPages = pagesArray.count;
        _pageControl.selectedDotImage =[UIImage imageNamed:@"emptyHalo"];
        _pageControl.dotImage = [UIImage imageNamed:@"fullHalo"];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.dotSize=10.0f;
        _pageControl.wrapEnabled=YES;
        
     
        [_pageControl sizeToFit];
        [_pageControl setCenter:CGPointMake(frame.size.width/2.0, frame.size.height/23*22)];
        [self addSubview:_pageControl];
        
        //Create pages
        _pages = pagesArray;
        
        _scrollView.contentSize = CGSizeMake(_pages.count * frame.size.width, frame.size.height);
        _currentPhotoNum = -1;
        
        //Adding views into scroll view.
        FirstPageView * firstPage=[[FirstPageView alloc] initWithFrame:frame model:[_pages objectAtIndex:0]];
        firstPage.frame = CGRectOffset(firstPage.frame, 0, 0);
        [_scrollView addSubview:firstPage];
        for(int i = 1; i <  _pages.count-1; i++) {
            IntroView *view = [[IntroView alloc] initWithFrame:frame model:[_pages objectAtIndex:i]];
            view.frame = CGRectOffset(view.frame, i*frame.size.width, 0);
            view.loginButton.tag=16+i;
            [_scrollView addSubview:view];
        }
        LastPageView * lastPage=[[LastPageView alloc] initWithFrame:frame model:[_pages objectAtIndex:_pages.count-1]];
        lastPage.frame = CGRectOffset(lastPage.frame, (_pages.count-1)*frame.size.width, 0);
        [_scrollView addSubview:lastPage];
        
        [self initShow];
    }
    
    return self;
}

- (void) tick {
    
    [_scrollView setContentOffset:CGPointMake((_currentPhotoNum+1 == _pages.count ? 0 : _currentPhotoNum+1)*self.frame.size.width, 0) animated:YES];
}

- (void) initShow {
    int scrollPhotoNumber = MAX(0, MIN(_pages.count-1, (int)(_scrollView.contentOffset.x / self.frame.size.width)));
    
    if(scrollPhotoNumber != _currentPhotoNum) {
        _currentPhotoNum = scrollPhotoNumber;
        
        //backgroundImage1.image = currentPhotoNum != 0 ? [(IntroModel*)[pages objectAtIndex:currentPhotoNum-1] image] : nil;
        _backgroundImage1.image = [(IntroModel*)[_pages objectAtIndex:_currentPhotoNum] image];
        _backgroundImage2.image = _currentPhotoNum+1 != [_pages count] ? [(IntroModel*)[_pages objectAtIndex:_currentPhotoNum+1] image] : nil;
    }
    
    float offset =  _scrollView.contentOffset.x - (_currentPhotoNum * self.frame.size.width);

    //left
    if(offset < 0) {
        _pageControl.currentPage = 0;
        
        offset = self.frame.size.width - MIN(-offset, self.frame.size.width);
        _backgroundImage2.alpha = 0;
        _backgroundImage1.alpha = (offset / self.frame.size.width);
    
    //other
        
    } else if(offset != 0) {
        //last
        if(scrollPhotoNumber == _pages.count-1) {
            _pageControl.currentPage = _pages.count-1;
            
            _backgroundImage1.alpha = 1.0 - (offset / self.frame.size.width);
            
        } else {
            
            _pageControl.currentPage = (offset > self.frame.size.width/2) ? _currentPhotoNum+1 : _currentPhotoNum;
            
            _backgroundImage2.alpha = offset / self.frame.size.width;
            _backgroundImage1.alpha = 1.0 - _backgroundImage2.alpha;
           
        }
    //stable
    } else {
        _pageControl.currentPage = _currentPhotoNum;
        _backgroundImage1.alpha = 1;
        _backgroundImage2.alpha = 0;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    int scrollPhotoNumber = MAX(0, MIN(_pages.count-1, (int)(_scrollView.contentOffset.x / self.frame.size.width)));
    if(scrollPhotoNumber == _pages.count-1)
        [self.delegate lastPage:YES];
    else
        [self.delegate lastPage:NO];
    [self initShow];

}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scroll {
      [self initShow];
}

@end
