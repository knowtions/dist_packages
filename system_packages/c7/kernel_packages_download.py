#1/usr/bin/env python3
import requests


def dl(url, pkg):
    url_pkg = url + pkg
    print(url_pkg)
    r = requests.get(url_pkg)
    with open(f"./download/{pkg}", "wb") as f:
        f.write(r.content)
    print(f"Done with {pkg}")
   

for osv, knv in [
       ("7.0.1406", "3.10.0-123"), ("7.1.1503", "3.10.0-229"),
       ("7.2.1511", "3.10.0-327"), ("7.3.1611", "3.10.0-514"),
       ("7.4.1708", "3.10.0-693"), ("7.5.1804", "3.10.0-862"),
       ("7.6.1810", "3.10.0-957"), ("7.7.1908", "3.10.0-1062")]:

    url = f"http://vault.centos.org/{osv}/os/x86_64/Packages/"
    for pkg in (f"kernel-devel-{knv}.el7.x86_64.rpm", f"kernel-headers-{knv}.el7.x86_64.rpm"):
        dl(url, pkg)
