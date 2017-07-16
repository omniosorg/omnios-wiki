Signing Packages
================

This document specifies the process (but not the implementation
specifics) that OmniTI uses for creating signed packages, so that
interested third parties can sign their packages as well. The process is
straightforward, but requires the administrator to be familiar with how
SSL and IPS work. The [packaging how-to documents](Packaging.md#How-tos) will be quite helpful here.

## Prerequisites

* A functioning IPS repository
* An SSL CA and certificate with which to sign the packages

## Setup OmniOS CA

```
mkdir ca
cd ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
```

omniosce-ca.cnf:

```
[ ca ]
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = /home/oetiker/checkouts/omniosce-ca
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand

# The root key and root certificate.
private_key       = $dir/private/ca.key.pem
certificate       = $dir/certs/ca.cert.pem

# For certificate revocation lists.
crlnumber         = $dir/crlnumber
crl               = $dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_loose

[ crl_ext ]
# issuerAltName=issuer:copy  #this would copy the issuer name to altname
authorityKeyIdentifier=keyid:always

[ policy_loose ]
countryName             = supplied
stateOrProvinceName     = optional
localityName            = supplied
organizationName        = supplied
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = supplied

[ req ]
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256
x509_extensions     = omniosce_ca

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

# Optionally, specify some defaults.
countryName_default             = GB
stateOrProvinceName_default     = 
localityName_default            =
0.organizationName_default      = OmniOSce or MyCompany
emailAddress			= github-id@omniosce.org or me@mycompany.com

[ omniosce_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
crlDistributionPoints = URI:https://crl.omniosce.org/root.crl
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ ips_cert ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = digitalSignature
extendedKeyUsage = codeSigning, clientAuth
```

edit this to change the dir= line to the ca location

```
openssl genrsa -aes256 -out private/ca.key.pem 4096
```

enter passphrase when prompted

```
openssl req -config omniosce-ca.cnf -key private/ca.key.pem \
        -new -x509 -days 7300 -sha256 -extensions omniosce_ca \
        -out certs/ca.cert.pem
```

answer questions for information in request

```
chmod 444 certs/ca.cert.pem
```

### Create the Cert revokation List

```
openssl ca -config omniosce-ca.cnf -gencrl -out root.crl
scp root.crl omniosce:/crl
```

### Revoke a Certificate

```
openssl ca -config omniosce-ca.cnf -revoke newcerts/1000.pem 
scp root.crl omniosce:/crl
```

### Create Cert for a Guardian

First the Guardian creates a CSR

```
openssl genrsa -aes256 -out key.pem 2048
openssl req -config omniosce-ca.cnf \
        -key key.pem -new -sha256 -out csr.pem
```

and sends it to ca@ommniosce.org

The CA then sign the csr with:

```
openssl ca -config omniosce-ca.cnf \
        -extensions ips_cert -days 366 -notext \
        -md sha256 -in csr.pem
```

## Method

1. Create a repo and publish some packages to it
2. Create an SSL CA and obtain its certificate and key. Alternately, use an existing one
3. Obtain the list of packages, in FMRI form, to sign (one way to do this is, e.g.,
  ```
  pkg info -r -g $REPO_URL 'pkg:/*@*-0.151008' | grep FMRI | awk '{ print $2 }' > ~/fmris_to_sign_151008
  ```
  which will write all the FMRIs to sign for the 151008 release to the file `fmris_to_sign_151008`
4. Sign the packages with something like

```
# pkgsign \
  -c /path/to/signing.crt \
  -k /path/to/signing.key \
  -s $REPO_URL \
  $(cat fmris_to_sign_151008)
```

Known issues / troubleshooting
------------------------------

TBD
