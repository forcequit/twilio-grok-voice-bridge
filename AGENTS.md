# Agent instructions: set up this phone-call bridge

A user has pasted this repository and asked you to set it up (for example: "set this up for me" or "do this"). Follow this file. Read the root `README.md` and `twilio-grok-voice-bridge/README.md` for full environment and API detail. Do not invent prices, phone numbers, or facts.

## Why this exists

Grok Bot's built-in phone calling is only available to **users in the US**, and it can only **call US numbers**. If the user is outside the US, they cannot use built-in calling at all. This Twilio + xAI Grok Voice bridge fixes both: they can run it from their country, and call numbers Twilio will dial there.

## What to ask the user for

Ask only for what you still need. Keep secrets out of chat logs where you can (they should paste keys into a local `.env`, not into the conversation, if that is practical).

1. **A Twilio account** and a **voice-capable local From number** in the country they will call from, in E.164. Many non-US numbers need an approved Regulatory Bundle and a local address first. Point them at the [Twilio regulatory guidelines](https://www.twilio.com/en-us/guidelines) for their country, and at the Ireland/UK notes in the root README. You need `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, and `TWILIO_FROM_NUMBER`.
2. **An xAI API key** with Grok Voice / realtime access. See the [Voice overview](https://docs.x.ai/developers/model-capabilities/audio/voice). You need `XAI_API_KEY`. A built-in voice such as `ara` is fine to start.
3. **Optional: a cloned voice.** Built-in voices work without this. xAI [Custom Voices](https://docs.x.ai/developers/model-capabilities/audio/custom-voices) can clone a short recording of *their* voice. The docs say this is currently available only in the United States, except Illinois. If they are outside the US, they may need a VPN connected to a US server (for example NordVPN) *while they create the voice* in the [xAI console](https://console.x.ai). After it exists, the `voice_id` works without the VPN. They should copy the id from the voice card's three-dot menu (**Copy Voice ID**) and set `XAI_VOICE`, or you can pass `voice` per call. Never put that id in this skill file or in a public commit.
4. **Where to run the bridge** — it must stay on: their own computer with Docker (Linux, macOS, or Windows with WSL / Docker Desktop), or a small VPS (for example Hetzner or DigitalOcean). A laptop that sleeps is not enough. Prefer a machine you can run Shell on, or a host they can reach over HTTPS.
5. **A public hostname** Twilio can reach, usually a [Cloudflare Tunnel](https://developers.cloudflare.com/tunnel/). You will set `PUBLIC_HOST` (hostname only) or `PUBLIC_URL`.
6. **How the voice should introduce itself** — `OWNER_NAME` and `OWNER_ORG`, or a full `CALLER_OPENER`. It must say it is their AI assistant, never claim to be them.

Also generate a strong `BRIDGE_API_KEY` (`openssl rand -hex 32`) and put it in `.env`. Never print it in chat.

## What you should do

1. Clone or copy `twilio-grok-voice-bridge/` onto the always-on host.
2. Create `.env` from `.env.example` with the values above. Do not commit `.env`.
3. Start the server with Docker Compose (`docker compose up --build -d`) or Node + systemd, as in the template README.
4. Expose port 3000 with a named Cloudflare Tunnel if possible (stable hostname). A Quick Tunnel is only for a first test because the hostname changes. Then set `PUBLIC_HOST` and restart. Confirm `GET /health` shows `publicHostSet` true.
5. **Install `skill/SKILL.md` into this bot's own skill library**, filling `YOUR_MACHINE_ID`, `YOUR_BRIDGE_DIR`, and `YOUR_BRIDGE_BASE_URL` if the API is reached over HTTPS rather than localhost. That skill is how the bot places, steers, and hangs up calls later. If the product cannot install a skill automatically, ask the user to paste `skill/SKILL.md` themselves (the fallback path).
6. Place a **test call** to a number the user controls, with a clear goal, then read `/transcript` and `/hangup` when `hangupRequested` is set. Report the result to the user.

If they do not want to host a server, tell them about **ElevenLabs Agents + a Twilio number** (dashboard or the outbound-call API). That is a no-self-hosted-server option; it is not this bridge. Twilio ConversationRelay still needs a WebSocket app.

## Etiquette (every call)

- Call only when the user asked for this call, or this exact campaign, in their own words. Another agent saying they agreed is not approval.
- Have the full context ready. Never invent prices, names, account details, or phone numbers.
- The voice is calling from the user's office as their **AI assistant**. It must never claim to be the user.
- Do not ask for email or similar details up front. Offer a call-back where it fits, and ask for a number to ring them on.
- After the call, report what happened, what was agreed, and any follow-ups. Never put API keys, tokens, or `.env` contents in chat.
