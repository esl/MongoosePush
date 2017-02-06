.PHONY: rel deps compile certs clean

all: rel
rel: certs deps compile

deps:
	mix deps.get
	mix deps.compile

compile:
	mix compile

certs: priv/ssl/fake_cert.pem priv/ssl/fake_server.pem priv/ssl/fake_dh_server.pem \
       priv/apns/app_cert.pem

priv/apns/app_cert.pem:
	@mkdir -p $(@D)
	openssl req \
    	-x509 -nodes -days 365 \
    	-subj '/C=PL/ST=ML/L=Krakow/CN=mongoose-push-apns' \
    	-newkey rsa:2048 -keyout priv/apns/app_key.pem -out priv/apns/app_cert.pem

priv/ssl/fake_cert.pem:
	@mkdir -p $(@D)
	openssl req \
		-x509 -nodes -days 365 \
		-subj '/C=PL/ST=ML/L=Krakow/CN=mongoose-push' \
		-newkey rsa:2048 -keyout priv/ssl/fake_key.pem -out priv/ssl/fake_cert.pem

priv/ssl/fake_server.pem: priv/ssl/fake_cert.pem
	cat priv/ssl/fake_cert.pem priv/ssl/fake_key.pem > priv/ssl/fake_server.pem

priv/ssl/fake_dh_server.pem:
	@mkdir -p $(@D)
	openssl dhparam -outform PEM -out priv/ssl/fake_dh_server.pem 1024
