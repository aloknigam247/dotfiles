#include <iostream>
using namespace std;
// Default parameter values
inline static extern void myFunction(string a, string b = "Earth")
{
  cout << a + " " + b;
  return a;
}

int main()
{
  char  myChar  = 0; // -128   to +127
  short myShort = 0; // -32768 to +32767
  int   myInt   = 0; // -2^31  to +2^31-1

  std::cout << sizeof(myChar)  // 1 byte (per definition)
            << sizeof(myL2);   // 8

  // Char type
  char c = 'x'; // assigns 120 (ASCII for 'x')

  myFunction("Hello"); // "Hello Earth"
  int i = c;            // assigns 120
  if (x < 1)
    cout << x << " < 1";
  else if (x > 1)
    cout << x << " > 1";
  else
    cout << x << " == 1";

  // Switch statement
  switch (x)
  {
    case 0: cout << x << " is 0"; break;
    default: cout << x << " is not 1 or 2"; break;
  }

  // Ternary operator
  x = (x < 0.5) ? 0 : 1; // ternary operator
  (x < 0.5) ? x = 0 : x = 1; // alternative syntax
  // While loop
  int i = 0;
  while (i < 10) { cout << i++; } // 0-9

  // Do-while loop
  int j = 0;
  do { cout << j++; } while (j < 10); // 0-9
  for (int k = 0, m = 0; k < 10; k++, m--) {
    cout << k+m; // 0x10
  }

  // Break and continue
  for (int i = 0; i < 10; i++)
  {
    break;    // end loop
    continue; // start next iteration
  }

  // Goto statement
  goto myLabel; // jump to label
  myLabel:      // label declaration
  ;
}
*** Class ***
 
class MyRectangle
{
public:
  int x, y;
  int getArea();
};
 
int MyRectangle::getArea() { return x * y; }

int main()
{
  MyRectangle r; // object creation
  r.x = 10;
  r.y = 5;
  int z = r.getArea(); // 50 (5*10)

  MyRectangle r2; // another instance of MyRectangle
  r2.x = 25;      // not same as r.x

  MyRectangle r3;
  MyRectangle *p = &r3; // object pointer
 
  p->getArea();
  (*p).getArea(); // alternative syntax
}
 
 
class MyClass; // class prototype
 
class OtherClass
{
  MyClass* m;
};
 
class MyClass
{
  OtherClass* o;
};
 
*** Constructor ***

class MyRectangle
{
 public:
  int x, y;
  MyRectangle();
  MyRectangle(int, int);
};
 
MyRectangle::MyRectangle() { x = 10; y = 5; }
MyRectangle::MyRectangle(int x, int y)
{
  this->x = x; this->y = y;
}

int main()
{
  // Calls parameterless constructor
  MyRectangle r;
 
  // Calls constructor accepting two integers
  MyRectangle t(2,3);
}

  
// Destructor
class Semaphore
{
 public:
  bool *sem;
 
  Semaphore()  { sem = new bool; }
  ~Semaphore() { delete sem; }
};
 
 
// Direct initialization
MyClass a(5);
MyClass b;

// Value initialization
const MyClass& a = MyClass();

// Copy initialization
MyClass a = MyClass();
MyClass b(a);

delete a, b;
 
*** Inheritance ***
 
class Rectangle
{
 public:
  int x, y;
  int getArea() { return x * y; }
};
 
class Square : public Rectangle {};

int main()
{
  Square s;
  Rectangle& r = s;  // reference upcast
  Rectangle* p = &s; // pointer upcast

  Square& a = (Square&) r;  // reference downcast
  Square& b = (Square&) *p; // pointer downcast
}
 
*** Overriding ***
 
class Rectangle
{
 public:
  int x, y;
  int getArea() { return x * y; }
};
 
class Triangle : public Rectangle
{
 public:
  Triangle(int a, int b) { x = a; y = b; }
  int getArea() { return x * y / 2; }
};

int main()
{
  Triangle t = Triangle(2,3);
  t.getArea(); // 3 (2*3/2) calls Triangle's version

  Rectangle& r = t;
  r.getArea(); // 6 (2*3) calls Rectangle's version
}
 
 
class Rectangle
{
 public:
  int x, y;
  virtual int getArea() { return x * y; }
};

class Triangle : public Rectangle
{
 public:
  Triangle(int a, int b) { x = a; y = b; }
  int getArea() { return x * y / 2; }
};

int main()
{
  Triangle t = Triangle(2,3);
  Rectangle& r = t;
  r.getArea(); // 3 (2*3/2) calls Triangle's version
}
 
 
// Base class scoping
class Rectangle
{
 public:
  int x, y;
  virtual int getArea() { return x * y; }
};

