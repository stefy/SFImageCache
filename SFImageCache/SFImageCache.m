//
//  SFImageCache.m
//  SFImageCache
//
//  Created by Stefan Filip on 4/7/13.
//  Copyright (c) 2013 stefanfilip. All rights reserved.
//

#import "SFImageCache.h"
#import "SFImageCacheLRUPolicy.h"
#import <CommonCrypto/CommonDigest.h>

@interface SFImageCache() {
    unsigned long _currentSize;
    unsigned int _currentItems;
    NSMutableDictionary *_cache;
}

// Returns the size of the image in bytes.
- (unsigned int)sizeOfImage:(UIImage *)image;
// Evicts an item from the cache.
- (void)evictItemFromCache;
// Returns the hash key of the given key using the SHA256 hashing algorithm. These hashes are represented on 32 bytes
// and are guaranteed against colision.
- (NSString*)hashKey:(NSString *)key;
// Removes an image from the cache based by its hashkey.
- (UIImage *)removeImageForHashKey:(NSString *)hashKey;

@end

@implementation SFImageCache

@synthesize maxCacheItems = _maxCacheItems;
@synthesize maxCacheSize = _maxCacheSize;
@synthesize cachePolicy = _cachePolicy;

- (id)init {
    return [self initWithMaxItems:kSFImageCacheDefaultMaxItems maxCacheSize:kSFImageCacheDefaultCacheSize];
}

- (id)initWithMaxItems:(unsigned int)maxItems maxCacheSize:(unsigned long)maxCacheSize {
    SFImageCacheLRUPolicy *lruPolicy = [[SFImageCacheLRUPolicy alloc] init];
#if !__has_feature(objc_arc)  
    [lruPolicy autorelease];
#endif
    return [self initWithMaxItems:maxItems maxCacheSize:maxCacheSize cachePolicy:lruPolicy];
}

- (id)initWithMaxItems:(unsigned int)maxItems maxCacheSize:(unsigned long)maxCacheSize cachePolicy:(id<SFImageCachePolicy>)cachePolicy {
    self = [super init];
    if (self) {
        _maxCacheItems = maxItems;
        _maxCacheSize = maxCacheSize;
        _cache = [[NSMutableDictionary alloc] init];
        _cachePolicy = cachePolicy;
#if !__has_feature(objc_arc)  
        [_cachePolicy retain];
#endif
    }
    return self;
}

- (void)setMaxCacheItems:(unsigned int)maxCacheItems {
    _maxCacheItems = maxCacheItems;
    // We may need to remove items from cache if the maximum number of items was lowered.
    while (_currentItems > _maxCacheItems) {
        [self evictItemFromCache];
    }
}

- (void)setMaxCacheSize:(unsigned long)maxCacheSize {
    _maxCacheSize = maxCacheSize;
    // We may need to remove items from cache if the maximum size of the cache was lowered.
    while (_currentSize > _maxCacheSize) {
        [self evictItemFromCache];
    }
}

- (void)clearCache {
    _currentSize = 0;
    _currentItems = 0;
    [_cache removeAllObjects];
    [_cachePolicy removeAllKeys];
}

- (BOOL)addImage:(UIImage *)image forKey:(NSString *)key {
    NSString *hashKey = [self hashKey:key];
    // If key is already present in the cache, we first need to remove the existing image.
    if ([_cache objectForKey:hashKey]) {
        [self removeImageForHashKey:hashKey];
    }
    unsigned int imageSize = [self sizeOfImage:image];
    
    // Evicts items from cache if the cache if full (either max size or max items reached).
    while (_cache.count > 0 && ((_currentItems + 1 > _maxCacheItems) || (_currentSize + imageSize > _maxCacheSize))) {
        [self evictItemFromCache];
    }
    
    if ((_currentItems + 1 <= _maxCacheItems) && (_currentSize + imageSize <= _maxCacheSize)) {
        // Adds the new image to the cache.
        _currentItems++;
        _currentSize += imageSize;
        [_cache setObject:image forKey:hashKey];
        [_cachePolicy addKey:hashKey withImage:image];
        
        return YES;
    }
    return NO;
}

- (UIImage *)removeImageForKey:(NSString *)key {
    NSString *hashKey = [self hashKey:key];
    return [self removeImageForHashKey:hashKey];
}

- (UIImage *)removeImageForHashKey:(NSString *)hashKey {
    UIImage *image = [_cache objectForKey:hashKey];
    if (image) {
#if !__has_feature(objc_arc)
        // If non-arc we need to retain and autorelease the image otherwise the image could get dealloc'd when removed from
        // the dictionary.
        [[image retain] autorelease];
#endif
        [_cache removeObjectForKey:hashKey];
        [_cachePolicy removeKey:hashKey];
        _currentItems--;
        _currentSize -= [self sizeOfImage:image];
    }
    return image;
}

- (UIImage *)imageForKey:(NSString *)key {
    // We need to heat the key before returning it.
    NSString *hashKey = [self hashKey:key];
    [_cachePolicy heatKey:hashKey];
    return [_cache objectForKey:hashKey];
}

- (void)dealloc {
#if !__has_feature(objc_arc)
    [_cache release];
    [_cachePolicy release];
    [super dealloc];
#endif
}

- (NSString*)hashKey:(NSString *)key {
    const char *s=[key cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

- (unsigned int)sizeOfImage:(UIImage *)image {
    if (image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        return [imageData length];
    }
    return 0;
}

- (void)evictItemFromCache {
    NSString *hashKeyToEvict = [_cachePolicy nextKeyToEvict];    
    if ([self removeImageForHashKey:hashKeyToEvict]) {
        NSLog(@"Item with hash key %@ was evicted from the cache", hashKeyToEvict);
    }
}

@end
