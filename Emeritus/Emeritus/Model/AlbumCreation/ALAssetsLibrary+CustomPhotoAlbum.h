//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by Marin Todorov on 10/26/11.
//  Copyright (c) 2011 Marin Todorov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SaveImageCompletion)(NSURL *url);
typedef void(^MediaExisted)(BOOL mediaStatus);
typedef void(^FailureBlock)(NSError* error);
typedef void(^GetImageFromAssetUrlCompletionBlock)(UIImage *imagFromAsset);
typedef void(^FailureBlockForGetImageFromAssetUrl)(NSError* error);
@interface ALAssetsLibrary (CustomPhotoAlbum)

/*! Write the image data to the assets library (camera roll).
 *
 * \param image The target image to be saved
 * \param albumName Custom album name
 * \param completion Block to be executed when succeed to write the image data to the assets library (camera roll)
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 */

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock AndFailureBlock:(FailureBlock)failureblock;

//- (void)saveImage:(UIImage *)image
//          toAlbum:(NSString *)albumName
//       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
//          failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! write the video to the assets library (camera roll).
 *
 * \param videoUrl The target video to be saved
 * \param albumName Custom album name
 * \param completion Block to be executed when succeed to write the image data to the assets library (camera roll)
 * \param failure block to be executed when failed to add the asset to the custom photo album
 */
//- (void)saveVideo:(NSURL *)videoUrl
//          toAlbum:(NSString *)albumName
//       completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
//          failure:(ALAssetsLibraryAccessFailureBlock)failure;
-(void)saveVideo:(NSURL *)videoUrl toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock AndFailureBlock:(FailureBlock)failureblock;
/*! Write the image data with meta data to the assets library (camera roll).
 * 
 * \param imageData The image data to be saved
 * \param albumName Custom album name
 * \param metadata Meta data for image
 * \param completion Block to be executed when succeed to write the image data
 * \param failure block to be executed when failed to add the asset to the custom photo album
 */
- (void)saveImageData:(NSData *)imageData
              toAlbum:(NSString *)albumName
             metadata:(NSDictionary *)metadata
           completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
              failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! Write the asset to the assets library (camera roll).
 *
 * \param assetURL The asset URL
 * \param albumName Custom album name
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 */
- (void)addAssetURL:(NSURL *)assetURL
            toAlbum:(NSString *)albumName
         completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
            failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! Loads assets from the assets group (album)
 *
 * \param albumName Custom album name
 * \param completion Block to be executed when succeed or failed to load images from target album
 */
- (void)loadImagesFromAlbum:(NSString *)albumName
                 completion:(void (^)(NSMutableArray *images, NSError *error))completion;

-(void)getImageFromAssetUrl:(NSURL *)assetUrl withCompletionBlock:(GetImageFromAssetUrlCompletionBlock)completionblock AndFailureBlock:(FailureBlockForGetImageFromAssetUrl)failureBlock;
- (NSData *)getvideoData:(ALAssetRepresentation *)assetrep;
-(void)checkMediaExistedOrNot:(NSURL *)mediaUrl WithStatusBlock:(MediaExisted)existedBlock;

@end
