import os
from pathlib import Path
from collections.abc import MutableMapping
from typing import Any, Dict, List, Optional

import yaml


BASE_DIR = os.environ.get("IDVH_BASE_DIR", "./IDVH")
CONFIG_DIR = "00_product_configs"


def flatten_dict(data: MutableMapping, parent: str = "", sep: str = "_") -> Dict[str, Any]:
    items: Dict[str, Any] = {}
    for key, value in sorted(data.items()):
        if not isinstance(key, str):
            continue
        item_key = f"{parent}{sep}{key}" if parent else key
        if isinstance(value, MutableMapping):
            items[item_key] = True
            items.update(flatten_dict(value, item_key, sep))
        else:
            items[item_key] = value
    return items


class Default(dict):
    def __missing__(self, key: str) -> str:
        return "-"


def load_yaml(path: str) -> Optional[Dict[str, Any]]:
    try:
        with open(path, "r", encoding="utf-8") as handle:
            content = yaml.safe_load(handle)
            return content if isinstance(content, MutableMapping) else None
    except Exception:
        return None


def build_configs(root_dir: str) -> Dict[str, List[Dict[str, Any]]]:
    configs: Dict[str, List[Dict[str, Any]]] = {}

    for root, dirs, files in os.walk(root_dir):
        dirs.sort()
        yml_files = sorted([f for f in files if f.endswith((".yml", ".yaml"))])
        if not yml_files:
            continue

        rel_parts = [p for p in Path(root).relative_to(root_dir).parts if p != "."]
        if len(rel_parts) < 2:
            continue

        product = rel_parts[-2]
        env = "All" if rel_parts[-1] == "common" else rel_parts[-1]

        for file_name in yml_files:
            module_name = Path(file_name).stem
            file_path = os.path.join(root, file_name)
            module_yaml = load_yaml(file_path)
            if not module_yaml:
                continue

            configs.setdefault(module_name, []).append(
                {
                    "product": product,
                    "env": env,
                    "tiers": module_yaml,
                }
            )

    return configs


def module_description(module_path: str) -> Optional[str]:
    desc_file = os.path.join(module_path, "resource_description.info")
    if not os.path.isfile(desc_file):
        return None

    with open(desc_file, "r", encoding="utf-8") as handle:
        return handle.read().strip()


def write_module_library(base_dir: str, module_name: str, entries: List[Dict[str, Any]]) -> None:
    module_path = os.path.join(base_dir, module_name)
    if not os.path.isdir(module_path):
        return

    description_tpl = module_description(module_path)
    if description_tpl is None:
        return

    output: List[str] = [f"# IDVH {module_name} Resources", ""]
    output.append("| Product | Environment | Tier | Description |")
    output.append("|:-------:|:-----------:|:----:|:------------|")

    last_pair: Optional[tuple[str, str]] = None
    sorted_entries = sorted(entries, key=lambda e: (e["product"], e["env"]))

    for entry in sorted_entries:
        pair = (entry["product"], entry["env"])
        if last_pair is not None and pair != last_pair:
            output.append("|---|---|---|---|")
        last_pair = pair

        for tier_name in sorted(entry["tiers"].keys()):
            tier_data = entry["tiers"][tier_name]
            if not isinstance(tier_data, MutableMapping):
                continue
            flat = flatten_dict(tier_data)
            description = description_tpl.format_map(Default(flat))
            output.append(f"| {entry['product']} | {entry['env']} | {tier_name} | {description} |")

    with open(os.path.join(module_path, "LIBRARY.md"), "w", encoding="utf-8") as handle:
        handle.write("\n".join(output) + "\n")


def write_root_library(base_dir: str, module_names: List[str]) -> None:
    lines = [
        "# IDVH Available Modules",
        "",
        "| Module | Documentation |",
        "|-----------|------------------|",
    ]

    for module in sorted(module_names):
        lines.append(f"| {module} | [README]({module}/README.md) |")

    with open(os.path.join(base_dir, "LIBRARY.md"), "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines) + "\n")


def main() -> None:
    base_dir = BASE_DIR
    config_root = os.path.join(base_dir, CONFIG_DIR)

    if not os.path.isdir(base_dir) or not os.path.isdir(config_root):
        return

    configs = build_configs(config_root)

    for module_name, entries in configs.items():
        write_module_library(base_dir, module_name, entries)

    write_root_library(base_dir, list(configs.keys()))


if __name__ == "__main__":
    main()
