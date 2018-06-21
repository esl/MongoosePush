defmodule MongoosePushRuntimeTest do
  use ExUnit.Case

  test "tls ciphers required by apns are available" do
    # APNS supports only:
    # - ECDHE-RSA-AES128-GCM-SHA256
    # - ECDHE-RSA-AES256-GCM-SHA384

    all_ciphers = :ssl.cipher_suites()
    apns_ciphers = Enum.filter(all_ciphers, fn cipher ->
      case cipher do
        {:ecdhe_rsa, :aes_128_gcm, _, :sha256} ->
          true
        {:ecdhe_rsa, :aes_256_gcm, _, :sha384} ->
          true
        _ ->
          false
      end
    end)

    assert length(apns_ciphers) > 0
  end

end
