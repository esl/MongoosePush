defmodule MongoosePush.Service.FCM.ErrorHandler do
  @moduledoc """
  Module responsible for handling errors returned by FCM service.
  """
  alias MongoosePush.Service

  # More information about possible return codes is here:
  # https://firebase.google.com/docs/reference/fcm/rest/v1/ErrorCode
  @spec translate_error_reason(Service.error_reason()) :: Service.error()
  def translate_error_reason(:INVALID_ARGUMENT), do: {:invalid_request, :INVALID_ARGUMENT}
  def translate_error_reason(:SENDER_ID_MISMATCH), do: {:auth, :SENDER_ID_MISMATCH}
  def translate_error_reason(:UNREGISTERED), do: {:unregistered, :UNREGISTERED}
  def translate_error_reason(:QUOTA_EXCEEDED), do: {:too_many_requests, :QUOTA_EXCEEDED}
  def translate_error_reason(:UNSPECIFIED), do: {:unspecified, :UNSPECIFIED}
  def translate_error_reason(:APNS_AUTH_ERROR), do: {:auth, :APNS_AUTH_ERROR}
  def translate_error_reason(:THIRD_PARTY_AUTH_ERROR), do: {:auth, :THIRD_PARTY_AUTH_ERROR}
  def translate_error_reason(:UNAVAILABLE), do: {:service_internal, :UNAVAILABLE}
  def translate_error_reason(:INTERNAL), do: {:service_internal, :INTERNAL}
end
