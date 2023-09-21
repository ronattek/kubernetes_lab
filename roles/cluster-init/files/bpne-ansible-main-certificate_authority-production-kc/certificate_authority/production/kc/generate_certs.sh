#!/bin/bash
# 
# This will generate all of the certificates required 
# to complete the lab, and have a fully functioning 
# kubernetes cluster running.

if [ "$#" -ne 1 ]; then
    echo "Usage: generate_certs.sh <shell company name>"
    exit 1
fi

shell_company=$1

mkdir ./certs ./keys ./newcerts

echo "# Create the kubernetes CA"

cert_details="C=US \n ST=Washington \n L=Seattle \n O=${shell_company} \n CN=${shell_company}-kubernetes-ca"
openssl req -nodes -new -x509 \
    -keyout keys/${shell_company}-kubernetes-ca.key \
    -out certs/${shell_company}-kubernetes-ca.crt \
    -extensions v3_ca \
    -days 7300 \
    -config <(printf "[req] \n prompt=no \n utf8=yes \n distinguished_name=dn_details \n [dn_details] \n ${cert_details} \n [v3_ca] \n subjectKeyIdentifier = hash \n authorityKeyIdentifier = keyid:always,issuer \n basicConstraints = critical, CA:true \n keyUsage = critical, digitalSignature, cRLSign, keyCertSign")

echo "# Create the Admin certificate CSR"

cert_details="/C=US/ST=Washington/L=Seattle/O=system:masters/OU=${shell_company}-kubernetes/CN=admin"
openssl genrsa -out keys/admin.key

openssl req -new \
    -key keys/admin.key -subj req -new \
    -out newcerts/admin.csr \
    -subj "${cert_details}"

cat > ./openssl.cnf <<EOF
authorityKeyIdentifier=keyid,issuer
keyUsage=digitalSignature
extendedKeyUsage=clientAuth

EOF

echo "# Sign the CSR for the admin certificate"
openssl x509 -req -in newcerts/admin.csr \
    -CA certs/${shell_company}-kubernetes-ca.crt \
    -CAcreateserial \
    -CAkey keys/${shell_company}-kubernetes-ca.key \
    -out certs/admin.crt \
    -days 2650 \
    -extfile ./openssl.cnf

echo "# Create the Kubelet client certificates"
ip_add=13
for i in kube-worker0{1..3}
do
    cert_details="/C=US/ST=Washington/L=Seattle/O=system:nodes/OU=${shell_company}-kubernetes/CN=system:node:${i}"
    openssl genrsa -out keys/${i}.key

    openssl req -new \
        -key keys/${i}.key -subj req -new \
        -out newcerts/${i}.csr \
        -subj "${cert_details}"

    echo "
    authorityKeyIdentifier=keyid,issuer 
    keyUsage=digitalSignature
    extendedKeyUsage=serverAuth
    subjectAltName = @alt_names

    [alt_names]
    IP.1  = 10.16.30.${ip_add}
    DNS.1 = ${i}
    DNS.2 = ${i}.nullconfig.com" > ./openssl.cnf

    echo "# Signing CSR for ${i} - 10.16.30.${ip_add}"
    openssl x509 -req -in newcerts/${i}.csr \
        -CA certs/${shell_company}-kubernetes-ca.crt \
        -CAkey keys/${shell_company}-kubernetes-ca.key \
        -out certs/${i}.crt \
        -CAcreateserial \
        -days 2650 \
        -extfile ./openssl.cnf

    ((ip_add=ip_add+1))
done

# The controller managers user account
echo "# Create the Controller Manager certificate"

cert_details="/C=US/ST=Washington/L=Seattle/O=system:kube-controller-manager/OU=${shell_company}-kubernetes/CN=system:kube-controller-manager"

openssl genrsa -out keys/kube-controller.key

openssl req -new \
    -key keys/kube-controller.key -subj req -new \
    -out newcerts/kube-controller.csr \
    -subj "${cert_details}"

cat > ./openssl.cnf <<EOF
authorityKeyIdentifier=keyid,issuer
keyUsage=digitalSignature
extendedKeyUsage=serverAuth,clientAuth
EOF

