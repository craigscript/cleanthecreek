#import "CameraVC.h"
#import "PhotoDetailsVC.h"
#import "TGCameraColor.h"
#define CAMERA_TRANSFORM_X 1
#define CAMERA_TRANSFORM_Y 0.5
@implementation CameraVC
- (id) init
{
    self = [super init];
    if (!self) return nil;
    self.photoTaken = NO;
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *tintColor = [UIColor colorWithRed:1/255.0 green:122/255.0 blue:1 alpha:1.0];
    [TGCameraColor setTintColor:tintColor];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"cameraview will appear");
    self.internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    if(!self.photoTaken)
    {
        self.internetReachableFoo.reachableBlock = ^(Reachability*reach)
        {
            // Update the UI on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self takePhoto];
                self.photoTaken=YES;
                
            });
        };
    }
    else
        self.photoTaken=NO;
    // Internet is not reachable
    self.internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self networkError];
        });
    };
    
    [self.internetReachableFoo startNotifier];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Camera View"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
}

-(void) takePhoto
{
//    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
//    picker.allowsEditing = YES;
//    
//    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==NO)
//    {
//        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    else
//    {
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//         picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
//        
//    }
   
//   
//    picker.delegate = self;
//    [self presentViewController:picker animated:YES completion:nil];
    TGCameraNavigationController *navigationController =
    [TGCameraNavigationController newWithCameraDelegate:self];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
//{
//    
//    self.cameraPicture = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
//    self.photoURL=[[NSURL alloc]init];
//    self.photoURL=[info valueForKey:UIImagePickerControllerReferenceURL];
//    [picker dismissViewControllerAnimated:YES completion:NULL];
//    
//    [self performSegueWithIdentifier:@"showPhotoDetails" sender:self];
//}

- (void)cameraDidTakePhoto:(UIImage *)image
{
    self.cameraPicture = image;
    [self performSegueWithIdentifier:@"showPhotoDetails" sender:self];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
    self.cameraPicture = image;
    [self performSegueWithIdentifier:@"showPhotoDetails" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.photoTaken = NO;
}

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//   
//    [picker dismissViewControllerAnimated:YES completion:^{
//        
//    }];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    self.photoTaken = NO;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) cameraRefresh:(BOOL)set
{
    self.photoTaken = set;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"showPhotoDetails"])
    {
        PhotoDetailsVC *photoDetailsVC=(PhotoDetailsVC*)segue.destinationViewController;
        photoDetailsVC.delegate=self;
        
        if(self.location!=nil)
        {
            photoDetailsVC.location=self.location;
            photoDetailsVC.foundDate=self.location.found_date;
            photoDetailsVC.cleanedDate=[[NSDate date] timeIntervalSince1970];
            photoDetailsVC.takenPhoto=self.dirtyPhoto;
            photoDetailsVC.cleanedPhoto=self.cameraPicture;
            photoDetailsVC.secondPhototaken = YES;
        }
        else
        {
            photoDetailsVC.location=nil;
            photoDetailsVC.takenPhoto=self.cameraPicture;
            photoDetailsVC.foundDate=[[NSDate date] timeIntervalSince1970];
            photoDetailsVC.secondPhototaken = NO;
        }
       
    }
}

@end
