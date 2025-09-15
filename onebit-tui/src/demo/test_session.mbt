///|
/// Test terminal session creation
pub fn test_terminal_session() -> Unit {
  println("Creating terminal session...")
  match
    @ffi.TerminalSession::new(
      raw_mode=true,
      mouse=false,
      resize_detection=false,
    ) {
    None => println("Failed to create terminal session (no TTY available)")
    Some(session) => {
      println("✓ Terminal session created successfully!")
      println("  - Raw mode enabled")
      println("  - Ready for keyboard input")

      // Clean up
      session.cleanup()
      println("✓ Terminal session cleaned up")
    }
  }
}
