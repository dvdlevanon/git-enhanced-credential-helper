<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]

<br />
<p align="center">
  <h3 align="center">Git Enhanced Credential Helper</h3>

  <p align="center">
    A git Credential Helper that supports multi accounts + encryption
  </p>
</p>


## Table of Contents

* [About the Project](#about-the-project)
* [Usage](#usage)
* [Contact](#contact)

## About The Project

This project provides a simple bash implementation of git credential helper, it support multiple accounts of the same URL. For example if you have two different github.com accounts, one is used for your main work while the other is your personal github account. (e.g. https://github.com/company-name/some-repo https://github.com/personal/repo).

It also provides a basic GnuPG encryption of the stored credentials.

## Usage

### Installation

Clone the repository
```
git clone https://github.com/dvdlevanon/git-enhanced-credential-helper.git
```

Run the `install-credential-helper.sh` script to install the new credential helper.

Encryption is enabled by passing the `--secure` as follow:
```
./install-credential-helper.sh --secure
```
When encryption is enabled, you *SHOULD* put a `.password` file near the `enhanced-credential-helper.sh` script. This file should contain a secure password for encryption/decryption of the credential files.

The credential files would be stored by default under the `store` folder near the `enhanced-credential-helper.sh` script. You may change it by passing `--store-dir` to the installer script as follow:
```
./install-credential-helper.sh --store-dir /path/to/store/dir
```

Of course you may pass both parameters like:
```
./install-credential-helper.sh --store-dir /path/to/store/dir --secure
```

### Restoring

If you want to go back to the old credential helper, you may run the following script:
```
./restore-credential-helper.sh
```

This would instruct git to use the old credential helper

A hidden file called `.old-credential.helper` is created upon installation which allows us to restore easily and safely.

### Usage

Once you install the new credential helper, just try to push/pull from a remote repository and you'll see the credentials are saved encrypted or unencrypted depending on the installation options. 

You may try to pull from different account in the same host name (e.g. github.com)

## Contact

David Levanon - dvdlevanon@gmail.com

</p>