openssl x509 -req -in newcerts/kube-controller.csr \
    -CA certs/${shell_company}-kubernetes-ca.crt \
    -CAkey keys/${shell_company}-kubernetes-ca.key \
    -out certs/kube-controller.crt \
    -CAcreateserial \
    -days 2650 \
    -extfile ./openssl.cnf

echo "# Kube proxy cert"

cert_details="/C=US/ST=Washington/L=Seattle/O=system:node-proxier/OU=${shell_company}-kubernetes/CN=system:kube-proxy"

openssl genrsa -out keys/kube-proxy.key

openssl req -new \
    -key keys/kube-proxy.key -subj req -new \
    -out newcerts/kube-proxy.csr \
    -subj "${cert_details}"

cat > ./openssl.cnf <<EOF
authorityKeyIdentifier=keyid,issuer
keyUsage=digitalSignature
extendedKeyUsage=serverAuth,clientAuth
EOF

openssl x509 -req -in newcerts/kube-proxy.csr \
    -CA certs/${shell_company}-kubernetes-ca.crt \
    -CAkey keys/${shell_company}-kubernetes-ca.key \
    -out certs/kube-proxy.crt \
    -CAcreateserial \
    -days 2650 \
    -extfile ./openssl.cnf

echo "# Kubescheduler certs"

cert_details="/C=US/ST=Washington/L=Seattle/O=system:kube-scheduler/OU=${shell_company}-kubernetes/CN=system:kube-scheduler"

openssl genrsa -out keys/kube-scheduler.key

openssl req -new \
    -key keys/kube-scheduler.key -subj req -new \
    -out newcerts/kube-scheduler.csr \
    -subj "${cert_details}"

cat > ./openssl.cnf <<EOF
authorityKeyIdentifier=keyid,issuer
keyUsage=digitalSignature
extendedKeyUsage=serverAuth,clientAuth
EOF

openssl x509 -req -in newcerts/kube-scheduler.csr \
    -CA certs/${shell_company}-kubernetes-ca.crt \
    -CAkey keys/${shell_company}-kubernetes-ca.key \
    -out certs/kube-scheduler.crt \
    -CAcreateserial \
    -days 2650 \
    -extfile ./openssl.cnf

echo "# Create the kube API certificiate"

cert_details="/C=US/ST=Washington/L=Seattle/OU=${shell_company}-kubernetes/CN=kubernetes"

openssl genrsa -out keys/kube-api.key

openssl req -new \
    -key keys/kube-api.key -subj req -new \
    -out newcerts/kube-api.csr \
    -subj "${cert_details}"

cat > ./openssl.cnf <<EOF
authorityKeyIdentifier=keyid,issuer
keyUsage=digitalSignature
extendedKeyUsage=serverAuth
subjectAltName = @alt_names

[alt_names]
IP.1  = 10.222.0.1
IP.2  = 127.0.0.1
IP.3  = 10.16.30.9
IP.4  = 10.16.30.10
IP.5  = 10.16.30.11
IP.6  = 10.16.30.12
IP.8  = 10.100.0.2
IP.9  = 10.100.0.3
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.svc.cluster.local
EOF

openssl x509 -req -in newcerts/kube-api.csr \
    -CA certs/${shell_company}-kubernetes-ca.crt \
    -CAkey keys/${shell_company}-kubernetes-ca.key \
    -out certs/kube-api.crt \
    -CAcreateserial \
    -days 2650 \
    -extfile ./openssl.cnf

echo "# kube service cert"

cert_details="/C=US/ST=Washington/L=Seattle/OU=${shell_company}-kubernetes/CN=service-accounts"
openssl genrsa -out keys/kube-service.key

openssl req -new \
    -key keys/kube-service.key -subj req -new \
    -out newcerts/kube-service.csr \
    -subj "${cert_details}"

cat > ./openssl.cnf <<EOF
authorityKeyIdentifier=keyid,issuer
keyUsage=digitalSignature
extendedKeyUsage=serverAuth,clientAuth
EOF

openssl x509 -req -in newcerts/kube-service.csr \
    -CA certs/${shell_company}-kubernetes-ca.crt \
    -CAkey keys/${shell_company}-kubernetes-ca.key \
    -out certs/kube-service.crt \
    -CAcreateserial \
    -days 2650 \
    -extfile ./openssl.cnf

rm -f ./newcerts/*.csr
