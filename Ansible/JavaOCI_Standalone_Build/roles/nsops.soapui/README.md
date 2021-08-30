# Ansible: SoapUI

[![Build Status](https://travis-ci.org/nsops/ansible-soapui.svg?branch=master)](https://travis-ci.org/nsops/ansible-soapui) [![Ansible Galaxy](http://img.shields.io/badge/galaxy-nsops.intellij-blue.svg?style=flat)](https://galaxy.ansible.com/nsops/soapui/)

Install SoapUI in Ubuntu

### Requirements
- Java. It's recommended to install Ansible role: ```nsops.java```.

### Variables
- ```soapui_version```

Version to download. Default: **5.2.1**.

- ```soapui_install_dir```
Directory where soapui will be installed. Default: **/opt/soapui**.

- ```soapui_url```
URL to download SoapUI tar file.

### Dependencies
None

### Usage
```yaml
- hosts: all
  role:
    - { name: nsops.soapui }
```

```yaml
- hosts: all
  role:
    - { name: nsops.soapui, soapui_version: 5.0.0 }
```

### License
MIT