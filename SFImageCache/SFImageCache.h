//
//  SFImageCache.h
//  SFImageCache
//
//  Created by Stefan Filip on 4/7/13.
//  Copyright (c) 2013 stefanfilip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Default value for the maximum number of images the cache supports.
#define kSFImageCacheDefaultMaxItems                        100
// Default value for the maximum size the cache supports.
#define kSFImageCacheDefaultCacheSize                       100000

@interface SFImageCachePolicy : NSObject

// Returns the next key that needs to be evicted from the cache.
- (NSString *)nextKeyToEvict;
- (void)removeAllKeys;
- (void)removeKey:(NSString *)key;
- (void)addKey:(NSString *)key withImage:(UIImage *)image;
- (void)heatKey:(NSString *)key;

@end

@interface SFImageCache : NSObject

@property (nonatomic, assign) unsigned int maxCacheItems;
@property (nonatomic, assign) unsigned long maxCacheSize;
@property (readonly,  retain) SFImageCachePolicy *cachePolicy;

// Inits an SFImageCache object with a custom number of maximum items and a custom maximum cache size. This initializer
// uses the default eviction policy (LRU).
- (id)initWithMaxItems:(unsigned int)maxItems maxCacheSize:(unsigned long)maxCacheSize;
// Same as before but with a custom cache policy.
- (id)initWithMaxItems:(unsigned int)maxItems maxCacheSize:(unsigned long)maxCacheSize cachePolicy:(SFImageCachePolicy *)cachePolicy;

// Clears the contents of the cache.
- (void)clearCache;
// Returns the image for the specified key. If the key is not present in the cache, nil is returned.
- (UIImage *)imageForKey:(NSString *)key;
// Adds an image to the cache at the specified key. If the key is already present in the cache, its value is overriden.
// If the image cannot be added to the cache NO is returned.
- (BOOL)addImage:(UIImage *)image forKey:(NSString *)key;
// Removes and returns a image from the cache. If the key is not present, nil is returned.
- (UIImage *)removeImageForKey:(NSString *)key;

@end
