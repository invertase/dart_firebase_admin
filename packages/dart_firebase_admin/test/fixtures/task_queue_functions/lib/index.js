/**
 * Copyright 2026 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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