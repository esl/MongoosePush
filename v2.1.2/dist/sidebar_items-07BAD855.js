sidebarNodes={"extras":[{"group":"","headers":[{"anchor":"documentation","id":"Documentation"},{"anchor":"running-from-dockerhub","id":"Running from DockerHub"},{"anchor":"local-build-prerequisites","id":"Local build prerequisites"}],"id":"readme","title":"Introduction"},{"group":"","headers":[{"anchor":"restful-api-configuration","id":"RESTful API configuration"},{"anchor":"fcm-configuration","id":"FCM configuration"},{"anchor":"apns-configuration","id":"APNS configuration"},{"anchor":"environment-variables","id":"Environment variables"},{"anchor":"toml-schema","id":"TOML schema"}],"id":"configuration","title":"Configuration"},{"group":"","headers":[{"anchor":"prerequisites","id":"Prerequisites"},{"anchor":"production-release","id":"Production release"},{"anchor":"development-release","id":"Development release"}],"id":"local_build","title":"Local build"},{"group":"","headers":[{"anchor":"tl-dr","id":"TL;DR"},{"anchor":"basic-tests-non-release","id":"Basic tests (non-release)"},{"anchor":"integration-tests-using-production-grade-release","id":"Integration tests (using production-grade release)"},{"anchor":"test-environment-setup","id":"Test environment setup"}],"id":"test","title":"Running tests"},{"group":"","headers":[{"anchor":"running-from-dockerhub","id":"Running from DockerHub"},{"anchor":"building","id":"Building"},{"anchor":"configuration-basic","id":"Configuration (basic)"}],"id":"docker","title":"Docker"},{"group":"","headers":[{"anchor":"request","id":"Request"},{"anchor":"response","id":"Response"}],"id":"http_api","title":"HTTP API"},{"group":"","headers":[],"id":"healthcheck","title":"Healthcheck"},{"group":"","headers":[{"anchor":"default-dashboard","id":"Default dashboard"},{"anchor":"available-metrics","id":"Available metrics"},{"anchor":"how-to-quickly-see-all-metrics","id":"How to quickly see all metrics"},{"anchor":"prometheus-configuration","id":"Prometheus configuration"}],"id":"metrics","title":"Metrics"}],"modules":[{"deprecated":false,"group":"","id":"MongoosePush","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:alert/0","deprecated":false,"id":"alert/0","title":"alert()"},{"anchor":"t:alert_key/0","deprecated":false,"id":"alert_key/0","title":"alert_key()"},{"anchor":"t:data/0","deprecated":false,"id":"data/0","title":"data()"},{"anchor":"t:data_key/0","deprecated":false,"id":"data_key/0","title":"data_key()"},{"anchor":"t:error/0","deprecated":false,"id":"error/0","title":"error()"},{"anchor":"t:mode/0","deprecated":false,"id":"mode/0","title":"mode()"},{"anchor":"t:req_key/0","deprecated":false,"id":"req_key/0","title":"req_key()"},{"anchor":"t:request/0","deprecated":false,"id":"request/0","title":"request()"},{"anchor":"t:service/0","deprecated":false,"id":"service/0","title":"service()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"push/2","deprecated":false,"id":"push/2","title":"push(device_id, request)"}]}],"sections":[],"title":"MongoosePush"},{"deprecated":false,"group":"","id":"MongoosePushWeb.HealthcheckController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"send/2","deprecated":false,"id":"send/2","title":"send(conn, map)"}]}],"sections":[],"title":"MongoosePushWeb.HealthcheckController"},{"deprecated":false,"group":"API","id":"MongoosePush.API","nodeGroups":[{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:to_status/1","deprecated":false,"id":"to_status/1","title":"to_status(arg1)"}]}],"sections":[],"title":"MongoosePush.API"},{"deprecated":false,"group":"API","id":"MongoosePush.API.V1.ResponseEncoder","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"to_status/1","deprecated":false,"id":"to_status/1","title":"to_status(return_val)"}]}],"sections":[],"title":"MongoosePush.API.V1.ResponseEncoder"},{"deprecated":false,"group":"API","id":"MongoosePush.API.V2.ResponseEncoder","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"to_status/1","deprecated":false,"id":"to_status/1","title":"to_status(arg1)"}]}],"sections":[],"title":"MongoosePush.API.V2.ResponseEncoder"},{"deprecated":false,"group":"API","id":"MongoosePush.API.V3.ResponseEncoder","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"to_status/1","deprecated":false,"id":"to_status/1","title":"to_status(arg1)"}]}],"sections":[],"title":"MongoosePush.API.V3.ResponseEncoder"},{"deprecated":false,"group":"Configuration","id":"MongoosePush.Config.Utils","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"parse_bind_addr/1","deprecated":false,"id":"parse_bind_addr/1","title":"parse_bind_addr(string_addr)"}]}],"sections":[],"title":"MongoosePush.Config.Utils"},{"deprecated":false,"group":"Logs format","id":"MongoosePush.Logger.Common","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"flatten_metadata/1","deprecated":false,"id":"flatten_metadata/1","title":"flatten_metadata(metadata)"}]}],"sections":[],"title":"MongoosePush.Logger.Common"},{"deprecated":false,"group":"Logs format","id":"MongoosePush.Logger.JSON","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"format/4","deprecated":false,"id":"format/4","title":"format(level, message, arg, metadata)"}]}],"sections":[],"title":"MongoosePush.Logger.JSON"},{"deprecated":false,"group":"Logs format","id":"MongoosePush.Logger.LogFmt","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"format/4","deprecated":false,"id":"format/4","title":"format(level, message, arg, metadata)"}]}],"sections":[],"title":"MongoosePush.Logger.LogFmt"},{"deprecated":false,"group":"Metrics","id":"MongoosePush.Metrics.TelemetryMetrics","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"child_spec/1","deprecated":false,"id":"child_spec/1","title":"child_spec(_)"},{"anchor":"metrics/0","deprecated":false,"id":"metrics/0","title":"metrics()"},{"anchor":"periodic_measurements/0","deprecated":false,"id":"periodic_measurements/0","title":"periodic_measurements()"},{"anchor":"pooler/0","deprecated":false,"id":"pooler/0","title":"pooler()"},{"anchor":"running_pools/0","deprecated":false,"id":"running_pools/0","title":"running_pools()"}]}],"sections":[],"title":"MongoosePush.Metrics.TelemetryMetrics"},{"deprecated":false,"group":"Push notification services","id":"MongoosePush.Service","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:error/0","deprecated":false,"id":"error/0","title":"error()"},{"anchor":"t:error_reason/0","deprecated":false,"id":"error_reason/0","title":"error_reason()"},{"anchor":"t:error_type/0","deprecated":false,"id":"error_type/0","title":"error_type()"},{"anchor":"t:notification/0","deprecated":false,"id":"notification/0","title":"notification()"},{"anchor":"t:options/0","deprecated":false,"id":"options/0","title":"options()"}]},{"key":"callbacks","name":"Callbacks","nodes":[{"anchor":"c:choose_pool/2","deprecated":false,"id":"choose_pool/2","title":"choose_pool(mode, list)"},{"anchor":"c:prepare_notification/3","deprecated":false,"id":"prepare_notification/3","title":"prepare_notification(t, request, pool_name)"},{"anchor":"c:push/4","deprecated":false,"id":"push/4","title":"push(notification, t, pool_name, options)"},{"anchor":"c:supervisor_entry/1","deprecated":false,"id":"supervisor_entry/1","title":"supervisor_entry(arg1)"}]}],"sections":[],"title":"MongoosePush.Service"},{"deprecated":false,"group":"Push notification services","id":"MongoosePush.Service.APNS","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"choose_pool/2","deprecated":false,"id":"choose_pool/2","title":"choose_pool(mode, tags \\\\ [])"},{"anchor":"prepare_notification/3","deprecated":false,"id":"prepare_notification/3","title":"prepare_notification(device_id, request, pool)"},{"anchor":"push/4","deprecated":false,"id":"push/4","title":"push(notification, device_id, pool, opts \\\\ [])"},{"anchor":"supervisor_entry/1","deprecated":false,"id":"supervisor_entry/1","title":"supervisor_entry(pool_configs)"},{"anchor":"unify_error/1","deprecated":false,"id":"unify_error/1","title":"unify_error(reason)"}]}],"sections":[],"title":"MongoosePush.Service.APNS"},{"deprecated":false,"group":"Push notification services","id":"MongoosePush.Service.APNS.ErrorHandler","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"translate_error_reason/1","deprecated":false,"id":"translate_error_reason/1","title":"translate_error_reason(reason)"}]}],"sections":[],"title":"MongoosePush.Service.APNS.ErrorHandler"},{"deprecated":false,"group":"Push notification services","id":"MongoosePush.Service.APNS.State","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"child_spec/1","deprecated":false,"id":"child_spec/1","title":"child_spec(init_arg)"},{"anchor":"get_default_topic/1","deprecated":false,"id":"get_default_topic/1","title":"get_default_topic(pool_name)"},{"anchor":"start_link/1","deprecated":false,"id":"start_link/1","title":"start_link(arg)"}]}],"sections":[],"title":"MongoosePush.Service.APNS.State"},{"deprecated":false,"group":"Push notification services","id":"MongoosePush.Service.APNS.Supervisor","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"child_spec/1","deprecated":false,"id":"child_spec/1","title":"child_spec(init_arg)"},{"anchor":"start_link/1","deprecated":false,"id":"start_link/1","title":"start_link(arg)"}]}],"sections":[],"title":"MongoosePush.Service.APNS.Supervisor"},{"deprecated":false,"group":"Push notification services","id":"MongoosePush.Service.FCM","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"choose_pool/2","deprecated":false,"id":"choose_pool/2","title":"choose_pool(mode, tags \\\\ [])"},{"anchor":"prepare_notification/3","deprecated":false,"id":"prepare_notification/3","title":"prepare_notification(device_id, request, pool)"},{"anchor":"push/4","deprecated":false,"id":"push/4","title":"push(notification, device_id, pool, opts \\\\ [])"},{"anchor":"supervisor_entry/1","deprecated":false,"id":"supervisor_entry/1","title":"supervisor_entry(pools_configs)"},{"anchor":"unify_error/1","deprecated":false,"id":"unify_error/1","title":"unify_error(reason)"}]}],"sections":[],"title":"MongoosePush.Service.FCM"},{"deprecated":false,"group":"Push notification services","id":"MongoosePush.Service.FCM.ErrorHandler","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"translate_error_reason/1","deprecated":false,"id":"translate_error_reason/1","title":"translate_error_reason(reason)"}]}],"sections":[],"title":"MongoosePush.Service.FCM.ErrorHandler"},{"deprecated":false,"group":"Push notification services","id":"MongoosePush.Service.FCM.Pool.Supervisor","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"child_spec/1","deprecated":false,"id":"child_spec/1","title":"child_spec(init_arg)"},{"anchor":"start_link/1","deprecated":false,"id":"start_link/1","title":"start_link(arg)"}]}],"sections":[],"title":"MongoosePush.Service.FCM.Pool.Supervisor"},{"deprecated":false,"group":"Push notification services","id":"MongoosePush.Service.FCM.Pools","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"pool_size/2","deprecated":false,"id":"pool_size/2","title":"pool_size(service, name)"},{"anchor":"pools_by_mode/0","deprecated":false,"id":"pools_by_mode/0","title":"pools_by_mode()"},{"anchor":"select_worker/0","deprecated":false,"id":"select_worker/0","title":"select_worker()"},{"anchor":"worker_name/3","deprecated":false,"id":"worker_name/3","title":"worker_name(type, name, num)"}]}],"sections":[],"title":"MongoosePush.Service.FCM.Pools"},{"deprecated":false,"group":"Web","id":"MongoosePushWeb","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"__using__/1","deprecated":false,"id":"__using__/1","title":"__using__(which)"},{"anchor":"controller/0","deprecated":false,"id":"controller/0","title":"controller()"},{"anchor":"router/0","deprecated":false,"id":"router/0","title":"router()"}]}],"sections":[],"title":"MongoosePushWeb"},{"deprecated":false,"group":"Web","id":"MongoosePushWeb.APIv1.NotificationController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"open_api_operation/1","deprecated":false,"id":"open_api_operation/1","title":"open_api_operation(action)"},{"anchor":"send/2","deprecated":false,"id":"send/2","title":"send(conn, map)"},{"anchor":"send_operation/0","deprecated":false,"id":"send_operation/0","title":"send_operation()"}]}],"sections":[],"title":"MongoosePushWeb.APIv1.NotificationController"},{"deprecated":false,"group":"Web","id":"MongoosePushWeb.APIv2.NotificationController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"open_api_operation/1","deprecated":false,"id":"open_api_operation/1","title":"open_api_operation(action)"},{"anchor":"send/2","deprecated":false,"id":"send/2","title":"send(conn, map)"},{"anchor":"send_operation/0","deprecated":false,"id":"send_operation/0","title":"send_operation()"}]}],"sections":[],"title":"MongoosePushWeb.APIv2.NotificationController"},{"deprecated":false,"group":"Web","id":"MongoosePushWeb.APIv3.NotificationController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"open_api_operation/1","deprecated":false,"id":"open_api_operation/1","title":"open_api_operation(action)"},{"anchor":"send/2","deprecated":false,"id":"send/2","title":"send(conn, map)"},{"anchor":"send_operation/0","deprecated":false,"id":"send_operation/0","title":"send_operation()"}]}],"sections":[],"title":"MongoosePushWeb.APIv3.NotificationController"},{"deprecated":false,"group":"Web","id":"MongoosePushWeb.ApiSpec","sections":[],"title":"MongoosePushWeb.ApiSpec"},{"deprecated":false,"group":"Web","id":"MongoosePushWeb.Endpoint","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"broadcast/3","deprecated":false,"id":"broadcast/3","title":"broadcast(topic, event, msg)"},{"anchor":"broadcast!/3","deprecated":false,"id":"broadcast!/3","title":"broadcast!(topic, event, msg)"},{"anchor":"broadcast_from/4","deprecated":false,"id":"broadcast_from/4","title":"broadcast_from(from, topic, event, msg)"},{"anchor":"broadcast_from!/4","deprecated":false,"id":"broadcast_from!/4","title":"broadcast_from!(from, topic, event, msg)"},{"anchor":"call/2","deprecated":false,"id":"call/2","title":"call(conn, opts)"},{"anchor":"child_spec/1","deprecated":false,"id":"child_spec/1","title":"child_spec(opts)"},{"anchor":"config/2","deprecated":false,"id":"config/2","title":"config(key, default \\\\ nil)"},{"anchor":"config_change/2","deprecated":false,"id":"config_change/2","title":"config_change(changed, removed)"},{"anchor":"host/0","deprecated":false,"id":"host/0","title":"host()"},{"anchor":"init/1","deprecated":false,"id":"init/1","title":"init(opts)"},{"anchor":"local_broadcast/3","deprecated":false,"id":"local_broadcast/3","title":"local_broadcast(topic, event, msg)"},{"anchor":"local_broadcast_from/4","deprecated":false,"id":"local_broadcast_from/4","title":"local_broadcast_from(from, topic, event, msg)"},{"anchor":"path/1","deprecated":false,"id":"path/1","title":"path(path)"},{"anchor":"script_name/0","deprecated":false,"id":"script_name/0","title":"script_name()"},{"anchor":"server_info/1","deprecated":false,"id":"server_info/1","title":"server_info(scheme)"},{"anchor":"start_link/1","deprecated":false,"id":"start_link/1","title":"start_link(opts \\\\ [])"},{"anchor":"static_integrity/1","deprecated":false,"id":"static_integrity/1","title":"static_integrity(path)"},{"anchor":"static_lookup/1","deprecated":false,"id":"static_lookup/1","title":"static_lookup(path)"},{"anchor":"static_path/1","deprecated":false,"id":"static_path/1","title":"static_path(path)"},{"anchor":"static_url/0","deprecated":false,"id":"static_url/0","title":"static_url()"},{"anchor":"struct_url/0","deprecated":false,"id":"struct_url/0","title":"struct_url()"},{"anchor":"subscribe/2","deprecated":false,"id":"subscribe/2","title":"subscribe(topic, opts \\\\ [])"},{"anchor":"unsubscribe/1","deprecated":false,"id":"unsubscribe/1","title":"unsubscribe(topic)"},{"anchor":"url/0","deprecated":false,"id":"url/0","title":"url()"}]}],"sections":[],"title":"MongoosePushWeb.Endpoint"},{"deprecated":false,"group":"Web","id":"MongoosePushWeb.PrometheusMetricsController","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"send/2","deprecated":false,"id":"send/2","title":"send(conn, map)"}]}],"sections":[],"title":"MongoosePushWeb.PrometheusMetricsController"},{"deprecated":false,"group":"Web","id":"MongoosePushWeb.Router","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"api/2","deprecated":false,"id":"api/2","title":"api(conn, _)"},{"anchor":"call/2","deprecated":false,"id":"call/2","title":"call(conn, opts)"},{"anchor":"init/1","deprecated":false,"id":"init/1","title":"init(opts)"},{"anchor":"swagger_json/2","deprecated":false,"id":"swagger_json/2","title":"swagger_json(conn, _)"}]}],"sections":[],"title":"MongoosePushWeb.Router"},{"deprecated":false,"group":"Protocols and plugs","id":"MongoosePushWeb.Plug.CastAndValidate","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"update_schema/3","deprecated":false,"id":"update_schema/3","title":"update_schema(new_schema, conn, opts)"}]}],"sections":[],"title":"MongoosePushWeb.Plug.CastAndValidate"},{"deprecated":false,"group":"Protocols and plugs","id":"MongoosePushWeb.Plug.CastAndValidate.StubAdapter","sections":[],"title":"MongoosePushWeb.Plug.CastAndValidate.StubAdapter"},{"deprecated":false,"group":"Protocols and plugs","id":"MongoosePushWeb.Plug.MaybePutSwaggerUI","sections":[],"title":"MongoosePushWeb.Plug.MaybePutSwaggerUI"},{"deprecated":false,"group":"Protocols and plugs","id":"MongoosePushWeb.Plug.MaybeRenderSpec","sections":[],"title":"MongoosePushWeb.Plug.MaybeRenderSpec"},{"deprecated":false,"group":"Protocols and plugs","id":"MongoosePushWeb.Protocols.RequestDecoder","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"decode/1","deprecated":false,"id":"decode/1","title":"decode(schema)"}]}],"sections":[],"title":"MongoosePushWeb.Protocols.RequestDecoder"},{"deprecated":false,"group":"Protocols and plugs","id":"MongoosePushWeb.Protocols.RequestDecoderHelper","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"add_optional_fields/2","deprecated":false,"id":"add_optional_fields/2","title":"add_optional_fields(push_request, schema)"},{"anchor":"maybe_parse_to_atom/2","deprecated":false,"id":"maybe_parse_to_atom/2","title":"maybe_parse_to_atom(arg1, val)"},{"anchor":"parse_service/1","deprecated":false,"id":"parse_service/1","title":"parse_service(binary)"}]}],"sections":[],"title":"MongoosePushWeb.Protocols.RequestDecoderHelper"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas","sections":[],"title":"MongoosePushWeb.Schemas"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Request.SendNotification.Deep","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"alert/0","deprecated":false,"id":"alert/0","title":"alert()"},{"anchor":"base/0","deprecated":false,"id":"base/0","title":"base()"},{"anchor":"data/0","deprecated":false,"id":"data/0","title":"data()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Request.SendNotification.Deep"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertNotification","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Request.SendNotification.Deep.AlertNotification"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Alert","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Alert"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Data","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Request.SendNotification.Deep.Common.Data"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Request.SendNotification.Deep.MixedNotification","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Request.SendNotification.Deep.MixedNotification"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Request.SendNotification.Deep.SilentNotification"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Request.SendNotification.FlatNotification","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Request.SendNotification.FlatNotification"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Response.SendNotification.GenericError","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Response.SendNotification.GenericError"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Response.SendNotification.Gone","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Response.SendNotification.Gone"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Response.SendNotification.PayloadTooLarge","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Response.SendNotification.PayloadTooLarge"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Response.SendNotification.ServiceUnavailable","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Response.SendNotification.ServiceUnavailable"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Response.SendNotification.TooManyRequests","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Response.SendNotification.TooManyRequests"},{"deprecated":false,"group":"Schemas","id":"MongoosePushWeb.Schemas.Response.SendNotification.UnknownError","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:t/0","deprecated":false,"id":"t/0","title":"t()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"schema/0","deprecated":false,"id":"schema/0","title":"schema()"}]}],"sections":[],"title":"MongoosePushWeb.Schemas.Response.SendNotification.UnknownError"}],"tasks":[{"deprecated":false,"group":"","id":"Mix.Tasks.Certs.Dev","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"run/1","deprecated":false,"id":"run/1","title":"run(_)"}]}],"sections":[],"title":"mix certs.dev"},{"deprecated":false,"group":"","id":"Mix.Tasks.GhPagesDocs","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"run/1","deprecated":false,"id":"run/1","title":"run(list)"},{"anchor":"update_index_html/1","deprecated":false,"id":"update_index_html/1","title":"update_index_html(version)"},{"anchor":"update_versions_js/1","deprecated":false,"id":"update_versions_js/1","title":"update_versions_js(current)"}]}],"sections":[],"title":"mix gh_pages_docs"},{"deprecated":false,"group":"","id":"Mix.Tasks.Test.Env.Down","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"run/1","deprecated":false,"id":"run/1","title":"run(args)"}]}],"sections":[],"title":"mix test.env.down"},{"deprecated":false,"group":"","id":"Mix.Tasks.Test.Env.Up","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"run/1","deprecated":false,"id":"run/1","title":"run(args)"}]}],"sections":[],"title":"mix test.env.up"},{"deprecated":false,"group":"","id":"Mix.Tasks.Test.Env.Utils","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"compose/2","deprecated":false,"id":"compose/2","title":"compose(compose_binary, opcode_args)"},{"anchor":"flunk/1","deprecated":false,"id":"flunk/1","title":"flunk(reason)"},{"anchor":"wait_for_services/1","deprecated":false,"id":"wait_for_services/1","title":"wait_for_services(time_ms)"}]}],"sections":[],"title":"mix test.env.utils"},{"deprecated":false,"group":"","id":"Mix.Tasks.Test.Env.Wait","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"run/1","deprecated":false,"id":"run/1","title":"run(list)"}]}],"sections":[],"title":"mix test.env.wait"}]}