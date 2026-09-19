import { commonBufferStream, stdMapUpdTickCnt, } from "../../common/BufferStream.js";
export async function mkBufferStream(nc) {
    const createEmptyLiveBufferItemCb = () => new Map();
    const bufferUpdCb = (buff, _subj, data) => stdMapUpdTickCnt(buff, data, "I");
    const flushInterval = Number(process.env.FLUSH_MQL_INTERVALMS ?? 1000);
    return commonBufferStream(nc, createEmptyLiveBufferItemCb, bufferUpdCb, "pf", flushInterval);
}