class Triangle : public Rectangle
{
 public:
  Triangle(int a, int b) { x = a; y = b; }
  int getArea() { return Rectangle::getArea() / 2; }
};
 
// Calling base class constructor
class Rectangle
{
 public:
  int x, y;
  Rectangle(int a, int b) { x = a; y = b; }
};
 
class Triangle : public Rectangle
{
 public:
  Triangle(int a, int b) : Rectangle(a,b) {}
};
 
*** Access Levels ***
 
class MyClass
{
  int myPrivate;
 
 public:
  int myPublic;
  void publicMethod();
};
 
 
class MyClass
{
  // Unrestricted access
  public: int myPublic;
 
  // Defining or derived class only
  protected: int myProtected;
 
  // Defining class only
  private: int myPrivate;
 
  void test()
  {
    myPublic    = 0; // allowed
    myProtected = 0; // allowed
    myPrivate   = 0; // allowed
  }
};

class MyChild : public MyClass
{
  void test()
  {
    myPublic    = 0; // allowed
    myProtected = 0; // allowed
    myPrivate   = 0; // inaccessible
  }
};

class OtherClass
{
  void test(MyClass& c)
  {
    c.myPublic    = 0; // allowed
    c.myProtected = 0; // inaccessible
    c.myPrivate   = 0; // inaccessible
  }
};
 
// Friend classes and functions
class MyClass
{
  int myPrivate;
 
  // Give OtherClass access
  friend class OtherClass;
};
 
class OtherClass
{
  void test(MyClass c) { c.myPrivate = 0; } // allowed
};
 
class MyClass
{
  int myPrivate;
 
  // Give myFriend access
  friend void myFriend(MyClass c);
};
 
void myFriend(MyClass c) { c.myPrivate = 0; } // allowed
 
*** Static ***
 
class MyCircle
{
 public:
  double r;         // instance field (one per object)
  static double pi; // static field (only one copy)

  double getArea() { return pi * r * r; }
  static double newArea(double a) { return pi * a * a; }
};
 
double MyCircle::pi = 3.14;

int main()
{
  double p = MyCircle::pi;
  double a = MyCircle::newArea(1);
}
  
// Static local variables
void myFunc()
{
  static int count = 0; // holds # of calls to function
  count++;
}
 
*** Enum ***
 
enum Color { Red, Green, Blue };

int main()
{
  Color c = Red;

  switch(c)
  {
    case Red:   break;
    case Green: break;
    case Blue:  break;
  }
}
 
 
enum Color
{
  Red,   // 0
  Green, // 1
  Blue   // 2
};
 
 
enum Color
{
  Red   = 5,        // 5
  Green = Red,      // 5
  Blue  = Green + 2 // 7
};

*** Struct and Union ***
 
struct Point
{
  int x, y;
} r, s; // object declarations
 
int main()
{
  Point p, q; // object declarations
}
 
struct Point 
{
  int x, y;
} r = { 2, 3 }; // set values of x and y
 
int main() 
{
  Point p = { 2, 3 };
}
 
union Mix
{
  char c;  // 1 byte
  short s; // 2 bytes
  int i;   // 4 bytes
} m;

int main()
{
  m.c = 0xFF; // set first 8 bits
  m.s = 0;    // reset first 16 bits
}
 
union Mix
{
  char c[4];                  // 4 bytes
  struct { short hi, lo; } s; // 4 bytes
  int i;                      // 4 bytes
} m;

int main()
{
  m.i=0xFF00F00F; // 11111111 00000000 11110000 00001111
  m.s.lo;         // 11111111 00000000
  m.s.hi;         //                   11110000 00001111
  m.c[3];         // 11111111
  m.c[2];         //          00000000
  m.c[1];         //                   11110000
  m.c[0];         //                            00001111
}
 
 
// Anonymous union
int main()
{
  union { short s; }; // defines an unnamed union object
  s = 15;
}
 
*** Operator Overloading ***
 
class MyNum
{
 public:
  int val;
  MyNum(int i) : val(i) {}
 
  MyNum add(MyNum &a)
  { return MyNum( val + a.val ); }

  MyNum operator +(MyNum &a)
  { return MyNum( val + a.val ); }

  MyNum& operator++() // ++ prefix
  { ++val; return *this; }

  MyNum operator++(int) // postfix ++
  {
    MyNum t = MyNum(val);
    ++val;
    return t;
  }
};

int main()
{
  MyNum a = MyNum(10), b = MyNum(5);
  MyNum c = a.add(b);
        c = a + b;
  MyNum d = a.operator+(b);
}
 
*** Custom Conversions ***
 
// Implicit conversion methods
class MyNum
{
 public:
  int value;
  MyNum(int i) { value = i; }
};

