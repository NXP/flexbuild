import yaml
import sys

def parse_yaml_to_output(yaml_content, output_file):
    try:
        data = yaml.safe_load(yaml_content)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}")
        return

    output_lines = []

    # Process top-level keys
    for key, value in data.items():
        if key == 'KERNEL_CONFIG':
            # Special handling for KERNEL_CONFIG dictionary
            for subkey, subvalue in value.items():
                output_lines.append(f'KERNEL_CONFIG_{subkey}="{subvalue}"')
        elif key == 'repo':
            # Special handling for repo dictionary with version unification
            for repo_name, repo_data in value.items():
                for repo_key, repo_value in repo_data.items():
                    # Convert tag/commit/branch to ver
                    if repo_key in ['tag', 'commit', 'branch']:
                        output_lines.append(f'repo_{repo_name}_ver="{repo_value}"')
                    else:
                        output_lines.append(f'repo_{repo_name}_{repo_key}="{repo_value}"')
        else:
            # Handle all other top-level keys
            if isinstance(value, bool):
                value = 'y' if value else 'n'
            output_lines.append(f'{key}="{value}"')

    # Write to output file
    with open(output_file, 'w') as f:
        for line in output_lines:
            f.write(line + '\n')
    # print(f"Successfully wrote output to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python parse_yaml.py <input_yaml_file> <output_config_file>")
        print("Example: python parse_yaml.py config.yml .sdk.cfg")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    try:
        with open(input_file, 'r') as file:
            yaml_content = file.read()
        parse_yaml_to_output(yaml_content, output_file)
    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found.")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
