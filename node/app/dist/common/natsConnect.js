import { connect, nkeyAuthenticator } from "@nats-io/transport-node";
import { registerCleanupCB } from "./cleanupSequence.js";
import { logger } from "./logger.js";
import { getPublicKeyBySecret } from "./pkey.js";
export async function getNatsConnection() {
    const natsAddress = process.env.NATS_URL;
    const natsSecretKeyStr = process.env.NATS_USER_SECRET ?? "";
    const userPubKey = getPublicKeyBySecret(natsSecretKeyStr);
    const seed = new TextEncoder().encode(natsSecretKeyStr);
    const nc = await connect({
        servers: natsAddress,
        authenticator: nkeyAuthenticator(seed),
    });
    logger.info(`Connected to NATS/${process.env.NATS_ENGINE} as ${userPubKey}`);
    registerCleanupCB(async () => await nc.close());
    return nc;
}
