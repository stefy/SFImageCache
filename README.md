# SFImageCache #

A simple in-memory image cache static library. 

## Usage ##

Initialization

	SFImageCache *imageCache = [[SFImageCache alloc] init];

Adding images to the cache

	[imageCache addImage:image forKey:@"myKey"];

Getting images from the cache

	[imageCache imageForKey:@"myKey"];

Clearing the cache

	[imageCache clearCache];

Manually removing an image from the cache

	[imageCache removeImageForKey:@"myKey"];

## Custom eviction policies ##

The memory cache uses by default a LRU eviction policy. However, the eviction policy can be changed by creating a new class that implements the SFImageCachePolicy protocol. The image cache can then be initialized using

	MyCachePolicy *myCachePolicy = [[MyCachePolicy alloc] init];
	SFImageCache *imageCache = [[SFImageCache alloc] initWithMaxItems:100 maxCacheSize:1000000 cachePolicy:myCachePolicy];
