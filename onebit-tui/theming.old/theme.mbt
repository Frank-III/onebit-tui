// Theming system for OpenTUI

pub struct Theme {
  name : String
  colors : ColorPalette
  typography : Typography
  spacing : SpacingScale
  borders : BorderTheme
  shadows : ShadowTheme
}

pub struct ColorPalette {
  // Base colors
  primary : @core.RGBA
  secondary : @core.RGBA
  tertiary : @core.RGBA
  
  // Semantic colors
  success : @core.RGBA
  warning : @core.RGBA
  error : @core.RGBA
  info : @core.RGBA
  
  // Neutral colors
  background : @core.RGBA
  surface : @core.RGBA
  text : @core.RGBA
  text_secondary : @core.RGBA
  border : @core.RGBA
  
  // State colors
  hover : @core.RGBA
  active : @core.RGBA
  disabled : @core.RGBA
  focus : @core.RGBA
}

pub struct Typography {
  font_family : String
  font_size_base : Int
  font_size_small : Int
  font_size_large : Int
  font_size_xlarge : Int
  line_height : Double
  letter_spacing : Double
}

pub struct SpacingScale {
  xxs : Int  // 2
  xs : Int   // 4
  sm : Int   // 8
  md : Int   // 12
  lg : Int   // 16
  xl : Int   // 24
  xxl : Int  // 32
  xxxl : Int // 48
}

pub struct BorderTheme {
  default_style : @core.BorderStyle
  default_color : @core.RGBA
  radius_small : Int
  radius_medium : Int
  radius_large : Int
}

pub struct ShadowTheme {
  small : String
  medium : String
  large : String
  elevation_1 : String
  elevation_2 : String
  elevation_3 : String
}

// Default theme
pub fn Theme::default() -> Theme {
  {
    name: "Default",
    colors: ColorPalette::default(),
    typography: Typography::default(),
    spacing: SpacingScale::default(),
    borders: BorderTheme::default(),
    shadows: ShadowTheme::default(),
  }
}

pub fn ColorPalette::default() -> ColorPalette {
  {
    primary: @core.RGBA::from_hex("#007ACC"),
    secondary: @core.RGBA::from_hex("#40A9FF"),
    tertiary: @core.RGBA::from_hex("#73D7FF"),
    
    success: @core.RGBA::from_hex("#52C41A"),
    warning: @core.RGBA::from_hex("#FAAD14"),
    error: @core.RGBA::from_hex("#F5222D"),
    info: @core.RGBA::from_hex("#1890FF"),
    
    background: @core.RGBA::from_hex("#0A0E1A"),
    surface: @core.RGBA::from_hex("#1A1E2A"),
    text: @core.RGBA::from_hex("#E8E8E8"),
    text_secondary: @core.RGBA::from_hex("#B0B0B0"),
    border: @core.RGBA::from_hex("#303540"),
    
    hover: @core.RGBA::from_hex("#2A2E3A"),
    active: @core.RGBA::from_hex("#3A3E4A"),
    disabled: @core.RGBA::from_hex("#505560"),
    focus: @core.RGBA::from_hex("#40A9FF"),
  }
}

pub fn Typography::default() -> Typography {
  {
    font_family: "monospace",
    font_size_base: 14,
    font_size_small: 12,
    font_size_large: 16,
    font_size_xlarge: 20,
    line_height: 1.5,
    letter_spacing: 0.0,
  }
}

pub fn SpacingScale::default() -> SpacingScale {
  {
    xxs: 2,
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 32,
    xxxl: 48,
  }
}

pub fn BorderTheme::default() -> BorderTheme {
  {
    default_style: @core.BorderStyle::Single,
    default_color: @core.RGBA::from_hex("#303540"),
    radius_small: 2,
    radius_medium: 4,
    radius_large: 8,
  }
}

pub fn ShadowTheme::default() -> ShadowTheme {
  {
    small: "0 1px 2px rgba(0,0,0,0.1)",
    medium: "0 2px 4px rgba(0,0,0,0.15)",
    large: "0 4px 8px rgba(0,0,0,0.2)",
    elevation_1: "0 2px 4px rgba(0,0,0,0.1)",
    elevation_2: "0 4px 8px rgba(0,0,0,0.15)",
    elevation_3: "0 8px 16px rgba(0,0,0,0.2)",
  }
}

// Preset themes
pub fn Theme::dark() -> Theme {
  Theme::default()  // Default is already dark
}

