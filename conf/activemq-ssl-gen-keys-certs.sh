#!/bin/sh

# Author: Andriy Kalashnykov
# Contact: AndriyKalashnykov@gmail.com

rm broker.ks broker.ts broker.cert broker.p12 broker.pem client.ks client.ts client.cert client.p12 client.pem 

BROKER_KEYSTORE_PASSWORD=password
BROKER_DNAME="CN=localhost,OU=broker,O=localhost,C=US"
BROKER_KEYALG=RSA
BROKER_SIGALG=SHA256withRSA 
BROKER_VALIDTY=7300
BROKER_KEYSIZE=2048

CLIENT_KEYSTORE_PASSWORD=password
CLIENT_DNAME="CN=localhost,OU=broker,O=localhost,C=US"
CLIENT_KEYALG=RSA
CLIENT_SIGALG=SHA256withRSA
CLIENT_VALIDTY=7300
CLIENT_KEYSIZE=2048

rm -f *.ks *.ts *.cert

# Create a keystore for the broker SERVER
keytool \
	-genkey \
	-keyalg $BROKER_KEYALG \
	-sigalg $BROKER_SIGALG \
	-alias localhost \
	-dname "${BROKER_DNAME}" \
	-keystore broker.ks \
	-storepass $BROKER_KEYSTORE_PASSWORD \
    -keypass $BROKER_KEYSTORE_PASSWORD \
	-keysize $BROKER_KEYSIZE \
	-validity $BROKER_VALIDTY


# Export the broker SERVER certificate from the keystore
keytool \
	-export \
	-alias localhost \
	-keystore broker.ks \
	-storepass $CLIENT_KEYSTORE_PASSWORD \
	-file broker.cert

# Create the CLIENT keystore
keytool \
	-genkey \
	-keyalg $CLIENT_KEYALG \
	-sigalg $CLIENT_SIGALG \
	-alias client \
    -dname "$CLIENT_DNAME}" \
	-keystore client.ks \
	-storepass $CLIENT_KEYSTORE_PASSWORD \
    -keypass $CLIENT_KEYSTORE_PASSWORD \
	-keysize $CLIENT_KEYSIZE \
	-validity $CLIENT_VALIDTY

# Import the previous exported broker’s certificate into a CLIENT truststore
keytool \
	-import \
	-alias localhost \
	-keystore client.ts \
	-file broker.cert \
	-storepass $CLIENT_KEYSTORE_PASSWORD \
    -trustcacerts \
    -noprompt

# OPTIONAL steps...
# If you want to make trusted also the client, you must export the client’s certificate from the keystore
keytool -export -alias client -keystore client.ks -storepass $CLIENT_KEYSTORE_PASSWORD -file client.cert
# Import the client’s exported certificate into a broker SERVER truststore
keytool -import -alias client -keystore broker.ts -storepass $BROKER_KEYSTORE_PASSWORD -file client.cert -noprompt

# A good tool to know to list the contents of the key
keytool -list -keystore broker.ks -storepass $BROKER_KEYSTORE_PASSWORD

# # Export broker to PEM
keytool -importkeystore -srckeystore broker.ks -destkeystore broker.p12 -srcstoretype jks -deststoretype pkcs12 -srcstorepass $BROKER_KEYSTORE_PASSWORD -deststorepass $BROKER_KEYSTORE_PASSWORD
openssl pkcs12 -in broker.p12 -out broker.pem -passin pass:$BROKER_KEYSTORE_PASSWORD -passout pass:
openssl x509 -in broker.pem -noout -text -passin pass:

# # Export client to PEM
keytool -importkeystore -srckeystore client.ks -destkeystore client.p12 -srcstoretype jks -deststoretype pkcs12 -srcstorepass $CLIENT_KEYSTORE_PASSWORD -deststorepass $CLIENT_KEYSTORE_PASSWORD
openssl pkcs12 -in client.p12 -out client.pem -passin pass:$CLIENT_KEYSTORE_PASSWORD -passout pass:
openssl x509 -in client.pem -noout -text -passin pass: