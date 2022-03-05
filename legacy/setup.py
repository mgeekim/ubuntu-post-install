import os
import sys
import shutil
from pathlib import Path

def get_time_korea(tz="KST"):
    from datetime import datetime
    from pytz import timezone

    time_format = '%Y%m%d_%H%M%S_%f'
    zone = None
    if tz == "KST":
        zone = timezone('Asia/Seoul')
    return str(datetime.now(zone).strftime(time_format))

def make_backup(target_path, use_copy=True):
    path = Path(target_path)
    if (path.is_file() or path.is_dir()):
        new_path = path.parent / (path.name + "_{}".format(get_time_korea()))
        if use_copy:
            shutil.copy(target_path, new_path)
        else:
            shutil.move(target_path, new_path)
    else:
        pass

def file_replace(path, old_str, new_str):
    try:
        new_lines = ""
        with open(path, "r") as f:
            lines = f.readlines()
            for l in lines:
                if old_str in l:
                    l = l.replace(old_str, new_str)
                new_lines += l
        with open(path, "w") as f:
            f.write(new_lines)
        return True
    except Exception as e:
        return False

def add_line(path, string):
    with open(path, 'a') as file:
        file.write(string)
    return True

def change_sources(backup=False):
    try:
        sources_path = Path("/etc/apt/sources.list")
        if sources_path.is_file() and backup:
            make_backup(sources_path)
        file_replace(
            path=sources_path,
            old_str="deb http://archive.ubuntu.com",
            new_str="deb http://mirror.kakao.com")
        return True
    except Exception as e:
        return False

def copy(src, dst, backup=False):
    if not (src.is_file() and dst.parent.is_dir()):
        return False
    if dst.is_file() and backup:
        make_backup(dst, use_copy=False)
    shutil.copy(src=src, dst=dst)
    return True

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--chg_sources', dest='chg_sources', default=False, action='store_true')
    parser.add_argument('--cp_winterm', dest='cp_winterm', default=False, action='store_true')
    parser.add_argument('--cp_vscode', dest='cp_vscode', default=False, action='store_true')
    parser.add_argument('--add_alias', dest='add_alias', default=False, action='store_true')
    args = parser.parse_args()

    ret = False
    if args.chg_sources:
        ret = change_sources()
    if args.cp_winterm:
        src_path = Path("asset/windowsterminal/settings.json").resolve()
        dst_path = Path("/mnt/c/Users/64min/AppData/Local/Packages/",
                        "Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json")
        ret = copy(src_path, dst_path)
    if args.cp_vscode:
        src_path = Path("asset/vscode/settings.json").resolve()
        dst_path = Path("/mnt/c/Users/64min/AppData/Roaming/Code/User/settings.json")
        ret = copy(src_path, dst_path)
    if args.add_alias:
        string = "alias python=python3\n"
        target_path = "/home/mgkim/.bashrc"
        ret = add_line(Path(target_path), string)

    if ret != True:
        sys.exit(1)