"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.helloWorld = void 0;
const tasks_1 = require("firebase-functions/v2/tasks");
exports.helloWorld = (0, tasks_1.onTaskDispatched)({
    retryConfig: {
        maxAttempts: 5,
        minBackoffSeconds: 60,
    },
    rateLimits: {
        maxConcurrentDispatches: 6,
    },
}, async (req) => {
    console.log("Task received:", req.data);
});
//# sourceMappingURL=index.js.map