import kconfiglib
import os
import sys
import multiprocessing

def check_and_fix_config():
    # Use current directory as project root
    project_root = os.getcwd()
    config_file = ".config"
    
    if not os.path.exists(config_file):
        print(f"Error: {config_file} not found. Please run menuconfig first.")
        sys.exit(1)

    # Load Kconfig model and the current .config
    kconf = kconfiglib.Kconfig("Kconfig")
    kconf.load_config(config_file)

    needs_rewrite = False

    # Logic 1: Handle JOBS (If 0, set to CPU core count)
    jobs_sym = kconf.syms.get("JOBS")
    if jobs_sym:
        try:
            val = int(jobs_sym.str_value)
            if val == 0:
                cpu_count = multiprocessing.cpu_count()
                print(f"[*] JOBS is 0, auto-setting to CPU cores: {cpu_count}")
                jobs_sym.set_value(str(cpu_count))
                needs_rewrite = True
        except ValueError:
            print("Warning: JOBS is not a valid integer, skipping auto-set.")

    # Logic 2: Check LINUX_EXTRA_CONFIG file existence
    # If file is missing, clear the value
    linux_sym = kconf.syms.get("LINUX_EXTRA_CONFIG")
    if linux_sym and linux_sym.str_value.strip():
        file_name = linux_sym.str_value.strip()
        path = os.path.join(project_root, "configs", "linux", file_name)
        if not os.path.exists(path):
            print(f"[!] File not found: {path}. Clearing LINUX_EXTRA_CONFIG.")
            linux_sym.set_value("")
            needs_rewrite = True
        else:
            print(f"[*] Linux extra config verified: {path}")

    # Logic 3: Check CUSTOM_SDK_CONFIG file existence
    # If file is missing, clear the value
    sdk_sym = kconf.syms.get("CUSTOM_SDK_CONFIG")
    if sdk_sym and sdk_sym.str_value.strip():
        file_name = sdk_sym.str_value.strip()
        path = os.path.join(project_root, "configs", file_name)
        if not os.path.exists(path):
            print(f"[!] File not found: {path}. Clearing CUSTOM_SDK_CONFIG.")
            sdk_sym.set_value("")
            needs_rewrite = True
        else:
            print(f"[*] SDK config verified: {path}")

    # Sync memory values back to .config if any changes were made
    if needs_rewrite:
        # write_config will update the .config file with the new values
        kconf.write_config(config_file)
        print("[*] .config has been updated and synchronized.")

if __name__ == "__main__":
    check_and_fix_config()

