// Trying to reproduce exact compiler crash
// Multiple nested levels with Ref[T?] return type

pub struct Ref[T] {
  mut val : T
}

pub fn[T] Ref::new(value : T) -> Ref[T] {
  { val: value }
}

pub struct FrameNode {
  uid : String
  layout_cache : Ref[LayoutCache?]
}

pub struct LayoutCache {
  width : Int
  height : Int
}

pub fn FrameNode::new(uid : String) -> FrameNode {
  { 
    uid, 
    layout_cache: Ref::new(None)
  }
}

// Method that returns Ref[LayoutCache?]
pub fn FrameNode::get_layout_cache(self : FrameNode) -> Ref[LayoutCache?] {
  self.layout_cache
}

// Complex nested pattern that might trigger the crash
pub fn FrameNode::layout(self : FrameNode) -> Unit {
  // First level inline function
  fn calculate_layout() -> Unit {
    // Second level inline function
    fn update_cache() -> Unit {
      // Third level inline function
      fn set_dimensions(w : Int, h : Int) -> Unit {
        // Calling get_layout_cache from deeply nested inline function
        let cache = self.get_layout_cache()  // <-- Potential crash point
        cache.val = Some({ width: w, height: h })
      }
      
      set_dimensions(100, 200)
    }
    
    update_cache()
  }
  
  calculate_layout()
}

// Another pattern with closure capture
pub fn FrameNode::render(self : FrameNode) -> Unit {
  fn outer() -> Unit {
    let cache_ref = self.get_layout_cache()  // Get ref in outer
    
    fn inner() -> Unit {
      fn innermost() -> Unit {
        // Use captured ref from outer scope
        match cache_ref.val {
          Some(c) => println("Size: \{c.width}x\{c.height}")
          None => {
            // Call get_layout_cache again from innermost
            let new_cache = self.get_layout_cache()  // Another potential crash
            new_cache.val = Some({ width: 50, height: 50 })
          }
        }
      }
      innermost()
    }
    inner()
  }
  outer()
}

// Pattern with lambda/closure
pub fn FrameNode::with_cache(self : FrameNode, f : (Ref[LayoutCache?]) -> Unit) -> Unit {
  fn wrapper() -> Unit {
    let cache = self.get_layout_cache()  // Get in nested function
    f(cache)  // Pass to closure
  }
  wrapper()
}

fn main {
  let node = FrameNode::new("frame1")
  
  println("Testing layout...")
  node.layout()
  
  println("Testing render...")
  node.render()
  
  println("Testing with_cache...")
  node.with_cache(fn(cache) {
    cache.val = Some({ width: 300, height: 400 })
  })
  
  // Verify it worked
  match node.layout_cache.val {
    Some(c) => println("Final size: \{c.width}x\{c.height}")
    None => println("No cache")
  }
  
  println("If you see this, the compiler didn't crash")
}