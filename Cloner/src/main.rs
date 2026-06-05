use os_info::Type;
use std::path::{ PathBuf};
use std::process::Command;
use std::io;

fn main() {
    check_os()
}


fn check_os() {
    let os_inf = os_info::get();
    let script = get_script(os_inf.os_type());
    println!("\n── System Info ──────────────");
    println!("  OS      : {:?}", os_inf.os_type());
    println!("  Version : {}", os_inf.version());
    println!("────────────────────────────");
    println!("╔══════════════════════════╗");
    println!("║       Git Cloner         ║");
    println!("╠══════════════════════════╣");
    println!("║  1. Clone repositories   ║");
    println!("║  2. Contact Info         ║");
    println!("║  3. Exit                 ║");
    println!("╚══════════════════════════╝");
    print!("\nChoice: \n");

    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap();

    match input.trim() {
        "1" => start_clone(os_inf.os_type()),
        "2" => contact_infos(),
        "3" => std::process::exit(0),
        _   => println!("Invalid choice."),
    }

}

fn start_clone(os_type:Type) {
    let script = get_script(os_type);
    println!("Launching cloner: {}", script.display());
    Command::new("bash")
        .arg(&script)
        .status()
        .expect("Failed to launch cloner");
}

fn contact_infos() {
    println!("[Author]\n1tsubasa / mrtsubasa");
    println!("[Discord]\n Clarity -> https://discord.gg/MGrZGTY2zY\n Osaka -> https://discord.gg/wWKb9rrpwQ")
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