import { fromSeed } from "@nats-io/nkeys";
export function getPublicKeyBySecret(sKey) {
    const seed = new TextEncoder().encode(sKey);
    const kp = fromSeed(seed);
    return kp.getPublicKey();
}
