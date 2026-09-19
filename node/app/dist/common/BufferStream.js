import { PassThrough } from "node:stream";
import { jetstream } from "@nats-io/jetstream";
import { logger } from "./logger.js";
export class BufferStream extends PassThrough {
    constructor(bufferCreate) {
        super({
            objectMode: true,
        });
        this.buffer = bufferCreate();
        this.#bufferCreate = bufferCreate;
    }
    #bufferCreate;
    buffer;
    get isEmpty() {
        return this.buffer.size === 0;
    }
    flush() {
        if (this.buffer.size) {
            this.write(this.buffer);
            this.buffer = this.#bufferCreate();
        }
    }
}
const StateMode = {
    start: 0,
    pendingMode: 1,
    normalMode: 2,
};
export class BufferStreamManager {
    constructor(bufferStream, bufferUpdCb, flushInterval) {
        this.#bufferStream = bufferStream;
        this.#bufferUpdCb = bufferUpdCb;
        this.#flushInterval = flushInterval;
    }
    #bufferStream;
    #flush() {
        this.#bufferStream.flush();
    }
    #bufferUpdCb;
    #serverTs = { first: 0, last: 0 };
    #clientTs = { first: 0, last: 0 };
    #flushInterval;
    #runFlushTimer(firstRunAfter, period) {
        let timerId = setTimeout(() => {
            if (this.#bufferStream.buffer.size) {
                this.#flush();
            }
            const loop = () => {
                timerId = setTimeout(() => {
                    if (this.#bufferStream.buffer.size) {
                        this.#flush();
                    }
                    loop();
                }, period);
            };
            loop();
        }, firstRunAfter);
        return {
            stop() {
                clearTimeout(timerId);
            },
        };
    }
    #strategies = {
        [StateMode.start]: (subj, data, pending) => {
            const now = Date.now();
            this.#serverTs.first = data.extts;
            this.#serverTs.last = data.extts;
            this.#clientTs.first = now;
            this.#clientTs.last = now;
            this.#bufferUpdCb(this.#bufferStream.buffer, subj, data);
            if (pending && now - data.extts > 100) {
                this.manage = this.#strategies[StateMode.pendingMode];
            }
            else {
                this.#runFlushTimer(this.#flushInterval, this.#flushInterval);
                this.manage = this.#strategies[StateMode.normalMode];
            }
        },
        [StateMode.pendingMode]: (subj, data, pending) => {
            const now = Date.now();
            if (this.#bufferStream.isEmpty) {
                this.#serverTs.first = data.extts;
                this.#clientTs.first = now;
            }
            this.#serverTs.last = data.extts;
            this.#clientTs.last = now;
            this.#bufferUpdCb(this.#bufferStream.buffer, subj, data);
            if (pending) {
                if (this.#serverTs.last >= this.#serverTs.first + this.#flushInterval) {
                    this.#flush();
                }
            }
            else {
                this.#runFlushTimer(this.#flushInterval - (this.#clientTs.last - this.#clientTs.first), this.#flushInterval);
                this.manage = this.#strategies[StateMode.normalMode];
            }
        },
        [StateMode.normalMode]: (subj, data, _pending) => {
            this.#bufferUpdCb(this.#bufferStream.buffer, subj, data);
        },
    };
    manage = this.#strategies[StateMode.start];
}
export function stdMapUpdTickCnt(buf, obj, keyName) {
    const key = obj[keyName];
    const existing = buf.get(key);
    if (existing) {
        Object.assign(existing, obj);
        existing.tickCnt++;
    }
    else {
        buf.set(key, { ...obj, tickCnt: 1 });
    }
}
async function bufferStrem4CoreEngine(nc, createEmptyBufferItem, bufferUpdCb, subjRoot, flushInterval) {
    const bufferStream = new BufferStream(createEmptyBufferItem);
    const bsm = new BufferStreamManager(bufferStream, bufferUpdCb, flushInterval);
    nc.subscribe(`${subjRoot}.>`, {
        callback: (err, msg) => {
            if (err) {
                logger.error(err);
                process.kill(process.pid, "SIGTERM");
            }
            else
                bsm.manage(msg.subject, msg.json(), 0);
        },
    });
    return bufferStream;
}
async function buffStream4JetStreamEngine(nc, createEmptyBufferItem, bufferUpdCb, subjRoot, flushInterval) {
    const bufferStream = new BufferStream(createEmptyBufferItem);
    const bsm = new BufferStreamManager(bufferStream, bufferUpdCb, flushInterval);
    const js = jetstream(nc);
    const consumer = await js.consumers.get(subjRoot, `${subjRoot}_${process.env.NATS_CONS_SECRET}`);
    const messages = await consumer.consume();
    (async () => {
        for await (const msg of messages) {
            bsm.manage(msg.subject, msg.json(), msg.info.pending);
            msg.ack();
        }
        logger.error("EOF stream. SIGTERM");
        process.kill(process.pid, "SIGTERM");
    })();
    return bufferStream;
}
export async function commonBufferStream(nc, createEmptyBufferItem, bufferUpdCb, subjRoot, flushInterval) {
    switch (process.env.NATS_ENGINE?.toLowerCase()) {
        case "core": {
            return bufferStrem4CoreEngine(nc, createEmptyBufferItem, bufferUpdCb, subjRoot, flushInterval);
        }
        case "jetstream": {
            return buffStream4JetStreamEngine(nc, createEmptyBufferItem, bufferUpdCb, subjRoot, flushInterval);
        }
        default:
            throw Error("NATS_ENGINE not set");
    }
}
