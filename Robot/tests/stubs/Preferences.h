#pragma once
// Simulación NVS para pruebas de migración y errores; no se compila en Arduino.
#include <string>
#include <map>
#include <vector>
#include <cstring>
#include <cstdint>
#include <cstdlib>
#include <cctype>
#include <cstdio>
class String {
  std::string s;
 public:
  String(const char* x = "") : s(x) {}
  String(std::string x) : s(x) {}
  const char* c_str() const { return s.c_str(); }
  size_t length() const { return s.size(); }
  int indexOf(char c) const { auto p = s.find(c); return p == s.npos ? -1 : static_cast<int>(p); }
  int indexOf(char c, size_t start) const { auto p = s.find(c,start); return p == s.npos ? -1 : static_cast<int>(p); }
  String substring(size_t a) const { return s.substr(a); }
  String substring(size_t a, size_t b) const { return s.substr(a,b-a); }
  bool startsWith(const char* prefix) const { return s.find(prefix)==0; }
  void toUpperCase() { for (auto& c : s) c = std::toupper(c); }
  String& operator+=(char c) { s += c; return *this; }
  void trim() { auto a = s.find_first_not_of(" \t\r\n"), b = s.find_last_not_of(" \t\r\n"); s = a == s.npos ? "" : s.substr(a, b-a+1); }
  void toLowerCase() { for (auto& c : s) c = std::tolower(c); }
  bool operator==(const String& b) const { return s == b.s; }
  bool operator!=(const String& b) const { return s != b.s; }
};
struct SerialStub {
  std::string output;
  void println(const char* text) { output += text; output += '\n'; }
  template<class... T> void printf(const char* format, T... args) {
    char buffer[1024]; std::snprintf(buffer, sizeof(buffer), format, args...); output += buffer;
  }
  int availableForWrite() const { return 1024; }
  size_t write(const uint8_t* data, size_t n) { output.append(reinterpret_cast<const char*>(data), n); return n; }
  int available() const { return 0; }
  int read() const { return -1; }
};
static SerialStub Serial;
class Preferences {
  std::map<std::string, std::vector<uint8_t>> data;
  bool opened = false, readonly = false;
 public:
  bool failWrites = false, failOpen = false;
  unsigned writes = 0;
  bool begin(const char*, bool ro) { opened = !failOpen; readonly = ro; return opened; }
  void end() { opened = false; }
  bool isKey(const char* key) const { return data.count(key); }
  size_t putBytes(const char* key, const void* p, size_t n) {
    if (!opened || readonly || failWrites) return 0;
    const auto* b = static_cast<const uint8_t*>(p); data[key] = {b, b+n}; ++writes; return n;
  }
  size_t getBytesLength(const char* key) const { auto it=data.find(key); return it==data.end()?0:it->second.size(); }
  size_t getBytes(const char* key, void* out, size_t n) const {
    auto it=data.find(key); if (!opened || it==data.end() || it->second.size()>n) return 0;
    memcpy(out, it->second.data(), it->second.size()); return it->second.size();
  }
  size_t putFloat(const char* key, float x) { return putBytes(key,&x,sizeof(x)); }
  float getFloat(const char* key, float fallback) const { float x; return getBytes(key,&x,sizeof(x))==sizeof(x)?x:fallback; }
  size_t putInt(const char* key, int32_t x) { return putBytes(key,&x,sizeof(x)); }
  int32_t getInt(const char* key, int32_t fallback) const { int32_t x; return getBytes(key,&x,sizeof(x))==sizeof(x)?x:fallback; }
  size_t putString(const char* key, const String& x) { return putBytes(key,x.c_str(),x.length()+1); }
  String getString(const char* key, const String& fallback) const {
    auto it=data.find(key); return it==data.end()?fallback:String(reinterpret_cast<const char*>(it->second.data()));
  }
};
