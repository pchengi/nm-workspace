#!/bin/bash
write_ca_ans_templ(){
cat <<EOF



placeholder.fqdn-CA



EOF
}
write_reqhost.ans_templ(){
cat <<EOF


placeholder.fqdn


EOF
}
print_templ() {
cat <<EOF
# ca-signing-policy.conf, see ca-signing-policy.doc for more information
#
# This is the configuration file describing the policy for what CAs are
# allowed to sign whoses certificates.
#
# This file is parsed from start to finish with a given CA and subject
# name.
# subject names may include the following wildcard characters:
#    *    Matches any number of characters.
#    ?    Matches any single character.
#
# CA names must be specified (no wildcards). Names containing whitespaces
# must be included in single quotes, e.g. 'Certification Authority'.
# Names must not contain new line symbols.
# The value of condition attribute is represented as a set of regular
# expressions. Each regular expression must be included in double quotes.
#
# This policy file dictates the following policy:
#   -The Globus CA can sign Globus certificates
#
# Format:
#------------------------------------------------------------------------
#  token type  | def.authority |                value
#--------------|---------------|-----------------------------------------
# EACL entry #1|

 access_id_CA      X509         '/O=ESGF/OU=ESGF.ORG/CN=placeholder'

 pos_rights        globus        CA:sign

 cond_subjects     globus       '"/O=ESGF/OU=ESGF.ORG/*"'

# end of EACL
EOF
}
