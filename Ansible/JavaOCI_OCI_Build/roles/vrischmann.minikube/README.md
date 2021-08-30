minikube
========

This role sets up a minikube instance. Works with both Linux and macOS hosts.

Role Variables
--------------

  * **minikube\_dependencies** is a list of packages to install.

Ansible's [virt\_net](http://docs.ansible.com/ansible/virt_net_module.html) module requires `lxml` and `libvirt-python`.

Minikube requires `qemu`, `firewalld`, `libvirt` and `dnsmasq`.

The actual packages are distribution dependent. They are installed by using the [package](http://docs.ansible.com/ansible/package_module.html) module from Ansible.

The defaults are for Debian/Ubuntu based systems so if you are running another distribution you need to override this.

Note: this is ignored when installing on macOS.

  * **minikube\_install\_dir** is the installation directory of the `minikube`, `kubectl`, `docker-machine` and either `docker-machine-driver-xhyve` or `docker-machine-driver-kvm`. Defaults to `/usr/local/bin`.

  * **minikube\_version** is the version of minikube to install. If you don't want the latest you can override this using any of the tags [here](https://github.com/kubernetes/minikube/releases).

  * **kubectl\_version** is the kubectl version to install. Defaults to `v1.7.0`. You can find the latest version [here](https://storage.googleapis.com/kubernetes-release/release/stable.txt).

  * **docker\_machine\_version** is the docker-machine version to install. Defaults to `v0.12.2`. You can find all versions [here](https://github.com/docker/machine/releases).

  * **docker_machine_kvm_driver_version** is the version of the KVM driver to install. Defaults to `v0.10.0`. You can find all versions [here](https://github.com/dhiltgen/docker-machine-kvm/releases).

Note: this is ignored when installing on macOS.

  * **docker_machine_xhyve_driver_version** is the version of the XHyve driver to install. Defaults to `v0.3.3`. You can find all versions [here](https://github.com/zchee/docker-machine-driver-xhyve/releases).

Note: this is ignored when installing on Linux.

Caveats
-------

Beware that if you change any version and the binary already exists in the installation directory, you'll have to remove it.

This is because this role does not download the binary everytime, it would be too costly when included in other roles.

Example Playbook
----------------

This role works with only the defaults so using it is trivial:

    - hosts: all
      roles:
        - vrischmann.minikube

If you want to change the installation directory:

    - hosts: all
      roles:
        - { role: vrischmann.minikube, minikube_install_dir: "/sbin" }

License
-------

MIT
