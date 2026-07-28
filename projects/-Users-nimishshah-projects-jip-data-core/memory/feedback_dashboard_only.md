---
name: Dashboard is the only interface
description: User dropped Telegram notifications when shown the Cron Runs dashboard panel — single source of truth is https://data.jslwealth.in/
type: feedback
originSessionId: 2f310c99-51f6-4ae3-91ae-f37729895270
---
Don't propose messaging integrations (Telegram, Slack, email, SMS) unless
the user explicitly asks. The dashboard is the single source of truth.

When I built the loud-fail cron system on 2026-04-13, I initially wired
Telegram alerts as the failure notification channel and had scripts ready
for bot token + chat ID. The moment the user saw that de_cron_run rows
would render in the dashboard's new "Cron Runs (last 48h)" panel, they
said verbatim: *"actually chuk the telegram part - if the statuses get
updated on the dashboard well, i dont need any other interface"*.

**Why:** The user runs a small, focused ops posture. They check the
dashboard when they want state; they don't want push notifications
fragmenting their attention. One pane of glass beats three.

**How to apply:**
- When designing failure visibility, always make the dashboard the
  primary surface. Rows in `de_cron_run`, `de_healing_log`,
  `de_pipeline_log`, and `de_data_anomalies` all need to render in the
  observatory UI before anything else.
- Do not re-offer Telegram/Slack/email hooks. If an alerting channel
  becomes genuinely necessary for something time-critical (e.g. total
  system outage), ask explicitly before building it.
- If writing scripts that currently have outbound notification code,
  gate it behind an env var and default off.
