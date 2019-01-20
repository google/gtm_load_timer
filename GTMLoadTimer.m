// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>

#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <objc/runtime.h>
#include <os/log.h>
#include <os/signpost.h>

static os_log_t swizzleLogger;

static void SwizzleLoads(const struct mach_header* mh, intptr_t vmaddr_slide) {
  Dl_info info;

  if (dladdr(mh, &info) == 0 || info.dli_fname == NULL) {
    os_log_error(OS_LOG_DEFAULT, "Unable to locate a mach_header in GTMLoadTimer::SwizzleLoads");
    return;
  }
  os_signpost_id_t swizzleSignPost = OS_SIGNPOST_ID_INVALID;
  if (@available(iOS 12, macOS 10.14, *)) {
    swizzleSignPost = os_signpost_id_make_with_pointer(swizzleLogger, mh);
    os_signpost_interval_begin(swizzleLogger, swizzleSignPost, "swizzler",
                               "file: %{public}s", info.dli_fname);
  }
  unsigned int classCount;
  const char **classNames = objc_copyClassNamesForImage(info.dli_fname, &classCount);
  for (unsigned int i = 0; i < classCount; i++) {
    Class cls = objc_lookUpClass(classNames[i]);
    unsigned int methodCount;
    Method *methods= class_copyMethodList(object_getClass(cls), &methodCount);
    for (unsigned int j = 0; j < methodCount; j++) {
      SEL selector = method_getName(methods[j]);
      const char *name = sel_getName(selector);
      if (strcmp(name, "load") == 0) {
        char *className = strdup(classNames[i]);
        typedef void (*LoadImpType)(id self, SEL selector);
        LoadImpType oldImp = (LoadImpType)method_getImplementation(methods[j]);
        os_signpost_id_t loadSignPost = OS_SIGNPOST_ID_INVALID;
        if (@available(iOS 12, macOS 10.14, *)) {
         loadSignPost = os_signpost_id_make_with_pointer(swizzleLogger, oldImp);
        }
        IMP newImp = imp_implementationWithBlock(^void(id self) {
          if (@available(iOS 12, macOS 10.14, *)) {
            os_signpost_interval_begin(swizzleLogger, loadSignPost, "load",
                                       "class: %{public}s", className);
          }
          oldImp(self, @selector(load));
          if (@available(iOS 12, macOS 10.14, *)) {
            os_signpost_interval_end(swizzleLogger, loadSignPost, "load");
          }
          free(className);
        });
        method_setImplementation(methods[j], newImp);
        break;
      }
    }
    free(methods);
  }
  free(classNames);
  if (@available(iOS 12, macOS 10.14, *)) {
    os_signpost_interval_end(swizzleLogger, swizzleSignPost, "swizzler");
  }
}

@interface GTMLoadTimer : NSObject
@end

@implementation GTMLoadTimer

+ (void)load {
  if (@available (iOS 12.0, macOS 10.14, *)) {
    swizzleLogger = os_log_create("com.google.instruments.loadtimer", "performance");
    _dyld_register_func_for_add_image(SwizzleLoads);
  }
}

@end
