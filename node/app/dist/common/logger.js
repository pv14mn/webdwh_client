import { default as pino } from "pino";
const isProduction = process.env.NODE_ENV === "production";
export const logger = pino({
    level: process.env.LOG_LEVEL || "info",
    transport: {
        targets: [
            {
                target: isProduction ? "pino/file" : "pino-pretty",
                options: {
                    destination: 1,
                    colorize: !isProduction,
                    translateTime: isProduction ? false : "yyyy-mm-dd HH:MM:ss",
                },
            },
        ],
    },
});