int main()
{
  MyNum a = 5;        // implicit conversion
  MyNum b = MyNum(5); // object construction
  MyNum c(5);         // object construction
  MyNum d = 'H';      // implicit conversion
}
 
 
// Explicit conversion methods
class MyNum
{
 public:
  int value;
  explicit MyNum(int i) { value = i; }
};

int main()
{
  MyNum a = 5;        // error
  MyNum b(5);         // allowed
  MyNum c = MyNum(5); // allowed
}
 
*** Namespaces ***
 
namespace furniture
{
  class Table {};
}
 
namespace html
{
  class Table {};
}

int main()
{
  furniture::Table fTable;
  html::Table hTable;
}
 
 
// Nesting namespaces
namespace furniture
{
  namespace wood { class Table {}; }
}

int main()
{
  furniture::wood::Table fTable;
}
 
 
// Importing namespaces
namespace html
{
  class Table {};
}

namespace furniture
{
  namespace wood { class Table {}; }
}

using namespace html; // global namespace import
 
int main()
{
  using namespace html; // local namespace import

  // Namespace member import
  using html::Table; // import a single namespace member

  // Namespace alias
  namespace myAlias = furniture::wood; // namespace alias
  myAlias::Table fTable;
}
 
 
// Type alias
typedef my::name::MyClass MyType;
MyType t;

typedef struct { int len; } Length;
Length a, b, c;
 
*** Constants ***
 
int main()
{
  const int var = 5;
  int const var2 = 10; // alternative order

  // Constant pointers
  int myPointee;
  int *const p = &myPointee; // pointer constant
  const int *q = &var; // pointee constant
  const int *const r = &var; // pointer & pointee constant

  // Constant references
  const int& y = var; // referee constant
}
 
 
// Constant objects
class MyClass
{
  public: int x;
  void setX(int a) { x = a; }

  // Constant return type and parameters
  const int& getX() const { return x; }
};

int main()
{
  const MyClass a, b;
  a = b;       // error: object is const
  a.x = 10;    // error: object field is const
  a.setX(2); // error: cannot call non-const method
}
 
 
// Constant fields
class MyClass
{
 public:
  int i;
  const int c;
  MyClass() : c(5), i(5) {}
};
 
 
class MyClass
{
 public:
  static int si;
  const static double csd;
  const static int csi = 5;
};
int MyClass::si = 1;
const double MyClass::csd = 1.23;
 
*** Preprocessor ***
 
#include <iostream> // search default directory
#include "MyFile" // search current, then default
#include "C:\MyFile" // absolute path
#include "..\MyFile" // relative path

// Macros
#define MACRO 0 // macro definition
int x = MACRO; // x = 0

#undef MACRO // macro undefine
#undef MACRO // allowed

#define MAX(a,b) a>b ? a:b
int x = MAX(MACRO, 1); // evaluates to 1

#define MAX(a,b)  \
            a>b ? \
            a:b
  
// Conditional compilation directives
#define DEBUG_LEVEL 3
 
#if DEBUG_LEVEL > 2
 // �
#elif DEBUG_LEVEL == 2
 // �
#else
 // �
#endif
 
 
// Compile if defined
#define DEBUG

#if defined DEBUG
 // �
#elif !defined DEBUG
 // �
#endif

#ifdef DEBUG
 // �
#endif
 
#ifndef DEBUG
 // �
#endif
 
// Error directive
#error Compilation aborted

// Line directive
#line 5 "My MyApp Error"

// Pragma directive
#pragma message( "Hello Compiler" )
#pragma warning(disable : 4507)
 
*** Exception Handling ***
 
#include <iostream>
using namespace std;

int divide(int x, int y)
{
  if (y == 0) throw 0;
  return x / y;
}

int main()
{
  try {
    divide(10,0);
  }
  catch(int& e) {
    std::cout << "Error code: " << e;
  }
  catch(char& e) {
    std::cout << "Error char: " << e;
  }
  catch(...) { std::cout << "Error"; }
}
 
 
// Re-throwing exceptions
int main()
{
  try {
    try { throw 0; }
    catch(...) { throw; } // re-throw exception
  }
  catch(...) { throw; } // run-time error
}
 
// Exception specification
void error1() {}            // may throw any exceptions
void error2() throw(...) {} // may throw any exceptions
void error3() throw(int) {} // may only throw int
void error4() throw() {}    // may not throw exceptions
 
 
// Exception class
#include <iostream>
#include <exception>

void make_error()
{
  throw std::exception("My Error Description");
}

int main()
{
  try { make_error(); }
  catch (std::exception e) {
    std::cout << e.what();
  }
}
 
*** Type Conversions ***
 
