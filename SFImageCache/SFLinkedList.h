//
//  SFLinkedList.h
//  SFImageCache
//
//  Created by Stefan Filip on 4/7/13.
//  Copyright (c) 2013 stefanfilip. All rights reserved.
//

#import <Foundation/Foundation.h>

// Defines a node of a linked list.
@interface SFLinkedListNode : NSObject {
}

@property (nonatomic, retain) NSObject *value;
// Reference to the next element in the list.
@property (nonatomic, retain) SFLinkedListNode *next;
// Reference to the previous element in the list.
@property (nonatomic, retain) SFLinkedListNode *prev;

@end

// Defines a double linked list data structure.
@interface SFLinkedList : NSObject

@property (nonatomic, retain) SFLinkedListNode *head;
@property (nonatomic, retain) SFLinkedListNode *tail;

// Adds a new object to the tail of the list.
- (SFLinkedListNode *)addObject:(NSObject *)object;
// Adds a new object to the head of the list.
- (SFLinkedListNode *)addObjectToHead:(NSObject *)object;
// Removes and returns a node from the linked list.
- (SFLinkedListNode *)removeNode:(SFLinkedListNode *)node;
// Searches for a specific object.
- (SFLinkedListNode *)searchForObject:(NSObject *)object;
// Removes all the objects from the linked list.
- (void)removeAllObjects;

@end
