// Minimal reproducible example for compiler crash
// The crash only occurs when calling a function that returns Ref[LayoutCache?]
// from an inline function inside a method that has nested inline functions

import moonbitlang/core/ref

pub struct TestNode {
  uid : String
  layout_cache : Ref[LayoutCache?]
}

pub struct LayoutCache {
  value : Int
}

pub fn TestNode::new(uid : String) -> TestNode {
  TestNode {
    uid,
    layout_cache: Ref::new(None)
  }
}

// This function returns Ref[LayoutCache?] - key to triggering the bug
pub fn TestNode::get_layout_cache(self : TestNode) -> Ref[LayoutCache?] {
  self.layout_cache
}

// The compiler crashes when process() calls get_layout_cache()
// from within an inline function that's inside a method with nested functions
pub fn TestNode::process(self : TestNode) -> Unit {
  // Nested inline function #1
  fn helper1() -> Unit {
    // Nested inline function #2 - calling get_layout_cache here causes crash
    fn helper2() -> Unit {
      let cache = self.get_layout_cache()  // <-- CRASH HERE
      cache.val = Some(LayoutCache { value: 42 })
    }
    helper2()
  }
  
  helper1()
}

pub fn main() {
  let node = TestNode::new("test")
  node.process()
  println("If you see this, the compiler didn't crash")
}