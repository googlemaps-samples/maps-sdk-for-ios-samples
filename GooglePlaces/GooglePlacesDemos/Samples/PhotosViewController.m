/*
 * Copyright 2016 Google Inc. All rights reserved.
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 * file except in compliance with the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "GooglePlacesDemos/Samples/PhotosViewController.h"

#import <GooglePlacePicker/GooglePlacePicker.h>
#import <GooglePlaces/GooglePlaces.h>

#import "GooglePlacesDemos/Samples/PagingPhotoView.h"

@interface PhotosViewController () <GMSPlacePickerViewControllerDelegate>
@end

@implementation PhotosViewController {
  GMSPlacePickerViewController *_placePicker;
  GMSPlacesClient *_placesClient;
  PagingPhotoView *_photoView;
  UIActivityIndicatorView *_indicatorView;
  NSMapTable *_imagesByPhoto;
}

+ (NSString *)demoTitle {
  return NSLocalizedString(@"Demo.Title.Photos",
                           @"Title of the photos demo for display in a list or nav header");
}

- (instancetype)init {
  if ((self = [super init])) {
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:nil];
    _placePicker = [[GMSPlacePickerViewController alloc] initWithConfig:config];
    _placePicker.delegate = self;
    _placesClient = [GMSPlacesClient sharedClient];
    _imagesByPhoto = [NSMapTable strongToStrongObjectsMapTable];

    // Add a button in the navigation bar which opens the Place Picker.
    NSString *selectPlaceTitle =
        NSLocalizedString(@"Demo.Title.Photos.SelectPlace",
                          @"Title of the 'select place' button within the photos demo");
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:selectPlaceTitle
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(showPlacePicker)];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor whiteColor];

  // Configure the photo view where we are going to display the loaded photos.
  _photoView = [[PagingPhotoView alloc] initWithFrame:self.view.bounds];
  _photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:_photoView];

  // Setup the loading indicator.
  _indicatorView = [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  _indicatorView.autoresizingMask =
      UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
  _indicatorView.center = _photoView.center;
  [self.view addSubview:_indicatorView];

  [self startActivityIndicator];

  // Show Place Picker as soon as the demo is opened.
  [self showPlacePicker];
}

#pragma mark - GMSPlacePickerViewControllerDelegate

- (void)placePicker:(GMSPlacePickerViewController *)viewController didPickPlace:(GMSPlace *)place {
  [self dismissViewControllerAnimated:YES completion:nil];

  [self startActivityIndicator];

  // Start loading the photos for the selected place.
  [_placesClient
      lookUpPhotosForPlaceID:place.placeID
                    callback:^(GMSPlacePhotoMetadataList *photos, NSError *__nullable photoError) {
                      if (photos != nil) {
                        [self displayPhotoList:photos];
                      } else {
                        NSLog(@"Photo metadata lookup failed: %@", photoError);
                      }
                    }];
}

- (void)placePickerDidCancel:(GMSPlacePickerViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:nil];
  NSLog(@"Place picking cancelled.");
}

- (void)placePicker:(GMSPlacePickerViewController *)viewController
    didFailWithError:(NSError *)error {
  NSLog(@"Place picking failed with error: %@", error);
}

#pragma mark - Private methods

- (void)startActivityIndicator {
  _photoView.photoList = @[];
  [_indicatorView startAnimating];
}

- (void)stopActivityIndicator {
  [_indicatorView stopAnimating];
}

- (void)showPlacePicker {
  // Present the Place Picker view controller to select a place to load photos for.
  _placePicker.modalPresentationStyle = UIModalPresentationPopover;
  _placePicker.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
  [self presentViewController:_placePicker animated:YES completion:nil];
}

// Displays a list of photos.
- (void)displayPhotoList:(GMSPlacePhotoMetadataList *)photos {
  // Create a dispatch group for photo requests. We will enter this group immediately before making
  // each photo request, and leave when the request completes. This provides a mechanism for waiting
  // for all of the photo requests to complete.
  dispatch_group_t photoRequestGroup = dispatch_group_create();
  for (GMSPlacePhotoMetadata *photo in photos.results) {
    dispatch_group_enter(photoRequestGroup);
    [_placesClient loadPlacePhoto:photo
                         callback:^(UIImage *photoImage, NSError *error) {
                           if (photoImage == nil) {
                             NSLog(@"Photo request failed with error: %@", error);
                           } else {
                             [_imagesByPhoto setObject:photoImage forKey:photo];
                           }
                           dispatch_group_leave(photoRequestGroup);
                         }];
  }

  // The block will be called once all photo requests have completed.
  dispatch_group_notify(photoRequestGroup, dispatch_get_main_queue(), ^{
    NSMutableArray *attributedPhotos = [NSMutableArray array];
    for (GMSPlacePhotoMetadata *photo in photos.results) {
      UIImage *image = [_imagesByPhoto objectForKey:photo];
      if (image == nil) {
        continue;
      }
      AttributedPhoto *attributedPhoto = [[AttributedPhoto alloc] init];
      attributedPhoto.image = image;
      attributedPhoto.attributions = photo.attributions;
      [attributedPhotos addObject:attributedPhoto];
    }
    _photoView.photoList = attributedPhotos;

    [self stopActivityIndicator];
  });
}

@end
