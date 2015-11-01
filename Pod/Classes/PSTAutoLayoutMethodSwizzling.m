//
//  PSTAutoLayoutMethodSwizzling.m
//  Pods
//
//  Created by ypresto on 2015/10/28.
//
//  Refer: http://stackoverflow.com/a/32677457/1474113
//
//


#import "PSTAutoLayoutMethodSwizzling.h"

#import <dlfcn.h>
#import <objc/runtime.h>
#import <sys/mman.h>

@implementation PSTAutoLayoutMethodSwizzling

static int64_t originalInstruction;
static int64_t *origFunc;
static NSObject *lockObject;
static PSTAutoLayoutMethodSwizzlingUnsatisfiableConstraintsHandler unsatisfiableConstraintsHandler;

static void PSTAutoLayoutMethodSwizzling_swizzled_UIViewAlertForUnsatisfiableConstraints(NSLayoutConstraint *offendingConstraint,
                                                                                         NSArray *allConstraints)
{
    @synchronized(lockObject)
    {
        int64_t swizzledInstruction = *origFunc;
        // replace jump instruction w/ the original memory offset
        *origFunc = originalInstruction;
        ((void (*)(NSLayoutConstraint *, NSArray *))origFunc)(offendingConstraint, allConstraints);
        *origFunc = swizzledInstruction;
    }
    
    unsatisfiableConstraintsHandler(offendingConstraint, allConstraints);
}

static inline BOOL PSTAutoLayoutMethodSwizzling_swizzleAlertForUnsatisfiableConstraints()
{
    if (origFunc) {
        return YES;
    }

    if (!lockObject) {
        lockObject = [NSObject new];
    }
    
    // get the original function and hold onto it's memory offset
    origFunc = dlsym(RTLD_DEFAULT, "UIViewAlertForUnsatisfiableConstraints");
    if (!origFunc) {
        return NO;
    }
    originalInstruction = *origFunc;
    
    // define the swizzled implementation
    int64_t *swizzledFunc = (int64_t *)&PSTAutoLayoutMethodSwizzling_swizzled_UIViewAlertForUnsatisfiableConstraints;
    
    // make the memory containing the original funcion writable
    size_t pageSize = sysconf(_SC_PAGESIZE);
    uintptr_t start = (uintptr_t)origFunc;
    uintptr_t end = start + 1;
    uintptr_t pageStart = start & -pageSize;
    mprotect((void *)pageStart, end - pageStart, PROT_READ | PROT_WRITE | PROT_EXEC);
    
    // Calculate the relative offset needed for the jump instruction
    // Since relative jumps are calculated from the address of the next instruction,
    //  5 bytes must be added to the original address (jump instruction is 5 bytes)
    int64_t offset = (int64_t)swizzledFunc - ((int64_t)origFunc + 5 * sizeof(char));
    
    // Set the first instruction of the original function to be a jump
    //  to the replacement function.
    // E9 is the x86 opcode for an unconditional relative jump
    int64_t instruction = 0xe9 | offset << 8;
    *origFunc = instruction;
    
    return YES;
}

static inline void PSTAutoLayoutMethodSwizzling_restoreSwizzledAlertForUnsatisfiableConstraints()
{
    if (!origFunc) {
        return;
    }
    *origFunc = originalInstruction;
    origFunc = NULL;
    originalInstruction = 0x0;
}

+ (void)setUnsatisfiableConstraintsHandler:(PSTAutoLayoutMethodSwizzlingUnsatisfiableConstraintsHandler)newValue
{
    if (!newValue) {
        PSTAutoLayoutMethodSwizzling_restoreSwizzledAlertForUnsatisfiableConstraints();
        unsatisfiableConstraintsHandler = nil;
        return;
    }

    BOOL swizzleResult = PSTAutoLayoutMethodSwizzling_swizzleAlertForUnsatisfiableConstraints();
    if (!swizzleResult) {
        [NSException raise:NSInternalInconsistencyException format:@"This platform does not support UIViewAlertForUnsatisfiableConstraints."];
    }
    unsatisfiableConstraintsHandler = [newValue copy];
}

+ (void)removeUnsatisfiableConstraintsHandler
{
    [self setUnsatisfiableConstraintsHandler:nil];
}

@end
