use std::env;
use std::path::PathBuf;

pub fn home_dir() -> PathBuf {
    env::var_os("HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("/tmp"))
}

pub fn quickshell_dir() -> PathBuf {
    env::var_os("QUICKSHELL_DIR")
        .map(PathBuf::from)
        .or_else(|| env::var_os("HOME").map(|home| PathBuf::from(home).join(".config/quickshell")))
        .unwrap_or_else(|| PathBuf::from(".config/quickshell"))
}

pub fn cache_dir() -> PathBuf {
    env::var_os("XDG_CACHE_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| home_dir().join(".cache"))
        .join("quickshell")
}

pub fn dotfiles_dir() -> PathBuf {
    if let Some(val) = env::var_os("WABI_DOTFILES_DIR").or_else(|| env::var_os("RICE_DIR")) {
        return PathBuf::from(val);
    }
    let dev_oceanus = home_dir().join("dev/rice/nixos/doty");
    if dev_oceanus.exists() {
        return dev_oceanus;
    }
    let oceanus_path = home_dir().join("dev/rice/nixos/oceanus");
    if oceanus_path.exists() {
        return oceanus_path;
    }
    let doty_path = home_dir().join("doty");
    if doty_path.exists() {
        return doty_path;
    }
    dev_oceanus
}
