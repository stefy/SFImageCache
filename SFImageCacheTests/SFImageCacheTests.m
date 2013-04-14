//
//  SFImageCacheTests.m
//  SFImageCacheTests
//
//  Created by Stefan Filip on 4/7/13.
//  Copyright (c) 2013 stefanfilip. All rights reserved.
//

#import "SFImageCacheTests.h"
#import "SFImageCache.h"

@interface SFImageCacheTests() {
    SFImageCache *_imageCache;
    NSMutableArray *_imageKeys;
    NSMutableArray *_images;
}

@end

@implementation SFImageCacheTests


// The setup create a test image cache which contain 10 empty images.
- (void)setUp
{
    [super setUp];
    
    _imageCache = [[SFImageCache alloc] initWithMaxItems:10 maxCacheSize:1000];
    _imageKeys = [[NSMutableArray alloc] init];
    _images = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        UIImage *image = [[UIImage alloc] init];
        [_images addObject:image];
        NSString *currentKey = [NSString stringWithFormat:@"Image%d", i];
        [_imageKeys addObject:currentKey];
        [_imageCache addImage:image forKey:currentKey];
    }
}

- (void)tearDown
{
#if !__has_feature(objc_arc) 
    [_imageCache release];
    [_imageKeys release];
    [_images release];
#endif
    
    [super tearDown];
}

// Tests the clear cache method.
- (void)testEmptyCache {
    [_imageCache clearCache];
    for (NSString *key in _imageKeys) {
        STAssertNil([_imageCache imageForKey:key], [NSString stringWithFormat:@"Image with key %@ was not removed from the cache.", key]);
    }
}

// Tests the removal of an image from the cache.
- (void)testRemoveImageFromCache {
    NSString *key = [_imageKeys objectAtIndex:0];
    [_imageCache removeImageForKey:key];
    UIImage *image = [_imageCache imageForKey:key];
    STAssertNil(image, [NSString stringWithFormat:@"Image with key %@ was not removed from the cache.", key]);
}

// Tests if all the images created in the setup are stored in the cache.
- (void)testImagesAndKeysInCache {
    for (int i=0;i<_imageKeys.count;i++) {
        NSString *key = [_imageKeys objectAtIndex:i];
        UIImage *imageFromCache = [_imageCache imageForKey:key];
        UIImage *expectedImage = [_images objectAtIndex:i];
        STAssertEqualObjects(expectedImage, imageFromCache, @"Image with key %@ was not found in cache");
    }
}

// Tests the addition of a new image to the cache. Since the setup was made so the cache allows only 10 items,
// the cache should evict item with key Image0 prior to adding the new image into the cache.
- (void)testAddNewImage {
    UIImage *image = [[UIImage alloc] init];
    NSString *imageKey = @"Image10";
    [_imageCache addImage:image forKey:imageKey];
    STAssertNil([_imageCache imageForKey:@"Image0"], @"Image with key Image0 should have been evicted from the cache.");
    STAssertEqualObjects(image, [_imageCache imageForKey:imageKey], @"Image was not added to the cache");
}

// Same as the previous test but with an access of image with key Image0. So now the LRU image in the cache should be
// the key Image1.
- (void)testAddNewImageWithPriorHeating {
    UIImage *image = [[UIImage alloc] init];
    NSString *imageKey = @"Image10";
    [_imageCache imageForKey:@"Image0"];
    [_imageCache addImage:image forKey:imageKey];
    STAssertNil([_imageCache imageForKey:@"Image1"], @"Image with key Image1 should have been evicted from the cache.");
    STAssertEqualObjects(image, [_imageCache imageForKey:imageKey], @"Image was not added to the cache");
}

// Tests against setting a new max item size. Items with keys Image0, Image1, Image2 should be removed from the cache.
- (void)testMaxItemsCacheResize {
    int substract = 3;
    _imageCache.maxCacheItems -= substract;
    for (int i = 0;i<substract;i++) {
        UIImage *image = [_imageCache imageForKey:[_imageKeys objectAtIndex:i]];
        STAssertNil(image, [NSString stringWithFormat:@"Image with key %@ should have been evicted from the cache.", [_imageKeys objectAtIndex:i]]);
    }    
}

// We are adding a real image of size 5594259 to our cache which is limited to size 1000. The image should not be
// added to the cache.
- (void)testCacheOverflow {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_image" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    [_imageCache clearCache];
    BOOL result = [_imageCache addImage:image forKey:@"New Image"];
    
    STAssertFalse(result, @"The image is bigger than the max cache size. It shouldn't be stored in the cache.");
    STAssertNil([_imageCache imageForKey:@"New Image"], @"The image is bigger than the max cache size. It shouldn't be stored in the cache.");
}

// Testing the previous scenarion with the increase of the cache size first. Now the image should be in the cache.
- (void)testCacheSizeIncrease {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test_image" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    [_imageCache clearCache];
    _imageCache.maxCacheSize = 10000000;
    [_imageCache addImage:image forKey:@"New Image"];
    
    STAssertEqualObjects(image, [_imageCache imageForKey:@"New Image"], @"The image should be in the cache.");
}

@end