int main()
{
  // Promotion
  long   a = 5;  // int promoted to long
  double b = a2;  // long promoted to double
 
  // Demotion
  int  c = 10.5; // warning: possible loss of data
  bool d = c;    // warning: possible loss of data
}
 
 
int main()
{
  // Explicit conversions
  int  c = (int)10.5; // double demoted to int
  char d = (char)c;   // int demoted to char
}
 
 
int main()
{
  // Static cast
  char c = 10;       // 1 byte
  int *p = (int*)&c; // 4 bytes
  *p = 5; // run-time error: stack corruption
  int *q = static_cast<int*>(&c); // compile-time error

  // Reinterpret cast
  int *r = reinterpret_cast<int*>(&c); // forced conversion
}
 
 
// Const cast
#include <iostream>

void print(int *p) { std::cout << *p; }

int main()
{
  const int myConst = 5;
  int *nonConst = const_cast<int*>(&myConst); // removes const
  *nonConst = 10; // potential run-time error

  print(&myConst); // error: cannot convert 
                   // const int* to int*
  print(nonConst); // allowed
}
 
 
// Dynamic cast
#include <iostream>
#include <exception>

class MyBase { public: virtual void test() {} };
class MyChild : public MyBase {};
 
int main()
{
  MyChild *child = new MyChild();
  MyBase  *base = dynamic_cast<MyBase*>(child); // ok

  MyBase  *base2 = new MyBase();
  MyChild *child2 = dynamic_cast<MyChild*>(base2);

  if (child2 == 0) std::cout << "Null pointer returned";

  try { MyChild &child = dynamic_cast<MyChild&>(*base2); }
  catch(std::bad_cast &e)
  {
    std::cout << e.what(); // bad dynamic_cast
  }
}
 
  
 
class MyBase { public: virtual void test() {} };
class MyChild : public MyBase {};
 
int main()
{
  MyChild *child = new MyChild();
  MyBase *base = static_cast<MyBase*>(child); // ok

  // Succeeds for a MyChild object
  MyChild *child2 = dynamic_cast<MyChild*>(base);

  // Allowed, but invalid
  MyChild *child3 = static_cast<MyChild*>(base);
 
  // Incomplete MyChild object dereferenced
  (*child3);
}
 
*** Templates ***
 
// Function templates
template<class T>
void swap(T& a, T& b)
{
  T tmp = a;
  a = b;
  b = tmp;
}

int main()
{
  int a = 1, b = 2;
  swap<int>(a,b); // calls int version of swap

  bool c = true, d = false;
  swap<bool>(c,d); // calls bool version of swap

  int e = 1, f = 2;
  swap(e,f); // calls int version of swap
}
 
 
template<class T, class U>
void swap(T& a, U& b)
{
  T tmp = a;
  a = b;
  b = tmp;
}

int main()
{
  int a = 1;
  long b = 2;
  swap<int, long>(a,b);
}
 
 
// Class templates
template<class T>
class myBox
{
 public:
  T a, b;
};

int main()
{
  myBox<int> box;
}

 
template<class T>
class myBox
{
 public:
  T a, b;
  void swap();
};
 
template<class T>
void myBox<T>::swap()
{
  T tmp = a;
  a = b;
  b = tmp;
}
 
 
// Non-type parameters
template<class T, int N>
class myBox
{
 public:
  T store[N];
};

int main()
{
  myBox<int, 5> box;
}
 
// Class template specialization
#include <iostream>
 
template<class T>
class myBox
{
 public:
  T a;
  void print() { std::cout << a; }
};

template<>
class myBox<bool>
{
 public:
  bool a;
  void print() { std::cout << (a ? "true" : "false"); }
};

int main()
{
  myBox<bool> box = { true };
  box.print(); // true
}
 
// Function template specialization
#include <iostream>
 
template<class T>
class myBox
{
 public:
  T a;
 
  template<class T> void print() {
    std::cout << a;
  }
 
  template<> void print<bool>() {
    std::cout << (a ? "true" : "false");
  }
};

int main()
{
  myBox<bool> box = { true };
  box.print<bool>(); // true
}
 
*** Headers ***
 
// MyFunc.c
void myFunc()
{
  // �
}
 
// MyApp.c
int main()
{
  myFunc(); // error: myFunc identifier not found
}
 
 
// MyApp.c
void myFunc(); // prototype
 
int main()
{
  myFunc(); // ok
}
 
 
// MyFunc.h
void myFunc(); // prototype
 
// MyApp.c
#include "MyFunc.h"
 
 
// MyApp.h - Interface
#define PI 3.14
const double E = 2.72;
void myFunc();

class MyClass
{
 public:
  void myMethod();
};
 
 
// MyApp.c
void MyClass::myMethod() {}
 
 
// MyApp.h
inline void myFunc() {}
 
class MyClass
{
 public:
  void myMethod() {}
};

template<class T>
void templateFunction()
{
  // �
}
