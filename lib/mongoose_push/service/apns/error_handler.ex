defmodule MongoosePush.Service.APNS.ErrorHandler do
  @moduledoc """
  Module responsible for handling errors returned by APNS service
  """
  alias MongoosePush.Service

  # More information about possible return codes is here:
  # https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html
  @spec translate_error_reason(Service.error_reason() | {Service.error_reason(), any()}) ::
          Service.error()
  def translate_error_reason(:BadCollapseId), do: {:invalid_request, :BadCollapseId}
  def translate_error_reason(:BadDeviceToken), do: {:invalid_request, :BadDeviceToken}

  def translate_error_reason(:DeviceTokenNotForTopic),
    do: {:invalid_request, :DeviceTokenNotForTopic}

  def translate_error_reason(:IdleTimeout), do: {:invalid_request, :IdleTimeout}
  def translate_error_reason(:PayloadEmpty), do: {:invalid_request, :PayloadEmpty}
  def translate_error_reason(:TopicDisallowed), do: {:invalid_request, :TopicDisallowed}
  def translate_error_reason(:Forbidden), do: {:invalid_request, :Forbidden}

  def translate_error_reason(:BadMessageId), do: {:internal_config, :BadMessageId}
  def translate_error_reason(:BadPriority), do: {:internal_config, :BadPriority}
  def translate_error_reason(:BadTopic), do: {:internal_config, :BadTopic}
  def translate_error_reason(:DuplicateHeaders), do: {:internal_config, :DuplicateHeaders}
  def translate_error_reason(:MissingDeviceToken), do: {:internal_config, :MissingDeviceToken}
  def translate_error_reason(:MethodNotAllowed), do: {:internal_config, :MethodNotAllowed}
  def translate_error_reason(:BadPath), do: {:internal_config, :BadPath}
  def translate_error_reason(:MissingTopic), do: {:internal_config, :MissingTopic}
  def translate_error_reason(:BadExpirationDate), do: {:internal_config, :BadExpirationDate}

  def translate_error_reason(:ExpiredProviderToken), do: {:auth, :ExpiredProviderToken}
  def translate_error_reason(:InvalidProviderToken), do: {:auth, :InvalidProviderToken}
  def translate_error_reason(:MissingProviderToken), do: {:auth, :MissingProviderToken}
  def translate_error_reason(:BadCertificate), do: {:auth, :BadCertificate}

  def translate_error_reason(:BadCertificateEnvironment),
    do: {:auth, :BadCertificateEnvironment}

  def translate_error_reason(:Unregistered), do: {:unregistered, :Unregistered}

  def translate_error_reason(:TooManyProviderTokenUpdates),
    do: {:too_many_requests, :TooManyProviderTokenUpdates}

  def translate_error_reason(:TooManyRequests), do: {:too_many_requests, :TooManyRequests}

  def translate_error_reason(:ServiceUnavailable), do: {:service_internal, :ServiceUnavailable}
  def translate_error_reason(:Shutdown), do: {:service_internal, :Shutdown}
  def translate_error_reason(:InternalServerError), do: {:service_internal, :InternalServerError}

  def translate_error_reason(:PayloadTooLarge), do: {:payload_too_large, :PayloadTooLarge}

  def translate_error_reason({reason, _specific}), do: {:unknown, reason}
  def translate_error_reason(reason), do: {:unknown, reason}
end
