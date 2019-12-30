#1/usr/bin/env python3
import threading
import requests
import sys


def dl(url, pkg):
    url_pkg = url + pkg
    print(url_pkg)
    r = requests.get(url_pkg)
    with open(f"./download/kernel/{pkg}", "wb") as f:
        f.write(r.content)


def show_versions():
    for osv, knv in [
           ("7.0.1406", "3.10.0-123"), ("7.1.1503", "3.10.0-229"),
           ("7.2.1511", "3.10.0-327"), ("7.3.1611", "3.10.0-514"),
           ("7.4.1708", "3.10.0-693"), ("7.5.1804", "3.10.0-862"),
           ("7.6.1810", "3.10.0-957"), ("7.7.1908", "3.10.0-1062")]:
        print(f"OS version: {osv}, Kernel version: {knv}")


def gen_links(fn):
    pkgs = []
    ver_link_base = None
    links = []

    with open(fn, 'r') as f:
        pkg_flag = True
        for line in f:
            line = line.strip()
            print(line)

            if line == "--":
                pkg_flag = False
                continue

            if pkg_flag:
                pkgs.append(line)
                continue

            if line.startswith('http'):
                ver_link_base = line
            elif line == '':
                ver_link_base = None
            else:
                if not ver_link_base or not ver_link_base.startswith('http') or not ver_link_base.endswith('/'):
                    raise Exception(f'Bad format: {line}')
                for pkg in pkgs:
                    pkg_with_version = f"{pkg}-{line}.rpm"
                    links.append((ver_link_base, pkg_with_version))
    return links


def main():
    show_versions()
    pkg_links = gen_links("kernel-versions.txt")
    with open("kernel_packages_list.txt", 'w') as kf:
        for url, pkg in pkg_links:
            kf.write(f"{url}{pkg}\n")

        if len(sys.argv) > 1 and sys.argv[1] == 'd':
            for url, pkg in pkg_links:
                dl(url, pkg)

    print("All Done!")


if __name__ == "__main__":
    main()
