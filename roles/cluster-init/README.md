Adding OIDC add these to the api config
```
  --oidc-ca-file=/var/lib/kubernetes/{{ kube_ca_cert }} \
  --oidc-issuer-url=https://authentik.bronsonlabs.com/application/o/bpne-kubernetes/ \
  --oidc-client-id=kubernetes \
  --oidc-username-claim=email \
  --oidc-groups-claim=groups \
```