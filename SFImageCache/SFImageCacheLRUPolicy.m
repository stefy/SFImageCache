//
//  SFImageCacheLRUPolicy.m
//  SFImageCache
//
//  Created by Stefan Filip on 4/7/13.
//  Copyright (c) 2013 stefanfilip. All rights reserved.
//

#import "SFImageCacheLRUPolicy.h"
#import "SFLinkedList.h"

@interface SFImageCacheLRUPolicy() {
    // We keep our keys in a linked in list. The least recently used key will be kept always at the tail of our list.
    SFLinkedList *_keysList;
    // We also keep the nodes of the list in a dictionary in order to have better performance. Using this approach we don't
    // need to traverse the list each time.
    NSMutableDictionary *_keyNodes;
}

@end

@implementation SFImageCacheLRUPolicy

- (id)init {
    self = [super init];
    if (self) {
        _keysList = [[SFLinkedList alloc] init];
        _keyNodes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
#if !__has_feature(objc_arc)
    [_keysList release];
    [_keyNodes release];
    [super dealloc];
#endif
}

- (void)removeAllKeys {
    [_keyNodes removeAllObjects];
    [_keysList removeAllObjects];
}

- (void)addKey:(NSString *)key withImage:(UIImage *)image {
    // We add the new key to the head of our linked list.
    SFLinkedListNode *newNode = [_keysList addObjectToHead:key];
    [_keyNodes setObject:newNode forKey:key];
}

- (void)heatKey:(NSString *)key {
    // Whenever a key was used we move the node of that specific key to the head of our list (if that node isn't already the head).
    SFLinkedListNode *node = [_keyNodes objectForKey:key];
    if (node != _keysList.head) {
        node = [_keysList removeNode:node];
        [_keysList addObjectToHead:node.value];
    }
}

- (void)removeKey:(NSString *)key {
    SFLinkedListNode *nodeToDelete = [_keyNodes objectForKey:key];
    [_keysList removeNode:nodeToDelete];
    [_keyNodes removeObjectForKey:key];
}

- (NSString *)nextKeyToEvict {
    // The key that will be evicted is the tail of our linked list.
    SFLinkedListNode *nodeToEvict = _keysList.tail;
    if (nodeToEvict) {
        return (NSString *)nodeToEvict.value;
    }
    return nil;
}

@end
