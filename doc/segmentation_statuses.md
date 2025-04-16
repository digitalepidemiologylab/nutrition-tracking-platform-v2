# Segmentation statuses

## Possible `status` values

* `initial`: request to segmentation service not sent yet
* `requested`: request to segmentation service sent
* `received`: response form segmentation received but not parsed yet
* `processed`: response form segmentation received processed
* `error`: error while requesting service, timeout (webhook not received) or error during response parsing

## State diagram

```mermaid
stateDiagram-v2
  state requested_with_success? <<choice>>
  state webhook_received? <<choice>>
  state segmentation_error? <<choice>>

  [*] --> initial : create segmentation
  initial --> requested_with_success?
  requested_with_success? --> requested : requested segmentation service with success\n(`request`)
  requested_with_success? --> error : requested with error\n(`fail`)
  requested --> webhook_received?
  webhook_received? --> received : webhook received\n(`receive`)
  webhook_received? --> received : cron load data\n(`receive`)
  webhook_received? --> error : response took too long\n(`fail`)
  received --> segmentation_error?
  segmentation_error? --> processed : no data parsing error\n(`process`)
  segmentation_error? --> error : data parsing error\n(`fail`)
  processed --> [*]

  note right of error
    error_details can be one of
    - `service_error`
    - `timeout`
    - `parsing_error`
    - `segmentation_error`
  end note
```
