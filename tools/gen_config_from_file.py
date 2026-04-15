#!/usr/bin/env python3
"""
Generate .config file from provided file.

This script reads a file containing CONFIG_* settings
and generates a complete .config file using Kconfig.

Usage:
    gen_config_from_file.py <Kconfig> <config-file>

Example:
    gen_config_from_file.py Kconfig myconfig
"""

import sys
import os
from pathlib import Path
from kconfiglib import Kconfig


def die(msg):
    """Print error message and exit."""
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def load_defconfig(defconfig_path):
    """
    Load defconfig file and parse CONFIG_* settings.
    
    Args:
        defconfig_path: Path to defconfig file
        
    Returns:
        dict: Dictionary of CONFIG_NAME -> value mappings
        
    Raises:
        SystemExit: If file doesn't exist or is invalid
    """
    if not os.path.isfile(defconfig_path):
        die(f"config file not found: {defconfig_path}")
    
    configs = {}
    line_num = 0
    
    try:
        with open(defconfig_path, 'r') as f:
            for line in f:
                line_num += 1
                line = line.strip()
                
                # Skip empty lines and comments
                if not line or line.startswith('#'):
                    continue
                
                # Parse CONFIG_* lines
                if line.startswith('CONFIG_'):
                    if '=' in line:
                        key, value = line.split('=', 1)
                        key = key.strip()
                        value = value.strip()
                        
                        # Remove quotes from string values
                        if value.startswith('"') and value.endswith('"'):
                            value = value[1:-1]
                        
                        configs[key] = value
                    else:
                        die(f"Invalid line {line_num} in {defconfig_path}: {line}")
                elif line.startswith('# CONFIG_'):
                    # Handle explicitly disabled options: # CONFIG_FOO is not set
                    if ' is not set' in line:
                        key = line.split()[1]  # Extract CONFIG_NAME
                        configs[key] = 'n'
                else:
                    die(f"Invalid line {line_num} in {defconfig_path}: {line}\n"
                        f"Lines must start with 'CONFIG_' or '#'")
    
    except IOError as e:
        die(f"Failed to read {defconfig_path}: {e}")
    
    if not configs:
        die(f"No CONFIG_* settings found in {defconfig_path}")
    
    return configs


def apply_defconfig(kconf, configs):
    """
    Apply defconfig settings to Kconfig.
    
    Args:
        kconf: Kconfig instance
        configs: Dictionary of CONFIG_NAME -> value mappings
        
    Returns:
        list: List of warnings for unknown or invalid configs
    """
    warnings = []
    applied = 0
    
    for config_name, value in configs.items():
        # Remove CONFIG_ prefix to get symbol name
        if config_name.startswith('CONFIG_'):
            sym_name = config_name[7:]  # Remove 'CONFIG_' prefix
        else:
            warnings.append(f"Skipping invalid config name: {config_name}")
            continue
        
        # Get symbol from Kconfig
        sym = kconf.syms.get(sym_name)
        
        if not sym:
            warnings.append(f"Unknown symbol: {sym_name}")
            continue
        
        # Apply value based on type
        try:
            if value == 'y':
                sym.set_value(2)  # y
                applied += 1
            elif value == 'n':
                sym.set_value(0)  # n
                applied += 1
            elif value == 'm':
                sym.set_value(1)  # m
                applied += 1
            else:
                # String or int value
                sym.set_value(value)
                applied += 1
        except Exception as e:
            warnings.append(f"Failed to set {sym_name}={value}: {e}")
    
    print(f"Applied {applied} configuration settings")
    return warnings


def main():
    """Main entry point."""
    if len(sys.argv) != 3:
        die("Usage: gen_config_from_file.py <Kconfig> <config-file>\n"
            "Example: gen_config_from_file.py Kconfig imx8mpevk_defconfig")
    
    kconfig_path = sys.argv[1]
    defconfig_path = sys.argv[2]
    
    # Validate Kconfig file
    if not os.path.isfile(kconfig_path):
        die(f"Kconfig file not found: {kconfig_path}")
    
    # Load defconfig
    print(f"Loading config settings from: {defconfig_path}")
    configs = load_defconfig(defconfig_path)
    #print(f"Found {len(configs)} configuration settings")
    
    # Load Kconfig
    print(f"Loading Kconfig from: {kconfig_path}")
    try:
        kconf = Kconfig(kconfig_path)
    except Exception as e:
        die(f"Failed to load Kconfig: {e}")
    
    # Apply config settings
    #print("Applying config settings")
    warnings = apply_defconfig(kconf, configs)
    
    # Print warnings if any
    if warnings:
        print("\nErrors found during configuration:", file=sys.stderr)
        for warning in warnings:
            print(f"  - {warning}", file=sys.stderr)
        print(f"\nTotal errors: {len(warnings)}", file=sys.stderr)
        die("Configuration failed due to errors above")
    
    # Write .config
    output_path = ".config"
    try:
        kconf.write_config(output_path)
        #print(f"Generated {output_path} successfully")
    except Exception as e:
        die(f"Failed to write {output_path}: {e}")
    
    # Print summary
    defconfig_name = Path(defconfig_path).stem
    print(f"\nConfiguration '{defconfig_name}' applied successfully")
    #print(f"Output: {output_path}")


if __name__ == "__main__":
    main()

