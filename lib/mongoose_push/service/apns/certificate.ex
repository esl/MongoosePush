defmodule MongoosePush.Service.APNS.Certificate do
  @moduledoc false

  require Record
  Record.defrecord :otp_cert,
    Record.extract(:OTPCertificate, from_lib: "public_key/include/public_key.hrl")
  Record.defrecord :tbs_cert,
    Record.extract(:TBSCertificate, from_lib: "public_key/include/public_key.hrl")
  Record.defrecord :cert_ext,
    Record.extract(:Extension,      from_lib: "public_key/include/public_key.hrl")
  Record.defrecord :cert_attr,
    Record.extract(:AttributeTypeAndValue,      from_lib: "public_key/include/public_key.hrl")

  # From: https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html
  @apns_topic_extn_id {1, 2, 840, 113635, 100, 6, 3, 6}

  def extract_topics!(cert_file) do
    maybe_extension =
      cert_file
      |> File.read!()
      |> :public_key.pem_decode()
      |> List.keyfind(:Certificate, 0)
      |> get_cert_extension!(@apns_topic_extn_id)

    if maybe_extension == nil do
        throw :no_extension
    end

    # The module below is compiled with Mix.Task.Compile.Asn1 after Elixir code is compiled,
    # so Elixir compiler may complain about undefined function here. Unfortunately current Mix
    # does not allow for running custom Mix tasks before Elixir's compiler.
    extn_value = cert_ext(maybe_extension, :extnValue)
    {:ok, topics} = :"APNS-Topics".decode(:"APNS-Topics", extn_value)
    topics
  end

  def extract_subject!(cert_file) do
    cert_file
    |> File.read!()
    |> :public_key.pem_decode()
    |> List.keyfind(:Certificate, 0)
    |> elem(1) # {:Certificate, DEREncoded, EncryptionInfo}
    |> :public_key.pkix_decode_cert(:otp)
    |> otp_cert(:tbsCertificate)
    |> tbs_cert(:subject)
    |> parse_subject_name()
  end

  defp parse_subject_name({:rdnSequence, rdn_sequence}) do
    rdn_sequence
    |> List.flatten()
    |> Enum.map(&(cert_attr(&1, :value))) # Get value for each RDN
    |> Enum.map(&normalize_rdn_string/1)
    |> List.insert_at(0, "")
    |> Enum.join("/")
  end

  defp normalize_rdn_string({_string_type, name}), do: normalize_rdn_string(name)
  defp normalize_rdn_string(name), do: ~s"#{name}"

  defp get_cert_extension!({:Certificate, cert, _}, ext_id) do
    cert
    |> :public_key.pkix_decode_cert(:otp)
    |> otp_cert(:tbsCertificate)
    |> tbs_cert(:extensions)
    |> ensure_extension_list()
    |> List.keyfind(ext_id, cert_ext(:extnID), nil)
  end

  defp ensure_extension_list(:asn1_NOVALUE), do: []
  defp ensure_extension_list(value), do: value
end
