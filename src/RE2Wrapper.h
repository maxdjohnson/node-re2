#ifndef RE2WRAPPER_H
#define RE2WRAPPER_H

#include <node.h>
#include "re2/re2.h"

class RE2Wrapper : public node::ObjectWrap {
 public:
  static void Init(v8::Handle<v8::Object> exports);

 private:
  explicit RE2Wrapper(const std::string &expression);
  ~RE2Wrapper();

  static v8::Persistent<v8::Function> constructor;

  static v8::Handle<v8::Value> New(const v8::Arguments& args);
  static v8::Handle<v8::Value> Match(const v8::Arguments& args);

  RE2 _instance;
};

#endif

