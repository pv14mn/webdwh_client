const cbs = [];
export const cleanupSequence = async () => {
    for (const cb of cbs) {
        await cb();
    }
};
async function shutdown() {
    await cleanupSequence();
    process.exit();
}
process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
export function registerCleanupCB(cb) {
    cbs.push(cb);
}
