import os
import re

def to_snake_case(name):
    # Separate lowercase letters from uppercase letters with underscores
    name = re.sub(r'([a-z0-9])([A-Z])', r'\1_\2', name)
    # Replace spaces, hyphens, and multiple underscores with a single underscore
    name = re.sub(r'[\s\-]+', '_', name)
    # Lowercase everything
    name = name.lower()
    # Replace any sequences of underscores with a single underscore
    name = re.sub(r'_+', '_', name)
    return name

def rename_assets(base_path):
    for root, dirs, files in os.walk(base_path):
        for file in files:
            if file.startswith('.') or file.endswith('.DS_Store'):
                continue
            
            old_path = os.path.join(root, file)
            # Standardize filename but keep extension
            name_part, ext = os.path.splitext(file)
            new_name = to_snake_case(name_part) + ext
            new_path = os.path.join(root, new_name)
            
            if old_path != new_path:
                print(f"Renaming: {old_path} -> {new_path}")
                os.rename(old_path, new_path)

if __name__ == "__main__":
    rename_assets("assets/images")
