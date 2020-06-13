#!/usr/bin/env python3
import sys, subprocess
from apt import Cache, Package
from concurrent.futures import ThreadPoolExecutor
from logging import StreamHandler, Formatter, INFO, getLogger

def init_logger():
    handler = StreamHandler()
    handler.setLevel(INFO)
    handler.setFormatter(Formatter("[%(threadName)s] %(message)s"))
    logger = getLogger()
    logger.addHandler(handler)
    logger.setLevel(INFO)

def search(pkgname):
    if type(pkgname) == str:
        try:
            pkg = cache[pkgname].candidate
        except:
            return

        if pkg.is_installed:
            return
    else:
        pkg = pkgname

    dl_list.append(pkg.filename)
    dl_namelist.append(pkg.filename.split("/")[-1].split("_")[0])

    for  deps in pkg.dependencies:
        for d in deps.or_dependencies:
            try:
                dep = d.target_versions[0]
                break
            except:
                continue
        
        if not dep.filename in dl_list and not dep.is_installed:
            search(dep)


def dl(dl_list, dl_namelist, max, lc):
    def run(list, name):
        getLogger().info("start downloading: %s", name)
        cmd = "aria2c -d /var/cache/apt/archives {}".format(' '.join(list))
        subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
        getLogger().info("finsh downloading: %s", name)

    url = []

    with open("/usr/share/python-apt/templates/Ubuntu.mirrors") as f:
        mirrors = f.readlines()
    
    mirrors = [m.replace("\n", "") for m in mirrors]
    lc_start = mirrors.index("#LOC:" + lc) + 1

    for num in [mirrors.index(m) for m in mirrors if "#LOC:" in m]:
        if num > lc_start:
            lc_end = num
            break
    
    mirrors = mirrors[lc_start:lc_end]

    for d in dl_list:
        url.append([m + d for m in mirrors])

    with ThreadPoolExecutor(max_workers=max, thread_name_prefix="thread") as executor:
        for i in range(len(dl_list)):
            executor.submit(run, url[i], dl_namelist[i])

if __name__ == "__main__":
    dl_list = []
    dl_namelist = []

    init_logger()
    cache = Cache()

    for p in sys.argv[1:]:
        search(p)
    
    dl(dl_list, dl_namelist, 20, "JP")