#ifndef BUILDING_NODE_EXTENSION
#define BUILDING_NODE_EXTENSION 1
#endif

#include <node.h>
#include "RE2Wrapper.h"

using namespace v8;

void InitAll(Handle<Object> exports) {
  RE2Wrapper::Init(exports);
}

NODE_MODULE(re2, InitAll)
