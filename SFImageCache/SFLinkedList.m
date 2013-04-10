//
//  SFLinkedList.m
//  SFImageCache
//
//  Created by Stefan Filip on 4/7/13.
//  Copyright (c) 2013 stefanfilip. All rights reserved.
//

#import "SFLinkedList.h"

@implementation SFLinkedListNode

@synthesize value = _value;
@synthesize next = _next;
@synthesize prev = _prev;

- (void)dealloc {
#if !__has_feature(objc_arc)
    self.next = nil;
    self.prev = nil;
    [super dealloc];
#endif
}

@end

@implementation SFLinkedList

@synthesize head = _head;
@synthesize tail = _tail;

- (id)init {
    self = [super init];
    if (self) {
        _head = nil;
        _tail = nil;
    }
    return self;
}

- (void)dealloc {
#if !__has_feature(objc_arc)
    self.head = nil;
    self.tail = nil;
    [super dealloc];
#endif
}

- (SFLinkedListNode *)addObject:(NSObject *)object {
    SFLinkedListNode *newNode = [[SFLinkedListNode alloc] init];
    newNode.value = object;
    newNode.next = nil;
    if (_tail) {
        _tail.next = newNode;
        newNode.prev = _tail;
    }
    _tail = newNode;
    if (!_head) {
        _head = newNode;
    }
#if !__has_feature(objc_arc)
    [newNode autorelease];
#endif
    return newNode;
}

- (SFLinkedListNode *)addObjectToHead:(NSObject *)object {
    SFLinkedListNode *newNode = [[SFLinkedListNode alloc] init];
    newNode.value = object;
    newNode.prev = nil;
    if (_head) {
        _head.prev = newNode;
        newNode.next = _head;
    }
    _head = newNode;
    if (!_tail) {
        _tail = newNode;
    }
#if !__has_feature(objc_arc)
    [newNode autorelease];
#endif
    return newNode;
}

- (SFLinkedListNode *)removeNode:(SFLinkedListNode *)node {
    if (node) {
#if !__has_feature(objc_arc)
        [node retain];
#endif
        if (node.prev) {
            node.prev.next = node.next;
        }
        else {
            _head = node.next;
        }
        if (node.next) {
            node.next.prev = node.prev;
        }
        else {
            _tail = node.prev;
        }
#if !__has_feature(objc_arc)
        [node autorelease];
#endif
    }
    return node;
}

- (SFLinkedListNode *)searchForObject:(NSObject *)object {
    SFLinkedListNode *currentNode = _head;
    while (currentNode) {
        if ([currentNode.value isEqual:object]) {
#if !__has_feature(objc_arc)
            [[currentNode retain] autorelease];
#endif
            return currentNode;
        }
        currentNode = currentNode.next;
    }
    return nil;
}

- (void)removeAllObjects {
    self.tail = nil;
    self.head = nil;
}

@end