pub fn Theme::light() -> Theme {
  let theme = Theme::default()
  theme.colors = {
    primary: @core.RGBA::from_hex("#0066CC"),
    secondary: @core.RGBA::from_hex("#0052A3"),
    tertiary: @core.RGBA::from_hex("#003D7A"),
    
    success: @core.RGBA::from_hex("#28A745"),
    warning: @core.RGBA::from_hex("#FFC107"),
    error: @core.RGBA::from_hex("#DC3545"),
    info: @core.RGBA::from_hex("#17A2B8"),
    
    background: @core.RGBA::from_hex("#FFFFFF"),
    surface: @core.RGBA::from_hex("#F8F9FA"),
    text: @core.RGBA::from_hex("#212529"),
    text_secondary: @core.RGBA::from_hex("#6C757D"),
    border: @core.RGBA::from_hex("#DEE2E6"),
    
    hover: @core.RGBA::from_hex("#E9ECEF"),
    active: @core.RGBA::from_hex("#DEE2E6"),
    disabled: @core.RGBA::from_hex("#ADB5BD"),
    focus: @core.RGBA::from_hex("#0066CC"),
  }
  theme
}

pub fn Theme::high_contrast() -> Theme {
  let theme = Theme::default()
  theme.colors = {
    primary: @core.RGBA::white(),
    secondary: @core.RGBA::yellow(),
    tertiary: @core.RGBA::cyan(),
    
    success: @core.RGBA::green(),
    warning: @core.RGBA::yellow(),
    error: @core.RGBA::red(),
    info: @core.RGBA::cyan(),
    
    background: @core.RGBA::black(),
    surface: @core.RGBA::from_hex("#0A0A0A"),
    text: @core.RGBA::white(),
    text_secondary: @core.RGBA::from_hex("#CCCCCC"),
    border: @core.RGBA::white(),
    
    hover: @core.RGBA::from_hex("#333333"),
    active: @core.RGBA::from_hex("#666666"),
    disabled: @core.RGBA::from_hex("#666666"),
    focus: @core.RGBA::yellow(),
  }
  theme
}

pub fn Theme::solarized_dark() -> Theme {
  let theme = Theme::default()
  theme.colors = {
    primary: @core.RGBA::from_hex("#268BD2"),
    secondary: @core.RGBA::from_hex("#2AA198"),
    tertiary: @core.RGBA::from_hex("#859900"),
    
    success: @core.RGBA::from_hex("#859900"),
    warning: @core.RGBA::from_hex("#CB4B16"),
    error: @core.RGBA::from_hex("#DC322F"),
    info: @core.RGBA::from_hex("#268BD2"),
    
    background: @core.RGBA::from_hex("#002B36"),
    surface: @core.RGBA::from_hex("#073642"),
    text: @core.RGBA::from_hex("#839496"),
    text_secondary: @core.RGBA::from_hex("#657B83"),
    border: @core.RGBA::from_hex("#586E75"),
    
    hover: @core.RGBA::from_hex("#073642"),
    active: @core.RGBA::from_hex("#586E75"),
    disabled: @core.RGBA::from_hex("#586E75"),
    focus: @core.RGBA::from_hex("#268BD2"),
  }
  theme
}

// Theme manager
pub struct ThemeManager {
  mut current_theme : Theme
  mut themes : @core.Map[Theme]
}

pub fn ThemeManager::new() -> ThemeManager {
  let manager = {
    current_theme: Theme::default(),
    themes: @core.Map::new(),
  }
  
  // Register built-in themes
  manager.themes.set("default", Theme::default())
  manager.themes.set("light", Theme::light())
  manager.themes.set("dark", Theme::dark())
  manager.themes.set("high_contrast", Theme::high_contrast())
  manager.themes.set("solarized_dark", Theme::solarized_dark())
  
  manager
}

pub fn register_theme(self : ThemeManager, name : String, theme : Theme) -> Unit {
  self.themes.set(name, theme)
}

pub fn set_theme(self : ThemeManager, name : String) -> Bool {
  match self.themes.get(name) {
    Some(theme) => {
      self.current_theme = theme
      true
    }
    None => false
  }
}

pub fn get_current_theme(self : ThemeManager) -> Theme {
  self.current_theme
}

// Theme context for components
pub struct ThemedComponent {
  theme : Theme
}

pub fn with_theme(component : ThemedComponent, theme : Theme) -> ThemedComponent {
  { theme }
}

// Helper to create RGBA from hex
fn RGBA::from_hex(hex : String) -> @core.RGBA {
  // Simple hex parser (assumes #RRGGBB format)
  if hex.length() != 7 || hex[0] != '#' {
    return @core.RGBA::black()
  }
  
  let r = parse_hex_pair(hex.substring(1, 3)) / 255.0
  let g = parse_hex_pair(hex.substring(3, 5)) / 255.0
  let b = parse_hex_pair(hex.substring(5, 7)) / 255.0
  
  @core.RGBA::{ r, g, b, a: 1.0 }
}

fn parse_hex_pair(hex : String) -> Double {
  let mut value = 0.0
  for i = 0; i < 2; i = i + 1 {
    let c = hex[i]
    let digit = if c >= '0' && c <= '9' {
      c.to_int() - '0'.to_int()
    } else if c >= 'A' && c <= 'F' {
      c.to_int() - 'A'.to_int() + 10
    } else if c >= 'a' && c <= 'f' {
      c.to_int() - 'a'.to_int() + 10
    } else {
      0
    }
    value = value * 16.0 + digit.to_double()
  }
  value
}
