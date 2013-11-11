#ifndef BUILDING_NODE_EXTENSION
#define BUILDING_NODE_EXTENSION 1
#endif

#include <node.h>

#include "RE2Wrapper.h"
#include "re2/stringpiece.h"

using namespace v8;

Persistent<Function> RE2Wrapper::constructor;

RE2Wrapper::RE2Wrapper(const std::string &expression) : _instance(expression, RE2::Quiet) {
}

RE2Wrapper::~RE2Wrapper() {
}

void RE2Wrapper::Init(Handle<Object> exports) {
  // Prepare constructor template
  Local<FunctionTemplate> tpl = FunctionTemplate::New(New);
  tpl->SetClassName(String::NewSymbol("RE2"));
  tpl->InstanceTemplate()->SetInternalFieldCount(1);
  // Prototype
  tpl->PrototypeTemplate()->Set(String::NewSymbol("match"),
      FunctionTemplate::New(Match)->GetFunction());
  constructor = Persistent<Function>::New(tpl->GetFunction());
  exports->Set(String::NewSymbol("RE2"), constructor);
}

Handle<Value> RE2Wrapper::New(const Arguments& args) {
  HandleScope scope;

  if (args.IsConstructCall()) {
    // Invoked as constructor: `new RE2Wrapper(...)`
    const char* expression = *String::Utf8Value(args[0]);
    if (args[0]->IsUndefined() || expression == NULL) {
      ThrowException(Exception::TypeError(String::New("Wrong number of arguments")));
      return scope.Close(Undefined());
    }
    RE2Wrapper* obj = new RE2Wrapper(expression);
    if (!obj->_instance.ok()) {
      std::string error = obj->_instance.error();
      ThrowException(Exception::SyntaxError(String::New(error.c_str(), error.size())));
      return scope.Close(Undefined());
    }
    obj->Wrap(args.This());
    return args.This();
  } else {
    // Invoked as plain function `RE2Wrapper(...)`, turn into construct call.
    const int argc = 1;
    Local<Value> argv[argc] = { args[0] };
    return scope.Close(constructor->NewInstance(argc, argv));
  }
}

static const int kMaxArgs = 16;
static const int kVecSize = 1+kMaxArgs;

Handle<Value> RE2Wrapper::Match(const Arguments& args) {
  HandleScope scope;

  RE2Wrapper* obj = ObjectWrap::Unwrap<RE2Wrapper>(args.This());

  const char* chars = *String::Utf8Value(args[0]);
  if (args[0]->IsUndefined() || chars == NULL) {
    ThrowException(Exception::TypeError(String::New("Wrong number of arguments")));
    return scope.Close(Undefined());
  }
  std::string str(chars);
  int pos = args[1]->IsUndefined() ? 0 : args[1]->NumberValue();

  int n_matches = 1 + obj->_instance.NumberOfCapturingGroups();
  re2::StringPiece* matches = new re2::StringPiece[n_matches];
  obj->_instance.Match(str, pos, str.size(), RE2::UNANCHORED, matches, n_matches);

  Local<Array> resultsArray = Array::New(n_matches);
  for(unsigned int i = 0; i < n_matches; i++){
    resultsArray->Set(i, String::New(matches[i].data(), matches[i].size()));
  }
  delete [] matches;
  return scope.Close(resultsArray);
}
