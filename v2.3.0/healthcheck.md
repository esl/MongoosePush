# Healthcheck

MongoosePush exposes a `/healthcheck` endpoint, from which you can get information about the current status of all connections in a `JSON` format, grouped by connection pool. The response structure is described in the following [RFC draft](https://datatracker.ietf.org/doc/draft-inadarei-api-health-check). An example with 2 pools, one being connected to the service and the other one not, would look like this:

```json
{
  "description": "Health of MongoosePush connections to FCM and APNS services",
  "details": {
    "pool:pool1": [
      {
        "output": {
          "connected": 5,
          "disconnected": 0
        },
        "status": "pass",
        "time": "2020-07-01T11:58:30.093318Z"
      }
    ],
    "pool:pool2": [
      {
        "output": {
          "connected": 0,
          "disconnected": 5
        },
        "status": "fail",
        "time": "2020-07-01T11:58:30.102291Z"
      }
    ]
  },
  "releaseID": "2.0.2",
  "status": "pass",
  "version": "2"
}
```
If all the connections are down the response status is `503`; in all the other cases, it's `200`.

Please note that it's not recommended to use this frequently as it puts an extra load on the worker processes.
