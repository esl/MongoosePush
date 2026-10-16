{:ok, _} = Application.ensure_all_started(:req)
MongoosePush.Support.API.start_mock_client()
