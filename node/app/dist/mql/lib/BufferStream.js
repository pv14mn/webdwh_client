import { commonBufferStream, stdMapUpdTickCnt, } from "../../common/BufferStream.js";
export async function mkBufferStream(nc) {
    const createEmptyLiveBufferItemCb = () => {
        const item = {
            dictData: [],
            factData: new Map(),
            get size() {
                return this.dictData.length + this.factData.size;
            },
        };
        return item;
    };
    const bufferUpdCb = (buff, subj, data) => {
        switch (subj) {
            case "mql.init":
                buff.dictData = data.idata;
                break;
            case "mql.main":
                stdMapUpdTickCnt(buff.factData, data, "icode");
                break;
            default:
                throw Error(`Unknown subject: ${subj}`);
        }
    };
    const flushInterval = Number(process.env.FLUSH_MQL_INTERVALMS ?? 1000);
    return commonBufferStream(nc, createEmptyLiveBufferItemCb, bufferUpdCb, "mql", flushInterval);
}
