defmodule Mix.Tasks.Certs.Dev do
  @moduledoc """
  Generate fake certs (placeholders) for `HTTPS` endpoint and `APNS` service.

  Please be aware that `APNS` requires valid Apple Developer certificates, so it
  will not accept those fake certificates. Generated certificates may be used
  only with mock APNS service (like one provided by docker
  `mobify/apns-http2-mock-server`).
  """
  @shortdoc "Generate fake certs (placeholders) for HTTPS endpoint and APNS"

  use Mix.Task

  @spec run(term) :: :ok
  def run(_) do
    maybe_gen_dev_apns()
    maybe_gen_prod_apns()
    maybe_gen_https()
  end

  defp maybe_gen_dev_apns do
    maybe_gen_cert("priv/apns/dev_cert.pem", "priv/apns/dev_key.pem",
                   "mongoose-push-apns-dev")
  end

  defp maybe_gen_prod_apns do
    maybe_gen_cert("priv/apns/prod_cert.pem", "priv/apns/prod_key.pem",
                   "mongoose-push-apns-prod")
  end

  defp maybe_gen_https do
    maybe_gen_cert("priv/ssl/fake_cert.pem", "priv/ssl/fake_key.pem",
                   "mongoose-push")
  end

  defp maybe_gen_cert(cert_file, key_file, common_name) do
    if File.exists?(cert_file) and File.exists?(key_file) do
      :ok
    else
      gen_cert(cert_file, key_file, common_name)
    end
  end

  defp gen_cert(cert_file, key_file, common_name) do
    cert_dir = Path.dirname(cert_file)
    key_dir = Path.dirname(key_file)

    :ok = File.mkdir_p(cert_dir)
    :ok = File.mkdir_p(key_dir)

    {_, 0} = System.cmd("openssl", [
      "req", "-x509", "-nodes", "-days", "365", "-subj",
      "/C=PL/ST=ML/L=Krakow/CN=" <> common_name, "-newkey", "rsa:2048",
      "-keyout", key_file, "-out", cert_file
    ])

    :ok
  end
end
