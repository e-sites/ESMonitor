//
//  ThreadCount.m
//  iBandPlus
//
//  Created by Bas van Kuijck on 22/08/2017.
//  Copyright © 2017 E-sites. All rights reserved.
//

#import "ThreadCount.h"
#include <pthread.h>
#include <mach/mach.h>

static int getThreadsCount() {
#if DEBUG
    thread_act_array_t threads;
    mach_msg_type_number_t thread_count = 0;

    const task_t    this_task = mach_task_self();
    const thread_t  this_thread = mach_thread_self();

    // 1. Get a list of all threads (with count):
    kern_return_t kr = task_threads(this_task, &threads, &thread_count);

    if (kr != KERN_SUCCESS) {
        printf("error getting threads: %s", mach_error_string(kr));
        return 0;
    }

    mach_port_deallocate(this_task, this_thread);
    vm_deallocate(this_task, (vm_address_t)threads, sizeof(thread_t) * thread_count);
    return thread_count;
#else
    return 0
#endif
}

@implementation ThreadCount

+ (int)get {
    return getThreadsCount();
}

@end

