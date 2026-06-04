use os_info::Type;
use std::path::{ PathBuf};
use std::process::Command;

fn main() {
    check_os()
}


fn check_os() {
    let os_inf = os_info::get();
    let script = get_script(os_inf.os_type());

    if os_inf.os_type() == Type::Windows {
        println!("You are on Windows , Script executed : {}", script.display());
    } else {
        println!("OS : {:?}. Script : {}", os_inf.os_type(), script.display());
    }

    Command::new(script).status().expect("[FAILED] failed to execute process]");
}

fn get_script(os_type: Type) -> PathBuf {
    let mut path = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    path.push("Scripts");
    if os_type == Type::Windows  {
        path.push("Windows");
        path.push("cloner.bat");
    } else {
        path.push("Linux_OSX");
        path.push("get_cloner.sh")
    }
    path
}